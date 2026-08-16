import 'package:flutter/material.dart';
import '../../../../core/notifications/push_notification_service.dart';

enum NotificationCategory {
  all,
  aiCoach,
  studyReminder,
  mockExam,
  streakAlert,
  system;

  String get label {
    switch (this) {
      case NotificationCategory.all:
        return 'All';
      case NotificationCategory.aiCoach:
        return 'AI Coach';
      case NotificationCategory.studyReminder:
        return 'Reminders';
      case NotificationCategory.mockExam:
        return 'Exams';
      case NotificationCategory.streakAlert:
        return 'Streaks';
      case NotificationCategory.system:
        return 'System';
    }
  }

  IconData get icon {
    switch (this) {
      case NotificationCategory.all:
        return Icons.notifications_rounded;
      case NotificationCategory.aiCoach:
        return Icons.psychology_rounded;
      case NotificationCategory.studyReminder:
        return Icons.alarm_on_rounded;
      case NotificationCategory.mockExam:
        return Icons.assignment_rounded;
      case NotificationCategory.streakAlert:
        return Icons.local_fire_department_rounded;
      case NotificationCategory.system:
        return Icons.info_outline_rounded;
    }
  }

  Color get color {
    switch (this) {
      case NotificationCategory.all:
        return const Color(0xFF6366F1);
      case NotificationCategory.aiCoach:
        return const Color(0xFF8B5CF6);
      case NotificationCategory.studyReminder:
        return const Color(0xFF10B981);
      case NotificationCategory.mockExam:
        return const Color(0xFF3B82F6);
      case NotificationCategory.streakAlert:
        return const Color(0xFFF97316);
      case NotificationCategory.system:
        return const Color(0xFF64748B);
    }
  }
}

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final NotificationCategory category;
  final String? actionRoute;
  final Map<String, dynamic>? extraData;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    required this.category,
    this.actionRoute,
    this.extraData,
  });

  NotificationItem copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? timestamp,
    bool? isRead,
    NotificationCategory? category,
    String? actionRoute,
    Map<String, dynamic>? extraData,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      category: category ?? this.category,
      actionRoute: actionRoute ?? this.actionRoute,
      extraData: extraData ?? this.extraData,
    );
  }

  factory NotificationItem.fromPushPayload(PushNotificationPayload payload) {
    return NotificationItem(
      id: payload.id,
      title: payload.title,
      message: payload.body,
      timestamp: payload.receivedAt,
      isRead: payload.isRead,
      category: _inferCategory(payload.title, payload.body),
      extraData: payload.data,
    );
  }

  static NotificationCategory _inferCategory(String title, String body) {
    final text = '$title $body'.toLowerCase();
    if (text.contains('ai') || text.contains('coach') || text.contains('band') || text.contains('score')) {
      return NotificationCategory.aiCoach;
    } else if (text.contains('streak') || text.contains('fire') || text.contains('daily')) {
      return NotificationCategory.streakAlert;
    } else if (text.contains('exam') || text.contains('test') || text.contains('mock')) {
      return NotificationCategory.mockExam;
    } else if (text.contains('remind') || text.contains('study') || text.contains('drill')) {
      return NotificationCategory.studyReminder;
    }
    return NotificationCategory.system;
  }
}
