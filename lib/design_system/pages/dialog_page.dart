import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';
import '../components/button/ds_button.dart';
import '../components/card/ds_card.dart';
import '../components/dialog/ds_dialog.dart';
import '../components/snackbar/ds_snackbar.dart';
import 'component_page_wrapper.dart';

class DSDialogPage extends StatefulWidget {
  final ThemeController themeController;
  final VoidCallback onBackToOverview;

  const DSDialogPage({
    super.key,
    required this.themeController,
    required this.onBackToOverview,
  });

  @override
  State<DSDialogPage> createState() => _DSDialogPageState();
}

class _DSDialogPageState extends State<DSDialogPage> {
  final String _dialogTitle = 'Confirm Action';
  final String _dialogMessage = 'Are you sure you want to proceed with this operation? This action cannot be undone.';

  @override
  Widget build(BuildContext context) {
    final isDark = widget.themeController.isDarkMode;

    return ComponentPageWrapper(
      title: 'DSDialog Modal Investigation',
      category: 'Design System / Overlays & Dialogs',
      description: 'Comprehensive investigation page for DSDialog. Test backdrop blur glassmorphism modal, spring scale transitions, and action buttons.',
      themeController: widget.themeController,
      onBackToOverview: widget.onBackToOverview,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section 1: Modal Launcher Playground
          Text(
            '1. Interactive Modal Launcher',
            style: AppTypography.h2.copyWith(
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          AppSpacing.gapVerticalMd,
          DSCard(
            variant: DSCardVariant.elevated,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: DSButton(
                    text: 'Launch Glassmorphic Modal',
                    variant: DSButtonVariant.primary,
                    leftIcon: const Icon(Icons.open_in_new_rounded),
                    onPressed: () {
                      DSDialog.show(
                        context: context,
                        icon: Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: const BoxDecoration(
                            color: AppColors.primaryLight,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.help_outline_rounded, color: AppColors.primary, size: 32),
                        ),
                        title: _dialogTitle,
                        message: _dialogMessage,
                        confirmText: 'Confirm',
                        cancelText: 'Cancel',
                        onConfirm: () {
                          DSSnackbar.show(
                            context,
                            title: 'Confirmed',
                            message: 'User confirmed modal dialog choice.',
                            variant: DSSnackbarVariant.success,
                          );
                        },
                        onCancel: () {
                          DSSnackbar.show(
                            context,
                            title: 'Cancelled',
                            message: 'User cancelled modal dialog.',
                            variant: DSSnackbarVariant.info,
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.gapVerticalXl,

          // Section 2: In-Page Card Preview of DSDialog
          Text(
            '2. In-Page Static Render Preview',
            style: AppTypography.h2.copyWith(
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          AppSpacing.gapVerticalMd,
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              child: DSDialog(
                title: 'Static Preview Title',
                message: 'This is how DSDialog appears when rendered in-page with backdrop blur and custom theme colors.',
                confirmText: 'Action',
                cancelText: 'Dismiss',
                icon: const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 32),
                onConfirm: () {},
                onCancel: () {},
              ),
            ),
          ),
        ],
      ),
    );
  }
}
