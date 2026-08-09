import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

enum DSBadgeVariant { primary, success, warning, danger, neutral }

class DSBadge extends StatelessWidget {
  final String label;
  final Widget? icon;
  final DSBadgeVariant variant;
  final bool isOutlined;

  const DSBadge({
    super.key,
    required this.label,
    this.icon,
    this.variant = DSBadgeVariant.primary,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color bg;
    Color fg;
    Color border = Colors.transparent;

    switch (variant) {
      case DSBadgeVariant.primary:
        bg = AppColors.primaryLight;
        fg = AppColors.primary;
        break;
      case DSBadgeVariant.success:
        bg = AppColors.successLight;
        fg = AppColors.success;
        break;
      case DSBadgeVariant.warning:
        bg = AppColors.warningLight;
        fg = AppColors.warning;
        break;
      case DSBadgeVariant.danger:
        bg = AppColors.dangerLight;
        fg = AppColors.danger;
        break;
      case DSBadgeVariant.neutral:
        bg = isDark
            ? AppColors.darkSurfaceVariant
            : AppColors.lightSurfaceVariant;
        fg = isDark
            ? AppColors.darkTextSecondary
            : AppColors.lightTextSecondary;
        break;
    }

    if (isOutlined) {
      border = fg.withValues(alpha: 0.4);
      bg = Colors.transparent;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs - 1,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: border != Colors.transparent
            ? Border.all(color: border, width: 1.2)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            IconTheme(
              data: IconThemeData(size: 12, color: fg),
              child: icon!,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: fg,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
