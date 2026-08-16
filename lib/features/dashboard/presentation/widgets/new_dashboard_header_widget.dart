import 'package:flutter/material.dart';
import '../../../auth/data/auth_service.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../notification/presentation/notifications_screen.dart';

/// Top header widget for the New Dashboard canvas.
/// Automatically pulls user name and avatar picture from the active Profile session.
class NewDashboardHeaderWidget extends StatelessWidget {
  final String? userName;
  final String? avatarUrl;
  final VoidCallback? onNotificationTap;
  final bool hasUnreadNotifications;

  const NewDashboardHeaderWidget({
    super.key,
    this.userName,
    this.avatarUrl,
    this.onNotificationTap,
    this.hasUnreadNotifications = true,
  });

  void _openNotifications(BuildContext context) {
    if (onNotificationTap != null) {
      onNotificationTap!();
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const NotificationsScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    UserEntity? user;
    try {
      user = AuthService().currentUser;
    } catch (_) {
      user = null;
    }

    final effectiveName = (userName != null && userName!.isNotEmpty)
        ? userName!
        : (user?.displayName != null && user!.displayName.isNotEmpty)
            ? user.displayName
            : (user?.fullName != null && user!.fullName.isNotEmpty)
                ? user.fullName
                : 'Ronald Richards';

    final effectiveAvatarUrl = avatarUrl ?? user?.photoURL ?? user?.avatarUrl;

    Widget avatarWidget;
    if (effectiveAvatarUrl != null && effectiveAvatarUrl.isNotEmpty) {
      avatarWidget = ClipOval(
        child: Image.network(
          effectiveAvatarUrl,
          width: 44,
          height: 44,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => CircleAvatar(
            radius: 22,
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Text(
              effectiveName.isNotEmpty ? effectiveName[0].toUpperCase() : 'R',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ),
      );
    } else {
      avatarWidget = CircleAvatar(
        radius: 22,
        backgroundColor: theme.colorScheme.primaryContainer,
        child: Text(
          effectiveName.isNotEmpty ? effectiveName[0].toUpperCase() : 'R',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
      child: Row(
        children: [
          // Left: User Avatar (Photo from profile session or fallback initial)
          avatarWidget,
          const SizedBox(width: 14),

          // Center: Single-line "Hello, NAME" (nothing below it)
          Expanded(
            child: Text(
              'Hello, $effectiveName',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: -0.3,
                color: theme.colorScheme.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Right: Circular Notification Bell Icon Button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _openNotifications(context),
              customBorder: const CircleBorder(),
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.5,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.notifications_none_rounded,
                      size: 24,
                      color: theme.colorScheme.onSurface,
                    ),
                    if (hasUnreadNotifications)
                      Positioned(
                        top: 11,
                        right: 12,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
