import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../design_system/components/card/ds_card.dart';
import '../../../design_system/components/snackbar/ds_snackbar.dart';
import '../data/repositories/notification_repository.dart';
import '../domain/models/notification_item.dart';
import 'notification_settings_screen.dart';

/// Notifications Screen displaying all app notifications.
///
/// TODO: Remove mock notifications data source and replace with live backend API sync.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationRepository _repository = NotificationRepository();

  List<NotificationItem> _notifications = [];
  bool _isLoading = true;
  bool _showMockBanner = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    final items = await _repository.getNotifications();
    if (mounted) {
      setState(() {
        _notifications = items;
        _isLoading = false;
      });
    }
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  void _markAsRead(String id) {
    setState(() {
      _notifications = _notifications.map((n) {
        if (n.id == id) {
          return n.copyWith(isRead: true);
        }
        return n;
      }).toList();
    });
  }

  void _toggleReadStatus(String id) {
    setState(() {
      _notifications = _notifications.map((n) {
        if (n.id == id) {
          return n.copyWith(isRead: !n.isRead);
        }
        return n;
      }).toList();
    });
  }

  void _markAllAsRead() {
    if (_unreadCount == 0) return;
    setState(() {
      _notifications =
          _notifications.map((n) => n.copyWith(isRead: true)).toList();
    });
    DSSnackbar.show(
      context,
      message: 'All notifications marked as read',
      variant: DSSnackbarVariant.success,
    );
  }

  void _deleteNotification(NotificationItem item) {
    final index = _notifications.indexWhere((n) => n.id == item.id);
    if (index == -1) return;

    setState(() {
      _notifications.removeAt(index);
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Notification deleted'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Undo',
          textColor: AppColors.primary,
          onPressed: () {
            setState(() {
              _notifications.insert(index, item);
            });
          },
        ),
      ),
    );
  }

  void _clearAll() {
    if (_notifications.isEmpty) return;

    final backup = List<NotificationItem>.from(_notifications);

    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear All Notifications'),
        content: const Text(
          'Are you sure you want to remove all notifications from your inbox?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Clear All'),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true && mounted) {
        setState(() {
          _notifications.clear();
        });

        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('All notifications cleared'),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Undo',
              textColor: AppColors.primary,
              onPressed: () {
                setState(() {
                  _notifications = backup;
                });
              },
            ),
          ),
        );
      }
    });
  }

  void _showNotificationDetailModal(NotificationItem item) {
    _markAsRead(item.id);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtextColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                  child: const Icon(
                    Icons.notifications_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _formatTimestamp(item.timestamp, full: true),
                    style: TextStyle(fontSize: 12, color: subtextColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              item.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.message,
              style: TextStyle(
                fontSize: 14,
                height: 1.35,
                color: textColor.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _toggleReadStatus(item.id);
                    },
                    icon: Icon(
                      item.isRead
                          ? Icons.mark_email_unread_outlined
                          : Icons.mark_email_read_outlined,
                      size: 16,
                    ),
                    label: Text(
                      item.isRead ? 'Mark Unread' : 'Mark Read',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.check_circle_outline, size: 16),
                    label: const Text('Done', style: TextStyle(fontSize: 13)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime dateTime, {bool full = false}) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (full) {
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} at $hour:$minute';
    }

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        title: Row(
          children: [
            Text(
              'Notifications',
              style: TextStyle(
                color: textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            if (_unreadCount > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$_unreadCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        iconTheme: IconThemeData(color: textPrimary),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_rounded, color: textPrimary, size: 22),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (value) {
              if (value == 'read_all') {
                _markAllAsRead();
              } else if (value == 'clear_all') {
                _clearAll();
              }
            },
            itemBuilder: (ctx) => [
              PopupMenuItem(
                value: 'read_all',
                enabled: _unreadCount > 0,
                child: Row(
                  children: const [
                    Icon(Icons.done_all_rounded, size: 16),
                    SizedBox(width: 8),
                    Text('Mark all as read', style: TextStyle(fontSize: 13)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'clear_all',
                enabled: _notifications.isNotEmpty,
                child: Row(
                  children: const [
                    Icon(Icons.delete_sweep_outlined,
                        size: 16, color: AppColors.danger),
                    SizedBox(width: 8),
                    Text('Clear all',
                        style: TextStyle(color: AppColors.danger, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.settings_outlined, color: textPrimary, size: 22),
            tooltip: 'Notification Settings',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificationSettingsScreen(),
                ),
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          // TODO: Remove this mock notification banner when live backend API is connected
          if (_showMockBanner) _buildMockDataBanner(isDark),

          // Notification Cards List or Empty View
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : _notifications.isEmpty
                    ? _buildEmptyState(isDark)
                    : RefreshIndicator(
                        onRefresh: _loadNotifications,
                        color: AppColors.primary,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          itemCount: _notifications.length,
                          separatorBuilder: (ctx, index) =>
                              const SizedBox(height: 8),
                          itemBuilder: (ctx, index) {
                            final item = _notifications[index];
                            return _buildNotificationCard(item, isDark);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  /// Banner explaining mock notification data status.
  /// TODO: Remove mock banner widget when backend notifications integration is finished.
  Widget _buildMockDataBanner(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.primary.withValues(alpha: 0.12)
            : AppColors.primaryLight.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded,
              color: AppColors.primary, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Mock notifications mode. Connect to backend service when ready.',
              style: TextStyle(
                fontSize: 11.5,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _showMockBanner = false),
            child: Icon(
              Icons.close_rounded,
              size: 16,
              color: isDark ? Colors.white60 : Colors.black45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(NotificationItem item, bool isDark) {
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textPrimary = isDark ? Colors.white : Colors.black87;
    final textSecondary =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: AppColors.danger,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            SizedBox(width: 6),
            Icon(Icons.delete_outline_rounded, color: Colors.white, size: 18),
          ],
        ),
      ),
      onDismissed: (_) => _deleteNotification(item),
      child: DSCard(
        variant: DSCardVariant.elevated,
        onTap: () => _showNotificationDetailModal(item),
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Bell Icon
            Stack(
              children: [
                CircleAvatar(
                  radius: 17,
                  backgroundColor: item.isRead
                      ? (isDark ? Colors.white10 : Colors.grey.shade100)
                      : AppColors.primary.withValues(alpha: 0.15),
                  child: Icon(
                    item.isRead
                        ? Icons.notifications_none_rounded
                        : Icons.notifications_active_rounded,
                    color: item.isRead
                        ? textSecondary
                        : AppColors.primary,
                    size: 18,
                  ),
                ),
                if (!item.isRead)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: cardColor,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 10),

            // Title, Message, & Time
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: item.isRead
                                ? FontWeight.w600
                                : FontWeight.bold,
                            color: textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _formatTimestamp(item.timestamp),
                        style: TextStyle(
                          fontSize: 11,
                          color: textSecondary,
                          fontWeight: item.isRead
                              ? FontWeight.normal
                              : FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.message,
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.25,
                      color: textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtextColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E293B)
                    : AppColors.primaryLight.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_off_outlined,
                size: 44,
                color: isDark ? const Color(0xFF64748B) : AppColors.primary,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'No notifications yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'You\'re all caught up! New updates, AI feedback, and reminders will appear here.',
              style: TextStyle(
                fontSize: 13,
                color: subtextColor,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _loadNotifications,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Reload', style: TextStyle(fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }
}
