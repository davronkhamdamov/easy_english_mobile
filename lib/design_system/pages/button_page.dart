import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';
import '../components/button/ds_button.dart';
import '../components/card/ds_card.dart';
import 'component_page_wrapper.dart';

class DSButtonPage extends StatefulWidget {
  final ThemeController themeController;
  final VoidCallback onBackToOverview;

  const DSButtonPage({
    super.key,
    required this.themeController,
    required this.onBackToOverview,
  });

  @override
  State<DSButtonPage> createState() => _DSButtonPageState();
}

class _DSButtonPageState extends State<DSButtonPage> {
  DSButtonVariant _selectedVariant = DSButtonVariant.primary;
  DSButtonSize _selectedSize = DSButtonSize.md;
  bool _isLoading = false;
  bool _isDisabled = false;
  bool _showIcon = false;
  final String _buttonText = 'Interactive Button';

  @override
  Widget build(BuildContext context) {
    final isDark = widget.themeController.isDarkMode;

    return ComponentPageWrapper(
      title: 'DSButton Investigation',
      category: 'Design System / Components',
      description: 'Comprehensive investigation page for DSButton. Explore 5 variants, 3 sizes, loading spinners, disabled states, and hover/press micro-animations.',
      themeController: widget.themeController,
      onBackToOverview: widget.onBackToOverview,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section 1: Interactive Playground
          Text(
            '1. Interactive Component Playground',
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
                // Live Interactive Button Display Area
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: Center(
                    child: DSButton(
                      text: _buttonText,
                      variant: _selectedVariant,
                      size: _selectedSize,
                      isLoading: _isLoading,
                      disabled: _isDisabled,
                      leftIcon: _showIcon ? const Icon(Icons.flash_on_rounded) : null,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Playground button clicked!')),
                        );
                      },
                    ),
                  ),
                ),
                AppSpacing.gapVerticalLg,
                // Controls Matrix
                Wrap(
                  spacing: AppSpacing.lg,
                  runSpacing: AppSpacing.md,
                  children: [
                    // Variant Selector
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Variant:', style: AppTypography.label),
                        AppSpacing.gapVerticalXs,
                        DropdownButton<DSButtonVariant>(
                          value: _selectedVariant,
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedVariant = val);
                          },
                          items: DSButtonVariant.values.map((v) {
                            return DropdownMenuItem(
                              value: v,
                              child: Text(v.name.toUpperCase()),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    // Size Selector
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Size:', style: AppTypography.label),
                        AppSpacing.gapVerticalXs,
                        DropdownButton<DSButtonSize>(
                          value: _selectedSize,
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedSize = val);
                          },
                          items: DSButtonSize.values.map((s) {
                            return DropdownMenuItem(
                              value: s,
                              child: Text(s.name.toUpperCase()),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    // Toggle Chips
                    FilterChip(
                      label: const Text('Is Loading'),
                      selected: _isLoading,
                      onSelected: (val) => setState(() => _isLoading = val),
                    ),
                    FilterChip(
                      label: const Text('Is Disabled'),
                      selected: _isDisabled,
                      onSelected: (val) => setState(() => _isDisabled = val),
                    ),
                    FilterChip(
                      label: const Text('With Icon'),
                      selected: _showIcon,
                      onSelected: (val) => setState(() => _showIcon = val),
                    ),
                  ],
                ),
              ],
            ),
          ),
          AppSpacing.gapVerticalXl,

          // Section 2: Complete Variant Matrix
          Text(
            '2. Variant & Size Matrix Overview',
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
              crossAxisAlignment: WrapCrossAlignment.center,
              children: DSButtonVariant.values.map((variant) {
                return DSButton(
                  text: variant.name.toUpperCase(),
                  variant: variant,
                  onPressed: () {},
                );
              }).toList(),
            ),
          ),
          AppSpacing.gapVerticalXl,

          // Section 3: Generated Code Snippet
          Text(
            '3. Code Usage Snippet',
            style: AppTypography.h2.copyWith(
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          AppSpacing.gapVerticalMd,
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Text(
              'DSButton(\n'
              '  text: "$_buttonText",\n'
              '  variant: DSButtonVariant.${_selectedVariant.name},\n'
              '  size: DSButtonSize.${_selectedSize.name},\n'
              '  isLoading: $_isLoading,\n'
              '  disabled: $_isDisabled,\n'
              '  leftIcon: ${_showIcon ? "Icon(Icons.flash_on_rounded)" : "null"},\n'
              '  onPressed: () { ... },\n'
              ')',
              style: AppTypography.code,
            ),
          ),
        ],
      ),
    );
  }
}
