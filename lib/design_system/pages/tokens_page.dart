import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';
import '../components/card/ds_card.dart';
import 'component_page_wrapper.dart';

class DSTokensPage extends StatelessWidget {
  final ThemeController themeController;
  final VoidCallback onBackToOverview;

  const DSTokensPage({
    super.key,
    required this.themeController,
    required this.onBackToOverview,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = themeController.isDarkMode;

    return ComponentPageWrapper(
      title: 'Design Tokens Foundation',
      category: 'Design System / Tokens',
      description: 'Comprehensive investigation page for design tokens: Color palette, typography scale, spacing tokens, and shadow definitions.',
      themeController: themeController,
      onBackToOverview: onBackToOverview,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section 1: Colors
          Text(
            '1. Color Palette Tokens',
            style: AppTypography.h2.copyWith(
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          AppSpacing.gapVerticalMd,
          DSCard(
            variant: DSCardVariant.elevated,
            child: Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: [
                _buildColorBox('Primary', AppColors.primary),
                _buildColorBox('Primary Hover', AppColors.primaryHover),
                _buildColorBox('Primary Light', AppColors.primaryLight),
                _buildColorBox('Secondary', AppColors.secondary),
                _buildColorBox('Success', AppColors.success),
                _buildColorBox('Warning', AppColors.warning),
                _buildColorBox('Danger', AppColors.danger),
              ],
            ),
          ),
          AppSpacing.gapVerticalXl,

          // Section 2: Typography
          Text(
            '2. Typography Scale',
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
                _buildTypeRow('Display Title', '32px / Bold', AppTypography.display, isDark),
                const Divider(),
                _buildTypeRow('H1 Header', '24px / W700', AppTypography.h1, isDark),
                const Divider(),
                _buildTypeRow('H2 Header', '20px / W600', AppTypography.h2, isDark),
                const Divider(),
                _buildTypeRow('H3 Header', '18px / W600', AppTypography.h3, isDark),
                const Divider(),
                _buildTypeRow('Body Large', '18px / Regular', AppTypography.bodyLg, isDark),
                const Divider(),
                _buildTypeRow('Body Medium', '16px / Regular', AppTypography.bodyMd, isDark),
                const Divider(),
                _buildTypeRow('Body Small', '14px / Regular', AppTypography.bodySm, isDark),
                const Divider(),
                _buildTypeRow('Caption Text', '12px / Medium', AppTypography.caption, isDark),
                const Divider(),
                _buildTypeRow('Code Snippet', '14px / Monospace', AppTypography.code, isDark),
              ],
            ),
          ),
          AppSpacing.gapVerticalXl,

          // Section 3: Spacing Tokens
          Text(
            '3. Spacing Scale Tokens',
            style: AppTypography.h2.copyWith(
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          AppSpacing.gapVerticalMd,
          DSCard(
            variant: DSCardVariant.outlined,
            child: Wrap(
              spacing: AppSpacing.lg,
              runSpacing: AppSpacing.md,
              children: [
                _buildSpacingItem('xs', AppSpacing.xs),
                _buildSpacingItem('sm', AppSpacing.sm),
                _buildSpacingItem('md', AppSpacing.md),
                _buildSpacingItem('lg', AppSpacing.lg),
                _buildSpacingItem('xl', AppSpacing.xl),
                _buildSpacingItem('xxl', AppSpacing.xxl),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorBox(String name, Color color) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: AppTypography.caption.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}',
            style: AppTypography.caption.copyWith(
              color: Colors.white70,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeRow(String name, String meta, TextStyle style, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTypography.label.copyWith(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                Text(
                  meta,
                  style: AppTypography.caption.copyWith(
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Text(
              'Sample Text Preview',
              style: style.copyWith(
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpacingItem(String label, double value) {
    return Column(
      children: [
        Container(
          width: value * 2,
          height: value * 2,
          color: AppColors.primary,
        ),
        AppSpacing.gapVerticalXs,
        Text('$label (${value.toInt()}px)', style: AppTypography.caption),
      ],
    );
  }
}
