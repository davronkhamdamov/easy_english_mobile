import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// Reusable auth header component displaying icon, bold title, and description.
class DSAuthHeader extends StatelessWidget {
  final Widget? icon;
  final IconData? iconData;
  final Color? iconColor;
  final double iconSize;
  final String title;
  final String subtitle;
  final TextAlign textAlign;

  const DSAuthHeader({
    super.key,
    this.icon,
    this.iconData = Icons.headphones_outlined,
    this.iconColor,
    this.iconSize = 32.0,
    required this.title,
    required this.subtitle,
    this.textAlign = TextAlign.center,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveIconColor =
        iconColor ??
        (isDark ? AppColors.accentGreen : AppColors.accentGreenDark);

    Widget headerIcon =
        icon ??
        (iconData != null
            ? Icon(iconData, size: iconSize, color: effectiveIconColor)
            : const SizedBox.shrink());

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        headerIcon,
        AppSpacing.gapVerticalMd,
        Text(
          title,
          textAlign: textAlign,
          style: AppTypography.h3.copyWith(
            fontWeight: FontWeight.w700,
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
            letterSpacing: -0.3,
          ),
        ),
        AppSpacing.gapVerticalSm,
        Text(
          subtitle,
          textAlign: textAlign,
          style: AppTypography.bodyMd.copyWith(
            color: isDark
                ? AppColors.darkTextMuted
                : AppColors.lightTextSecondary,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}
