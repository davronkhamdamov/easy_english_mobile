import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_english/core/notifications/push_notification_service.dart';
import 'package:easy_english/features/notification/presentation/notification_settings_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PushNotificationPayload Tests', () {
    test('PushNotificationPayload JSON Deserialization', () {
      final json = {
        'id': 'notif_123',
        'title': 'Daily IELTS Practice',
        'body': 'Your speaking drill is ready',
        'payload': {'topic': 'study_reminders'},
        'created_at': '2026-08-07T12:00:00Z',
        'status': 'queued',
      };

      final payload = PushNotificationPayload.fromJson(json);
      expect(payload.id, equals('notif_123'));
      expect(payload.title, equals('Daily IELTS Practice'));
      expect(payload.body, equals('Your speaking drill is ready'));
      expect(payload.data['topic'], equals('study_reminders'));
    });
  });

  group('PushNotificationService Singleton & State Tests', () {
    final service = PushNotificationService();

    test('PushNotificationService initial state & topic defaults', () {
      expect(service.topicSubscriptions.length, equals(4));
      expect(service.topicSubscriptions['study_reminders'], isTrue);
      expect(service.topicSubscriptions['ielts_tips'], isTrue);
      expect(service.topicSubscriptions['exam_alerts'], isTrue);
      expect(service.topicSubscriptions['daily_streak'], isTrue);
    });

    test('Topic subscription toggling', () async {
      await service.toggleTopic('study_reminders', false);
      expect(service.topicSubscriptions['study_reminders'], isFalse);

      await service.toggleTopic('study_reminders', true);
      expect(service.topicSubscriptions['study_reminders'], isTrue);
    });

    test('Local notification addition & history management', () {
      service.clearHistory();
      expect(service.receivedNotifications, isEmpty);

      final notif = PushNotificationPayload(
        id: 'test_1',
        title: 'Test Notification',
        body: 'Test Body',
        data: {},
        receivedAt: DateTime.now(),
      );

      service.addLocalNotification(notif);
      expect(service.receivedNotifications.length, equals(1));
      expect(service.receivedNotifications.first.title, equals('Test Notification'));

      service.clearHistory();
      expect(service.receivedNotifications, isEmpty);
    });
  });

  group('NotificationSettingsScreen Widget Tests', () {
    testWidgets('NotificationSettingsScreen renders title, FCM card, topics, and trigger button', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: NotificationSettingsScreen(userId: 'test_usr_widget'),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Push Notifications'), findsOneWidget);
      expect(find.text('Push Notification Gateway'), findsOneWidget);
      expect(find.text('FCM Active'), findsOneWidget);
      expect(find.text('Notification Channels & Topics'), findsOneWidget);
      expect(find.text('Daily Study Reminders'), findsOneWidget);
      expect(find.text('IELTS AI Tips & Strategy'), findsOneWidget);
      expect(find.text('Mock Exam & Diagnostic Alerts'), findsOneWidget);
      expect(find.text('Daily Streak Safeguard'), findsOneWidget);
      expect(find.text('Send Test Push Notification'), findsOneWidget);
      expect(find.text('Trigger Go Gateway Push'), findsOneWidget);
    });
  });
}
