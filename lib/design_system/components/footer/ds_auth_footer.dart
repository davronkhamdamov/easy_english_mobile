import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// Reusable auth footer component with question prompt and bold action button.
class DSAuthFooter extends StatelessWidget {
  final String promptText;
  final String actionText;
  final VoidCallback? onActionTap;

  const DSAuthFooter({
    super.key,
    this.promptText = 'Already have an account?',
    this.actionText = 'Log in',
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final actionTextColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return GestureDetector(
      onTap: onActionTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: '$promptText ',
            style: AppTypography.bodyMd.copyWith(color: primaryTextColor),
            children: [
              TextSpan(
                text: actionText,
                style: AppTypography.bodyMd.copyWith(
                  fontWeight: FontWeight.w700,
                  color: actionTextColor,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
