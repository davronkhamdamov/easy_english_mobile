import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

enum DSSnackbarVariant { success, warning, danger, info }

class DSSnackbar {
  static void show(
    BuildContext context, {
    required String message,
    String? title,
    DSSnackbarVariant variant = DSSnackbarVariant.info,
    Duration duration = const Duration(seconds: 4),
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    IconData icon;
    Color iconColor;

    switch (variant) {
      case DSSnackbarVariant.success:
        icon = Icons.check_circle_rounded;
        iconColor = AppColors.success;
        break;
      case DSSnackbarVariant.warning:
        icon = Icons.warning_rounded;
        iconColor = AppColors.warning;
        break;
      case DSSnackbarVariant.danger:
        icon = Icons.error_rounded;
        iconColor = AppColors.danger;
        break;
      case DSSnackbarVariant.info:
        icon = Icons.info_rounded;
        iconColor = AppColors.primary;
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        content: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
            boxShadow: AppShadows.md(isDark),
          ),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 24),
              AppSpacing.gapHorizontalMd,
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title != null) ...[
                      Text(
                        title,
                        style: AppTypography.label.copyWith(
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                    ],
                    Text(
                      message,
                      style: AppTypography.bodySm.copyWith(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
