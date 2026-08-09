import 'package:flutter/material.dart';
import '../../../core/notifications/push_notification_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../design_system/components/card/ds_card.dart';
import '../../../design_system/components/snackbar/ds_snackbar.dart';

class NotificationSettingsScreen extends StatefulWidget {
  final String userId;

  const NotificationSettingsScreen({
    super.key,
    this.userId = 'usr_student_demo',
  });

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  final PushNotificationService _pushService = PushNotificationService();

  @override
  void initState() {
    super.initState();
    _initPush();
  }

  Future<void> _initPush() async {
    await _pushService.initialize(userId: widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        title: Text(
          'Notifications',
          style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notification Channels / Preferences
            Text(
              'Notification Topics',
              style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            DSCard(
              variant: DSCardVariant.outlined,
              child: Column(
                children: [
                  _buildTopicTile(
                    title: 'Daily Study Reminders',
                    subtitle: 'Spaced repetition drills & daily vocabulary practice',
                    icon: Icons.alarm_on_rounded,
                    topicKey: 'study_reminders',
                    color: AppColors.primary,
                  ),
                  const Divider(height: 1),
                  _buildTopicTile(
                    title: 'IELTS AI Tips & Strategy',
                    subtitle: 'Antigravity AI speaking & writing insights',
                    icon: Icons.lightbulb_outline_rounded,
                    topicKey: 'ielts_tips',
                    color: AppColors.secondary,
                  ),
                  const Divider(height: 1),
                  _buildTopicTile(
                    title: 'Mock Exam & Diagnostic Alerts',
                    subtitle: 'Countdown reminders for scheduled practice tests',
                    icon: Icons.timer_rounded,
                    topicKey: 'exam_alerts',
                    color: AppColors.warning,
                  ),
                  const Divider(height: 1),
                  _buildTopicTile(
                    title: 'Daily Streak Safeguard',
                    subtitle: 'Notifications when your streak is about to reset',
                    icon: Icons.local_fire_department_rounded,
                    topicKey: 'daily_streak',
                    color: AppColors.danger,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required String topicKey,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEnabled = _pushService.topicSubscriptions[topicKey] ?? true;

    return Material(
      color: Colors.transparent,
      child: SwitchListTile(
        value: isEnabled,
        onChanged: (value) async {
          await _pushService.toggleTopic(topicKey, value);
          setState(() {});
          if (mounted) {
            DSSnackbar.show(
              context,
              message: value ? 'Subscribed to $title' : 'Unsubscribed from $title',
              variant: DSSnackbarVariant.info,
            );
          }
        },
        secondary: CircleAvatar(
          radius: 18,
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            fontSize: 12,
          ),
        ),
        activeThumbColor: AppColors.primary,
      ),
    );
  }
}
