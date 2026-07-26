import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';
import '../components/badge/ds_badge.dart';
import '../components/card/ds_card.dart';
import 'component_page_wrapper.dart';

class DSBadgePage extends StatefulWidget {
  final ThemeController themeController;
  final VoidCallback onBackToOverview;

  const DSBadgePage({
    super.key,
    required this.themeController,
    required this.onBackToOverview,
  });

  @override
  State<DSBadgePage> createState() => _DSBadgePageState();
}

class _DSBadgePageState extends State<DSBadgePage> {
  DSBadgeVariant _selectedVariant = DSBadgeVariant.primary;
  bool _isOutlined = false;
  bool _showIcon = true;
  final String _badgeLabel = 'Status Badge';

  @override
  Widget build(BuildContext context) {
    final isDark = widget.themeController.isDarkMode;

    return ComponentPageWrapper(
      title: 'DSBadge Investigation',
      category: 'Design System / Data Display',
      description: 'Comprehensive investigation page for DSBadge. Explore solid status pills, outlined badges, status color variants, and icon integrations.',
      themeController: widget.themeController,
      onBackToOverview: widget.onBackToOverview,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Playground
          Text(
            '1. Interactive Badge Playground',
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
                  child: DSBadge(
                    label: _badgeLabel,
                    variant: _selectedVariant,
                    isOutlined: _isOutlined,
                    icon: _showIcon ? const Icon(Icons.check_circle_rounded) : null,
                  ),
                ),
                AppSpacing.gapVerticalLg,
                Wrap(
                  spacing: AppSpacing.lg,
                  runSpacing: AppSpacing.md,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Variant:', style: AppTypography.label),
                        AppSpacing.gapVerticalXs,
                        DropdownButton<DSBadgeVariant>(
                          value: _selectedVariant,
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedVariant = val);
                          },
                          items: DSBadgeVariant.values.map((v) {
                            return DropdownMenuItem(
                              value: v,
                              child: Text(v.name.toUpperCase()),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    FilterChip(
                      label: const Text('Is Outlined'),
                      selected: _isOutlined,
                      onSelected: (val) => setState(() => _isOutlined = val),
                    ),
                    FilterChip(
                      label: const Text('Show Icon'),
                      selected: _showIcon,
                      onSelected: (val) => setState(() => _showIcon = val),
                    ),
                  ],
                ),
              ],
            ),
          ),
          AppSpacing.gapVerticalXl,

          // Matrix
          Text(
            '2. Badge Variants Matrix',
            style: AppTypography.h2.copyWith(
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          AppSpacing.gapVerticalMd,
          DSCard(
            variant: DSCardVariant.outlined,
            child: Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: DSBadgeVariant.values.map((variant) {
                return DSBadge(
                  label: variant.name.toUpperCase(),
                  variant: variant,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
