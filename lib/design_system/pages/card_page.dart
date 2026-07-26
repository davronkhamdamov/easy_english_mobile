import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';
import '../components/card/ds_card.dart';
import 'component_page_wrapper.dart';

class DSCardPage extends StatefulWidget {
  final ThemeController themeController;
  final VoidCallback onBackToOverview;

  const DSCardPage({
    super.key,
    required this.themeController,
    required this.onBackToOverview,
  });

  @override
  State<DSCardPage> createState() => _DSCardPageState();
}

class _DSCardPageState extends State<DSCardPage> {
  DSCardVariant _selectedVariant = DSCardVariant.elevated;
  bool _hasHeader = true;
  bool _hasFooter = true;
  bool _isClickable = true;

  @override
  Widget build(BuildContext context) {
    final isDark = widget.themeController.isDarkMode;

    return ComponentPageWrapper(
      title: 'DSCard Investigation',
      category: 'Design System / Layout & Containers',
      description: 'Comprehensive investigation page for DSCard. Explore elevated, outlined, and real-time glassmorphism backdrop blur variants.',
      themeController: widget.themeController,
      onBackToOverview: widget.onBackToOverview,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Playground Section
          Text(
            '1. Interactive Card Playground',
            style: AppTypography.h2.copyWith(
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          AppSpacing.gapVerticalMd,
          DSCard(
            variant: _selectedVariant,
            onTap: _isClickable
                ? () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Card tapped!')),
                    );
                  }
                : null,
            header: _hasHeader
                ? Row(
                    children: [
                      const Icon(Icons.dashboard_rounded, color: AppColors.primary),
                      AppSpacing.gapHorizontalSm,
                      Text(
                        'Card Title Header',
                        style: AppTypography.h3.copyWith(
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                    ],
                  )
                : null,
            body: Text(
              'This is the main body text inside the DSCard. It supports flexible custom children, smooth micro-animation hover/tap states, and dark mode theme switching.',
              style: AppTypography.bodyMd.copyWith(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            footer: _hasFooter
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {},
                        child: const Text('Action 1'),
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        child: const Text('Action 2'),
                      ),
                    ],
                  )
                : null,
          ),
          AppSpacing.gapVerticalLg,
          Wrap(
            spacing: AppSpacing.lg,
            runSpacing: AppSpacing.md,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Card Variant:', style: AppTypography.label),
                  AppSpacing.gapVerticalXs,
                  DropdownButton<DSCardVariant>(
                    value: _selectedVariant,
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedVariant = val);
                    },
                    items: DSCardVariant.values.map((v) {
                      return DropdownMenuItem(
                        value: v,
                        child: Text(v.name.toUpperCase()),
                      );
                    }).toList(),
                  ),
                ],
              ),
              FilterChip(
                label: const Text('Include Header'),
                selected: _hasHeader,
                onSelected: (val) => setState(() => _hasHeader = val),
              ),
              FilterChip(
                label: const Text('Include Footer'),
                selected: _hasFooter,
                onSelected: (val) => setState(() => _hasFooter = val),
              ),
              FilterChip(
                label: const Text('Clickable (Tap Animation)'),
                selected: _isClickable,
                onSelected: (val) => setState(() => _isClickable = val),
              ),
            ],
          ),
          AppSpacing.gapVerticalXl,

          // Glassmorphism Highlight Section
          Text(
            '2. Glassmorphism Blur Showcase',
            style: AppTypography.h2.copyWith(
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          AppSpacing.gapVerticalMd,
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFFA855F7), Color(0xFFEC4899)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            ),
            child: DSCard(
              variant: DSCardVariant.glass,
              header: Text(
                'Glassmorphic Backdrop Blur',
                style: AppTypography.h2.copyWith(color: Colors.white),
              ),
              body: Text(
                'Renders real-time ImageFilter.blur over colorful dynamic background gradients.',
                style: AppTypography.bodyMd.copyWith(color: Colors.white70),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
