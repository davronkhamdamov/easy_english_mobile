import '../../../../core/notifications/push_notification_service.dart';
import '../../domain/models/notification_item.dart';

/// Repository for managing app notifications.
///
/// TODO: Remove mock notifications data below and replace with production
/// backend API integration (e.g. GET /api/v1/notifications/user/{userID})
class NotificationRepository {
  final PushNotificationService _pushService = PushNotificationService();

  // TODO: Remove this mock notifications list when backend API is live.
  static final List<NotificationItem> _mockNotifications = [
    NotificationItem(
      id: 'notif_mock_1',
      title: 'AI Speaking Coach Feedback 🎙️',
      message:
          'Your recent Speaking Part 2 recording has been evaluated. Band Score: 7.5! Tap to review detailed fluency and pronunciation suggestions.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 12)),
      isRead: false,
      category: NotificationCategory.aiCoach,
    ),
    NotificationItem(
      id: 'notif_mock_2',
      title: 'Daily Streak Safeguard 🔥',
      message:
          'You are on a 5-day study streak! Complete today\'s 5-minute vocabulary practice to keep it active before midnight.',
      timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
      isRead: false,
      category: NotificationCategory.streakAlert,
    ),
    NotificationItem(
      id: 'notif_mock_3',
      title: 'Writing Task 2 Essay Graded 📝',
      message:
          'Your essay "Impact of Artificial Intelligence on Future Employment" was scored Band 7.0 with lexical resource improvement notes.',
      timestamp: DateTime.now().subtract(const Duration(hours: 4)),
      isRead: false,
      category: NotificationCategory.aiCoach,
    ),
    NotificationItem(
      id: 'notif_mock_4',
      title: 'Full Mock Exam Scheduled ⏰',
      message:
          'Full Academic IELTS Reading & Listening Mock Test starts tomorrow at 10:00 AM. Get your workspace ready!',
      timestamp: DateTime.now().subtract(const Duration(hours: 18)),
      isRead: true,
      category: NotificationCategory.mockExam,
    ),
    NotificationItem(
      id: 'notif_mock_5',
      title: 'Grammar Flashcards Mastery 📚',
      message:
          'Spaced-repetition reminder: 15 grammar items are ready for review in your Word Bank container.',
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      isRead: true,
      category: NotificationCategory.studyReminder,
    ),
    NotificationItem(
      id: 'notif_mock_6',
      title: 'Easy IELTS v2.0 Released 🚀',
      message:
          'We added real-time AI accent detection and expanded Band 8+ vocabulary cards. Explore all new features today!',
      timestamp: DateTime.now().subtract(const Duration(days: 2, hours: 5)),
      isRead: true,
      category: NotificationCategory.system,
    ),
  ];

  /// Fetches notifications. Merges real FCM received push notifications with mock data.
  ///
  /// TODO: Remove mock fallback list [_mockNotifications] once backend service is connected.
  Future<List<NotificationItem>> getNotifications({String? userId}) async {
    List<NotificationItem> items = [];

    // Attempt to pull real background/received notifications from PushNotificationService
    try {
      final realPayloads = _pushService.receivedNotifications;
      if (realPayloads.isNotEmpty) {
        items.addAll(realPayloads.map(NotificationItem.fromPushPayload));
      }
    } catch (_) {}

    // TODO: Remove this mock merge logic when production API endpoint is active
    for (final mockItem in _mockNotifications) {
      if (!items.any((item) => item.id == mockItem.id)) {
        items.add(mockItem);
      }
    }

    // Sort newest first
    items.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return items;
  }
}
