import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';
import '../components/card/ds_card.dart';
import '../components/input/ds_input.dart';
import 'component_page_wrapper.dart';

class DSInputPage extends StatefulWidget {
  final ThemeController themeController;
  final VoidCallback onBackToOverview;

  const DSInputPage({
    super.key,
    required this.themeController,
    required this.onBackToOverview,
  });

  @override
  State<DSInputPage> createState() => _DSInputPageState();
}

class _DSInputPageState extends State<DSInputPage> {
  DSInputType _selectedType = DSInputType.text;
  bool _isDisabled = false;
  bool _hasError = false;
  bool _hasHelperText = true;

  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.themeController.isDarkMode;

    return ComponentPageWrapper(
      title: 'DSInput Investigation',
      category: 'Design System / Form Inputs',
      description: 'Comprehensive investigation page for DSInput. Preview text, email, password with toggle eye, and search with clear button variants.',
      themeController: widget.themeController,
      onBackToOverview: widget.onBackToOverview,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Playground Section
          Text(
            '1. Interactive Input Playground',
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
                DSInput(
                  label: 'Interactive Field Label',
                  placeholder: 'Type something here...',
                  type: _selectedType,
                  controller: _controller,
                  disabled: _isDisabled,
                  helperText: _hasHelperText ? 'Helpful tip or formatting instruction' : null,
                  errorText: _hasError ? 'Invalid value provided in input field' : null,
                ),
                AppSpacing.gapVerticalLg,
                Wrap(
                  spacing: AppSpacing.lg,
                  runSpacing: AppSpacing.md,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Input Type:', style: AppTypography.label),
                        AppSpacing.gapVerticalXs,
                        DropdownButton<DSInputType>(
                          value: _selectedType,
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedType = val);
                          },
                          items: DSInputType.values.map((t) {
                            return DropdownMenuItem(
                              value: t,
                              child: Text(t.name.toUpperCase()),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    FilterChip(
                      label: const Text('Show Error'),
                      selected: _hasError,
                      onSelected: (val) => setState(() => _hasError = val),
                    ),
                    FilterChip(
                      label: const Text('Helper Text'),
                      selected: _hasHelperText,
                      onSelected: (val) => setState(() => _hasHelperText = val),
                    ),
                    FilterChip(
                      label: const Text('Disabled'),
                      selected: _isDisabled,
                      onSelected: (val) => setState(() => _isDisabled = val),
                    ),
                  ],
                ),
              ],
            ),
          ),
          AppSpacing.gapVerticalXl,

          // All Types Matrix
          Text(
            '2. Input Type Variants Matrix',
            style: AppTypography.h2.copyWith(
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          AppSpacing.gapVerticalMd,
          DSCard(
            variant: DSCardVariant.outlined,
            child: Column(
              children: [
                const DSInput(
                  label: 'Text Field',
                  placeholder: 'Standard text input',
                  type: DSInputType.text,
                ),
                AppSpacing.gapVerticalMd,
                const DSInput(
                  label: 'Email Field',
                  placeholder: 'student@example.com',
                  type: DSInputType.email,
                ),
                AppSpacing.gapVerticalMd,
                const DSInput(
                  label: 'Password Field (with eye toggle)',
                  placeholder: '••••••••••••',
                  type: DSInputType.password,
                ),
                AppSpacing.gapVerticalMd,
                const DSInput(
                  label: 'Search Field (with clear button)',
                  placeholder: 'Search topics...',
                  type: DSInputType.search,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
