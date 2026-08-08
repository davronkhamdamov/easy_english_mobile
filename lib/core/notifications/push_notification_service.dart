import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import '../auth/api_client.dart';

/// Top-level background message handler required by Firebase Messaging
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("Handling background message: ${message.messageId} - ${message.notification?.title}");
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
      title: message.notification?.title ?? message.data['title'] ?? 'Notification',
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
      data: json['payload'] is Map ? Map<String, dynamic>.from(json['payload']) : {},
      receivedAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
      isRead: json['status'] == 'read',
    );
  }
}

class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  FirebaseMessaging get _messaging => FirebaseMessaging.instance;
  final ApiClient _apiClient = ApiClient();

  String? _fcmToken;
  bool _isInitialized = false;

  final StreamController<PushNotificationPayload> _foregroundNotificationController =
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

  Map<String, bool> get topicSubscriptions => Map.unmodifiable(_topicSubscriptions);
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

      debugPrint('Push Notification Authorization Status: ${settings.authorizationStatus}');

      // Register background handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // Get FCM Token
      try {
        _fcmToken = await _messaging.getToken();
      } catch (e) {
        debugPrint('Failed to get FCM token directly from Firebase, fallback mock token used: $e');
        _fcmToken = 'fcm_mock_token_${DateTime.now().millisecondsSinceEpoch}';
      }

      if (_fcmToken != null && userId != null) {
        await registerDeviceToken(userId: userId, deviceToken: _fcmToken!);
      }

      // Listen for token refreshes
      _messaging.onTokenRefresh.listen((newToken) async {
        _fcmToken = newToken;
        if (userId != null) {
          await registerDeviceToken(userId: userId, deviceToken: newToken);
        }
      });

      // Handle Foreground Notifications
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        final payload = PushNotificationPayload.fromRemoteMessage(message);
        _receivedNotifications.insert(0, payload);
        _foregroundNotificationController.add(payload);
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
        final payload = PushNotificationPayload.fromRemoteMessage(initialMessage);
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
  Future<bool> registerDeviceToken({required String userId, required String deviceToken, String platform = 'android'}) async {
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
      _topicSubscriptions[topic] = true; // Local state preserved for demo/testing
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

  /// Trigger a live push notification test from Go Backend (`POST /api/v1/notifications/push`)
  Future<bool> sendTestPushNotification({
    required String userId,
    required String title,
    required String body,
    Map<String, String>? data,
  }) async {
    final token = _fcmToken ?? 'fcm_test_device_token';
    try {
      final response = await _apiClient.post('/api/v1/notifications/push', {
        'user_id': userId,
        'device_token': token,
        'title': title,
        'body': body,
        if (data != null) 'data': data,
      });

      if (response.statusCode == 202 || response.statusCode == 200) {
        // Also simulate immediate local delivery for testing feedback
        final testPayload = PushNotificationPayload(
          id: 'test_${DateTime.now().millisecondsSinceEpoch}',
          title: title,
          body: body,
          data: data ?? {},
          receivedAt: DateTime.now(),
        );
        _receivedNotifications.insert(0, testPayload);
        _foregroundNotificationController.add(testPayload);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error sending test push notification: $e');
      return false;
    }
  }

  /// Fetch user notifications history from Go Gateway (`GET /api/v1/notifications/user/{userID}`)
  Future<List<PushNotificationPayload>> fetchNotificationHistory(String userId) async {
    try {
      final response = await _apiClient.get('/api/v1/notifications/user/$userId');
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
