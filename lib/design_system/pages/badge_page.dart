import 'package:flutter/material.dart';
import '../design_system.dart';

class DSBadgePage extends StatefulWidget {
  final ThemeController themeController;
  final VoidCallback? onBackToOverview;

  const DSBadgePage({
    super.key,
    required this.themeController,
    this.onBackToOverview,
  });

  @override
  State<DSBadgePage> createState() => _DSBadgePageState();
}

class _DSBadgePageState extends State<DSBadgePage> {
  // Playground State
  String _badgeLabel = 'Completed';
  DSBadgeVariant _selectedVariant = DSBadgeVariant.success;
  bool _isOutlined = false;
  int _selectedIconIndex = 1; // 0: None, 1: Check, 2: Star, 3: Warning, 4: Flame, 5: Lock

  IconData? _getIconData() {
    switch (_selectedIconIndex) {
      case 1:
        return Icons.check_circle_rounded;
      case 2:
        return Icons.star_rounded;
      case 3:
        return Icons.warning_amber_rounded;
      case 4:
        return Icons.local_fire_department_rounded;
      case 5:
        return Icons.lock_outline_rounded;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ComponentPageWrapper(
      title: 'DSBadge',
      subtitle: 'Compact status pill badge component with solid & outlined variants across 5 color tokens',
      category: 'Components',
      themeController: widget.themeController,
      onBackToOverview: widget.onBackToOverview,
      playground: _buildPlayground(context),
      matrix: _buildMatrix(context),
      codeSnippet: _buildCodeSnippet(context),
      specs: _buildSpecs(context),
    );
  }

  // --- 1. PLAYGROUND ---
  Widget _buildPlayground(BuildContext context) {
    final isDark = widget.themeController.isDarkMode;
    final iconData = _getIconData();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Canvas Container
        DSCard(
          variant: DSCardVariant.elevated,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Live Badge Preview', style: AppTypography.h3.copyWith(color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
              AppSpacing.gapVerticalLg,
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl, horizontal: AppSpacing.xl),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
                child: Center(
                  child: Transform.scale(
                    scale: 1.5,
                    child: DSBadge(
                      label: _badgeLabel,
                      variant: _selectedVariant,
                      isOutlined: _isOutlined,
                      icon: iconData != null ? Icon(iconData) : null,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        AppSpacing.gapVerticalLg,

        // Controls
        DSCard(
          variant: DSCardVariant.outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Badge Configuration', style: AppTypography.h3.copyWith(color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
              AppSpacing.gapVerticalMd,

              DSInput(
                label: 'Badge Label Text',
                controller: TextEditingController(text: _badgeLabel),
                onChanged: (val) => setState(() => _badgeLabel = val.isEmpty ? 'Badge' : val),
              ),
              AppSpacing.gapVerticalMd,

              // Variant Chips
              Text('Variant', style: AppTypography.label.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
              AppSpacing.gapVerticalXs,
              Wrap(
                spacing: AppSpacing.xs,
                children: DSBadgeVariant.values.map((v) {
                  final isSelected = v == _selectedVariant;
                  return ChoiceChip(
                    label: Text(v.name.toUpperCase()),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(color: isSelected ? Colors.white : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
                    onSelected: (_) => setState(() => _selectedVariant = v),
                  );
                }).toList(),
              ),
              AppSpacing.gapVerticalMd,

              // Icon Chips
              Text('Icon', style: AppTypography.label.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
              AppSpacing.gapVerticalXs,
              Wrap(
                spacing: AppSpacing.xs,
                children: [
                  ChoiceChip(label: const Text('None'), selected: _selectedIconIndex == 0, onSelected: (_) => setState(() => _selectedIconIndex = 0)),
                  ChoiceChip(label: const Text('Check'), selected: _selectedIconIndex == 1, onSelected: (_) => setState(() => _selectedIconIndex = 1)),
                  ChoiceChip(label: const Text('Star'), selected: _selectedIconIndex == 2, onSelected: (_) => setState(() => _selectedIconIndex = 2)),
                  ChoiceChip(label: const Text('Warning'), selected: _selectedIconIndex == 3, onSelected: (_) => setState(() => _selectedIconIndex = 3)),
                  ChoiceChip(label: const Text('Flame'), selected: _selectedIconIndex == 4, onSelected: (_) => setState(() => _selectedIconIndex = 4)),
                  ChoiceChip(label: const Text('Lock'), selected: _selectedIconIndex == 5, onSelected: (_) => setState(() => _selectedIconIndex = 5)),
                ],
              ),
              AppSpacing.gapVerticalMd,

              SwitchListTile(
                title: const Text('Outlined Style (isOutlined)'),
                subtitle: const Text('Transparent background with thin colored border stroke'),
                value: _isOutlined,
                onChanged: (val) => setState(() => _isOutlined = val),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- 2. MATRIX ---
  Widget _buildMatrix(BuildContext context) {
    final isDark = widget.themeController.isDarkMode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Badge Style & Variant Matrix', style: AppTypography.h2.copyWith(color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
        AppSpacing.gapVerticalSm,
        Text('Solid background vs Outlined background across all status variants.', style: AppTypography.bodyMd.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
        AppSpacing.gapVerticalLg,

        DSCard(
          variant: DSCardVariant.elevated,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Solid Background Badges', style: AppTypography.h3.copyWith(color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
              AppSpacing.gapVerticalMd,
              Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.md,
                children: DSBadgeVariant.values.map((v) {
                  return DSBadge(
                    label: v.name.toUpperCase(),
                    variant: v,
                    icon: const Icon(Icons.circle, size: 8),
                  );
                }).toList(),
              ),

              const Divider(height: 48),

              Text('Outlined Stroke Badges (isOutlined = true)', style: AppTypography.h3.copyWith(color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
              AppSpacing.gapVerticalMd,
              Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.md,
                children: DSBadgeVariant.values.map((v) {
                  return DSBadge(
                    label: v.name.toUpperCase(),
                    variant: v,
                    isOutlined: true,
                    icon: const Icon(Icons.circle_outlined, size: 8),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        AppSpacing.gapVerticalLg,

        Text('Real-World Use Cases Showcase', style: AppTypography.h2.copyWith(color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
        AppSpacing.gapVerticalMd,

        DSCard(
          variant: DSCardVariant.outlined,
          child: Column(
            children: [
              _buildUseCaseRow(isDark, 'Band 8.5 Mastered', 'Vocabulary Part 1', const DSBadge(label: 'VERIFIED', variant: DSBadgeVariant.success, icon: Icon(Icons.verified_rounded))),
              const Divider(),
              _buildUseCaseRow(isDark, 'Speaking Mock Test #4', 'Submitted 2 hours ago', const DSBadge(label: 'UNDER REVIEW', variant: DSBadgeVariant.warning, icon: Icon(Icons.hourglass_top_rounded))),
              const Divider(),
              _buildUseCaseRow(isDark, 'Grammar Errors Detected', '3 pronoun agreement issues', const DSBadge(label: 'NEEDS REVISION', variant: DSBadgeVariant.danger, icon: Icon(Icons.error_outline_rounded))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUseCaseRow(bool isDark, String title, String subtitle, Widget badge) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.label.copyWith(color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
              Text(subtitle, style: AppTypography.caption.copyWith(color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted)),
            ],
          ),
          badge,
        ],
      ),
    );
  }

  // --- 3. CODE SNIPPET ---
  Widget _buildCodeSnippet(BuildContext context) {
    final isDark = widget.themeController.isDarkMode;

    final code = '''
DSBadge(
  label: '$_badgeLabel',
  variant: DSBadgeVariant.${_selectedVariant.name},
  isOutlined: $_isOutlined,
  ${_selectedIconIndex != 0 ? 'icon: const Icon(Icons.star_rounded),' : ''}
)
''';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Generated Flutter Code', style: AppTypography.h2.copyWith(color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
            DSButton(
              text: 'Copy Code',
              variant: DSButtonVariant.outline,
              size: DSButtonSize.sm,
              leftIcon: const Icon(Icons.copy_rounded, size: 14),
              onPressed: () {
                DSSnackbar.show(context, message: 'Badge code copied to clipboard!', variant: DSSnackbarVariant.success);
              },
            ),
          ],
        ),
        AppSpacing.gapVerticalMd,
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          ),
          child: SelectableText(
            code,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 14,
              color: Color(0xFF38BDF8),
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  // --- 4. API SPECS ---
  Widget _buildSpecs(BuildContext context) {
    final isDark = widget.themeController.isDarkMode;

    final props = [
      {'name': 'label', 'type': 'String', 'default': 'required', 'desc': 'Pill text label display.'},
      {'name': 'variant', 'type': 'DSBadgeVariant', 'default': 'primary', 'desc': 'Color token theme: primary, success, warning, danger, neutral.'},
      {'name': 'isOutlined', 'type': 'bool', 'default': 'false', 'desc': 'If true, renders with transparent background and thin border.'},
      {'name': 'icon', 'type': 'Widget?', 'default': 'null', 'desc': 'Optional icon widget leading the text label.'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('API Reference & Properties', style: AppTypography.h2.copyWith(color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
        AppSpacing.gapVerticalMd,
        DSCard(
          variant: DSCardVariant.elevated,
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                child: Row(
                  children: [
                    Expanded(flex: 2, child: Text('PROPERTY', style: AppTypography.label.copyWith(color: AppColors.primary))),
                    Expanded(flex: 2, child: Text('TYPE', style: AppTypography.label.copyWith(color: AppColors.primary))),
                    Expanded(flex: 2, child: Text('DEFAULT', style: AppTypography.label.copyWith(color: AppColors.primary))),
                    Expanded(flex: 4, child: Text('DESCRIPTION', style: AppTypography.label.copyWith(color: AppColors.primary))),
                  ],
                ),
              ),
              ...props.map((p) => Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder)),
                ),
                child: Row(
                  children: [
                    Expanded(flex: 2, child: Text(p['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace'))),
                    Expanded(flex: 2, child: Text(p['type']!, style: TextStyle(color: isDark ? AppColors.secondary : AppColors.primaryHover, fontFamily: 'monospace'))),
                    Expanded(flex: 2, child: Text(p['default']!, style: const TextStyle(fontFamily: 'monospace', color: Colors.grey))),
                    Expanded(flex: 4, child: Text(p['desc']!, style: AppTypography.bodySm.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary))),
                  ],
                ),
              )),
            ],
          ),
        ),
      ],
    );
  }
}
