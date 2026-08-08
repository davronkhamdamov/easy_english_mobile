import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/notifications/push_notification_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../design_system/components/badge/ds_badge.dart';
import '../../../design_system/components/button/ds_button.dart';
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
  final TextEditingController _titleController = TextEditingController(text: '🎯 Daily IELTS Practice Ready!');
  final TextEditingController _bodyController = TextEditingController(
    text: 'Your speaking score forecast updated to Band 7.5. Tap to complete today\'s 5-min drill!',
  );

  bool _isSending = false;
  bool _isLoadingHistory = false;
  List<PushNotificationPayload> _history = [];

  @override
  void initState() {
    super.initState();
    _initPush();
  }

  Future<void> _initPush() async {
    await _pushService.initialize(userId: widget.userId);
    _loadHistory();

    _pushService.onNotificationReceived.listen((payload) {
      if (mounted) {
        setState(() {
          _history = _pushService.receivedNotifications;
        });
        DSSnackbar.show(
          context,
          message: '🔔 Push Received: ${payload.title}',
          variant: DSSnackbarVariant.success,
        );
      }
    });
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoadingHistory = true;
    });
    final items = await _pushService.fetchNotificationHistory(widget.userId);
    if (mounted) {
      setState(() {
        _history = items;
        _isLoadingHistory = false;
      });
    }
  }

  Future<void> _sendTestNotification() async {
    if (_titleController.text.trim().isEmpty || _bodyController.text.trim().isEmpty) {
      DSSnackbar.show(
        context,
        message: 'Please enter both a title and body for the push test.',
        variant: DSSnackbarVariant.warning,
      );
      return;
    }

    setState(() {
      _isSending = true;
    });

    final success = await _pushService.sendTestPushNotification(
      userId: widget.userId,
      title: _titleController.text.trim(),
      body: _bodyController.text.trim(),
      data: {'type': 'test_push', 'screen': 'dashboard'},
    );

    if (mounted) {
      setState(() {
        _isSending = false;
        _history = _pushService.receivedNotifications;
      });

      if (success) {
        DSSnackbar.show(
          context,
          message: 'Push notification queued & delivered successfully!',
          variant: DSSnackbarVariant.success,
        );
      } else {
        DSSnackbar.show(
          context,
          message: 'Failed to enqueue push notification with backend gateway.',
          variant: DSSnackbarVariant.danger,
        );
      }
    }
  }

  void _copyToken() {
    final token = _pushService.fcmToken ?? 'fcm_none';
    Clipboard.setData(ClipboardData(text: token));
    DSSnackbar.show(
      context,
      message: 'FCM Device Token copied to clipboard!',
      variant: DSSnackbarVariant.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final token = _pushService.fcmToken;
    final truncatedToken = token != null && token.length > 24
        ? '${token.substring(0, 12)}...${token.substring(token.length - 12)}'
        : token ?? 'Generating FCM token...';

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        title: Text(
          'Push Notifications',
          style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        iconTheme: IconThemeData(color: textPrimary),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Notifications',
            onPressed: _loadHistory,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Device Token & Connection Status Card
            DSCard(
              variant: DSCardVariant.glass,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.notifications_active_rounded, color: AppColors.primary, size: 24),
                            const SizedBox(width: 8),
                            Text(
                              'Push Notification Gateway',
                              style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),
                        const DSBadge(
                          label: 'FCM Active',
                          variant: DSBadgeVariant.success,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Target Device Token:',
                      style: TextStyle(color: textSecondary, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              truncatedToken,
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                                color: textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy_rounded, size: 18, color: AppColors.primary),
                            onPressed: _copyToken,
                            tooltip: 'Copy FCM Token',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 2. Notification Channels / Preferences
            Text(
              'Notification Channels & Topics',
              style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
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
            const SizedBox(height: 24),

            // 3. Test Push Notification Playground
            Text(
              'Send Test Push Notification',
              style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            DSCard(
              variant: DSCardVariant.elevated,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Push Title',
                      style: TextStyle(color: textSecondary, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _titleController,
                      style: TextStyle(color: textPrimary),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Push Body Message',
                      style: TextStyle(color: textSecondary, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _bodyController,
                      maxLines: 2,
                      style: TextStyle(color: textPrimary),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: DSButton(
                        text: 'Trigger Go Gateway Push',
                        leftIcon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                        variant: DSButtonVariant.primary,
                        isLoading: _isSending,
                        onPressed: _sendTestNotification,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 4. Live Notification History Feed
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Received Notifications (${_history.length})',
                  style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                if (_history.isNotEmpty)
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _pushService.clearHistory();
                        _history = [];
                      });
                      DSSnackbar.show(
                        context,
                        message: 'Notification history cleared',
                        variant: DSSnackbarVariant.info,
                      );
                    },
                    icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.danger),
                    label: const Text('Clear', style: TextStyle(color: AppColors.danger)),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            if (_isLoadingHistory)
              const Center(child: CircularProgressIndicator())
            else if (_history.isEmpty)
              DSCard(
                variant: DSCardVariant.outlined,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.notifications_none_rounded, size: 40, color: textSecondary.withOpacity(0.5)),
                        const SizedBox(height: 8),
                        Text(
                          'No push notifications received yet.',
                          style: TextStyle(color: textSecondary, fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Use the test trigger above to send your first push notification.',
                          style: TextStyle(color: textSecondary.withOpacity(0.7), fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _history.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = _history[index];
                  return DSCard(
                    variant: DSCardVariant.elevated,
                    child: Material(
                      color: Colors.transparent,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary.withOpacity(0.15),
                          child: const Icon(Icons.notifications_active_rounded, color: AppColors.primary, size: 20),
                        ),
                        title: Text(
                          item.title,
                          style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              item.body,
                              style: TextStyle(color: textSecondary, fontSize: 13),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${item.receivedAt.hour.toString().padLeft(2, '0')}:${item.receivedAt.minute.toString().padLeft(2, '0')} • ${_formatTimeAgo(item.receivedAt)}',
                              style: TextStyle(color: textSecondary.withOpacity(0.6), fontSize: 11),
                            ),
                          ],
                        ),
                        trailing: const DSBadge(
                          label: 'Delivered',
                          variant: DSBadgeVariant.success,
                        ),
                      ),
                    ),
                  );
                },
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
          backgroundColor: color.withOpacity(0.15),
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
        activeColor: AppColors.primary,
      ),
    );
  }

  String _formatTimeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
