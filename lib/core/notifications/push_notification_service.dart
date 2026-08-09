import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import '../auth/api_client.dart';

/// Top-level background message handler required by Firebase Messaging
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint(
    "Handling background message: ${message.messageId} - ${message.notification?.title}",
  );
}

class PushNotificationPayload {
  final String id;
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final DateTime receivedAt;
  final bool isRead;

  PushNotificationPayload({
    required this.id,
    required this.title,
    required this.body,
    required this.data,
    required this.receivedAt,
    this.isRead = false,
  });

  factory PushNotificationPayload.fromRemoteMessage(RemoteMessage message) {
    return PushNotificationPayload(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title:
          message.notification?.title ??
          message.data['title'] ??
          'Notification',
      body: message.notification?.body ?? message.data['body'] ?? '',
      data: message.data,
      receivedAt: DateTime.now(),
    );
  }

  factory PushNotificationPayload.fromJson(Map<String, dynamic> json) {
    return PushNotificationPayload(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      data: json['payload'] is Map
          ? Map<String, dynamic>.from(json['payload'])
          : {},
      receivedAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
      isRead: json['status'] == 'read',
    );
  }
}

class PushNotificationService {
  static final PushNotificationService _instance =
      PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  FirebaseMessaging get _messaging => FirebaseMessaging.instance;
  final ApiClient _apiClient = ApiClient();

  /// Local notifications plugin for displaying foreground notifications
  /// and creating the Android notification channel.
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// Android notification channel — must match the ID in AndroidManifest.xml.
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );

  String? _fcmToken;
  bool _isInitialized = false;

  final StreamController<PushNotificationPayload>
  _foregroundNotificationController =
      StreamController<PushNotificationPayload>.broadcast();

  final List<PushNotificationPayload> _receivedNotifications = [];
  final Map<String, bool> _topicSubscriptions = {
    'study_reminders': true,
    'ielts_tips': true,
    'exam_alerts': true,
    'daily_streak': true,
  };

  Stream<PushNotificationPayload> get onNotificationReceived =>
      _foregroundNotificationController.stream;

  List<PushNotificationPayload> get receivedNotifications =>
      List.unmodifiable(_receivedNotifications);

  Map<String, bool> get topicSubscriptions =>
      Map.unmodifiable(_topicSubscriptions);
  String? get fcmToken => _fcmToken;
  bool get isInitialized => _isInitialized;

  /// Initialize Firebase Push Notifications and register listeners
  Future<void> initialize({String? userId}) async {
    if (_isInitialized) return;

    try {
      // Request permissions
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      debugPrint(
        'Push Notification Authorization Status: ${settings.authorizationStatus}',
      );

      // ── Create the Android notification channel ──
      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await androidPlugin?.createNotificationChannel(_channel);

      // Initialize flutter_local_notifications
      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwinInit = DarwinInitializationSettings();
      const initSettings = InitializationSettings(
        android: androidInit,
        iOS: darwinInit,
      );
      await _localNotifications.initialize(settings: initSettings);

      // Request POST_NOTIFICATIONS permission on Android 13+ (API 33+)
      if (defaultTargetPlatform == TargetPlatform.android) {
        final granted = await androidPlugin?.requestNotificationsPermission();
        debugPrint('Android POST_NOTIFICATIONS permission granted: $granted');
      }

      // Enable foreground notification presentation for iOS
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        await _messaging.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
      }

      // Register background handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // Get FCM Token (waiting for APNs token first on iOS)
      try {
        if (defaultTargetPlatform == TargetPlatform.iOS) {
          String? apnsToken = await _messaging.getAPNSToken();
          if (apnsToken == null) {
            // Wait briefly for APNs token to be populated by the OS
            for (int i = 0; i < 3; i++) {
              await Future.delayed(const Duration(seconds: 1));
              apnsToken = await _messaging.getAPNSToken();
              if (apnsToken != null) break;
            }
          }

          if (apnsToken != null) {
            debugPrint('APNs Token: $apnsToken');
            _fcmToken = await _messaging.getToken();
            debugPrint('FCM Token: $_fcmToken');
          } else {
            debugPrint(
              'APNs Token is null (iOS Simulator detected or APNs key pending in Firebase)',
            );
            _fcmToken =
                'fcm_ios_sim_token_${DateTime.now().millisecondsSinceEpoch}';
            debugPrint('Using FCM Simulator Token: $_fcmToken');
          }
        } else {
          _fcmToken = await _messaging.getToken();
          debugPrint('FCM Token: $_fcmToken');
        }
      } catch (e) {
        debugPrint(
          'Failed to get FCM token directly from Firebase, fallback mock token used: $e',
        );
        _fcmToken = 'fcm_mock_token_${DateTime.now().millisecondsSinceEpoch}';
      }

      if (_fcmToken != null && userId != null) {
        await registerDeviceToken(userId: userId, deviceToken: _fcmToken!);
      }

      // Listen for token refreshes
      _messaging.onTokenRefresh.listen((newToken) async {
        _fcmToken = newToken;
        debugPrint('FCM Token Refreshed: $newToken');
        if (userId != null) {
          await registerDeviceToken(userId: userId, deviceToken: newToken);
        }
      });

      // Handle Foreground Notifications
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        final payload = PushNotificationPayload.fromRemoteMessage(message);
        _receivedNotifications.insert(0, payload);
        _foregroundNotificationController.add(payload);

        // Show as a system notification when the app is in the foreground
        final notification = message.notification;
        if (notification != null) {
          _localNotifications.show(
            id: notification.hashCode,
            title: notification.title,
            body: notification.body,
            notificationDetails: NotificationDetails(
              android: AndroidNotificationDetails(
                _channel.id,
                _channel.name,
                channelDescription: _channel.description,
                importance: Importance.high,
                priority: Priority.high,
                icon: '@mipmap/ic_launcher',
              ),
              iOS: const DarwinNotificationDetails(),
            ),
          );
        }
      });

      // Handle App Launch / Background Click
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        final payload = PushNotificationPayload.fromRemoteMessage(message);
        _receivedNotifications.insert(0, payload);
        _foregroundNotificationController.add(payload);
      });

      // Check initial message if launched from terminated state
      RemoteMessage? initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        final payload = PushNotificationPayload.fromRemoteMessage(
          initialMessage,
        );
        _receivedNotifications.insert(0, payload);
        _foregroundNotificationController.add(payload);
      }

      // Default topic subscriptions
      for (final topic in _topicSubscriptions.keys) {
        if (_topicSubscriptions[topic] == true) {
          await subscribeToTopic(topic);
        }
      }

      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing PushNotificationService: $e');
      _fcmToken ??= 'fcm_fallback_${DateTime.now().millisecondsSinceEpoch}';
      _isInitialized = true;
    }
  }

  /// Register FCM Device Token with Go Gateway (`POST /api/v1/notifications/devices`)
  Future<bool> registerDeviceToken({
    required String userId,
    required String deviceToken,
    String platform = 'android',
  }) async {
    try {
      final response = await _apiClient.post('/api/v1/notifications/devices', {
        'user_id': userId,
        'device_token': deviceToken,
        'platform': platform,
      });
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Failed to register device token with backend: $e');
      return false;
    }
  }

  /// Toggle topic subscription
  Future<void> toggleTopic(String topic, bool enable) async {
    _topicSubscriptions[topic] = enable;
    if (enable) {
      await subscribeToTopic(topic);
    } else {
      await unsubscribeFromTopic(topic);
    }
  }

  /// Subscribe to FCM Topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      _topicSubscriptions[topic] = true;
    } catch (e) {
      debugPrint('Failed to subscribe to topic $topic: $e');
      _topicSubscriptions[topic] =
          true; // Local state preserved for demo/testing
    }
  }

  /// Unsubscribe from FCM Topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      _topicSubscriptions[topic] = false;
    } catch (e) {
      debugPrint('Failed to unsubscribe from topic $topic: $e');
      _topicSubscriptions[topic] = false;
    }
  }

  /// Fetch user notifications history from Go Gateway (`GET /api/v1/notifications/user/{userID}`)
  Future<List<PushNotificationPayload>> fetchNotificationHistory(
    String userId,
  ) async {
    try {
      final response = await _apiClient.get(
        '/api/v1/notifications/user/$userId',
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List notifs = data['notifications'] ?? [];
        return notifs.map((n) => PushNotificationPayload.fromJson(n)).toList();
      }
    } catch (e) {
      debugPrint('Failed to fetch notification history: $e');
    }
    return _receivedNotifications;
  }

  void addLocalNotification(PushNotificationPayload notification) {
    _receivedNotifications.insert(0, notification);
    _foregroundNotificationController.add(notification);
  }

  void clearHistory() {
    _receivedNotifications.clear();
  }
}
