import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';

/// Single item tile for the Quick Actions grid.
/// Displays a circular icon container styled dynamically using the active color palette,
/// with a clean text label underneath.
class QuickActionItemTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? backgroundColor;
  final Color? borderColor;

  const QuickActionItemTile({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.iconColor,
    this.backgroundColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final palette = ThemeScope.maybeOf(context)?.palette ?? AppColors.currentPalette;

    final primaryAccent = isDark ? palette.darkPrimary : palette.primary;

    final effectiveIconColor = iconColor ?? primaryAccent;
    final effectiveBgColor = backgroundColor ??
        primaryAccent.withValues(alpha: isDark ? 0.16 : 0.08);
    final effectiveBorderColor = borderColor ??
        primaryAccent.withValues(alpha: isDark ? 0.28 : 0.18);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: primaryAccent.withValues(alpha: 0.12),
        highlightColor: primaryAccent.withValues(alpha: 0.06),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: effectiveBgColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: effectiveBorderColor,
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (isDark ? Colors.black : primaryAccent).withValues(
                        alpha: isDark ? 0.25 : 0.06,
                      ),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: effectiveIconColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
