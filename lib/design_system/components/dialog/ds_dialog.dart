import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../button/ds_button.dart';

class DSDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? confirmText;
  final String? cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final Widget? icon;

  const DSDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    this.onConfirm,
    this.onCancel,
    this.icon,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required String message,
    String? confirmText = 'Confirm',
    String? cancelText = 'Cancel',
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    Widget? icon,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss Dialog',
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, anim1, anim2) => DSDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: onConfirm,
        onCancel: onCancel,
        icon: icon,
      ),
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: Curves.easeOutBack.transform(anim1.value),
          child: FadeTransition(opacity: anim1, child: child),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkGlassBackground
                    : AppColors.lightGlassBackground,
                borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                border: Border.all(
                  color: isDark
                      ? AppColors.darkGlassBorder
                      : AppColors.lightGlassBorder,
                  width: 1.5,
                ),
                boxShadow: AppShadows.lg(isDark),
              ),
              child: Material(
                color: Colors.transparent,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[icon!, AppSpacing.gapVerticalMd],
                    Text(
                      title,
                      style: AppTypography.h2.copyWith(
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    AppSpacing.gapVerticalSm,
                    Text(
                      message,
                      style: AppTypography.bodyMd.copyWith(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    AppSpacing.gapVerticalLg,
                    Row(
                      children: [
                        if (cancelText != null)
                          Expanded(
                            child: DSButton(
                              text: cancelText!,
                              variant: DSButtonVariant.outline,
                              onPressed: () {
                                Navigator.of(context).pop();
                                onCancel?.call();
                              },
                            ),
                          ),
                        if (cancelText != null && confirmText != null)
                          AppSpacing.gapHorizontalMd,
                        if (confirmText != null)
                          Expanded(
                            child: DSButton(
                              text: confirmText!,
                              variant: DSButtonVariant.primary,
                              onPressed: () {
                                Navigator.of(context).pop();
                                onConfirm?.call();
                              },
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
