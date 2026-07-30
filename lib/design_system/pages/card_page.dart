import 'package:flutter/material.dart';
import '../design_system.dart';

class DSCardPage extends StatefulWidget {
  final ThemeController themeController;
  final VoidCallback? onBackToOverview;

  const DSCardPage({
    super.key,
    required this.themeController,
    this.onBackToOverview,
  });

  @override
  State<DSCardPage> createState() => _DSCardPageState();
}

class _DSCardPageState extends State<DSCardPage> {
  // Playground State
  DSCardVariant _selectedVariant = DSCardVariant.elevated;
  bool _isClickable = true;
  bool _showHeader = true;
  bool _showBody = true;
  bool _showFooter = true;
  String _cardTitle = 'IELTS Speaking Masterclass';
  String _cardBody = 'Learn strategies for Part 1, 2 & 3. Practice mock tests with AI real-time feedback.';
  int _clickCount = 0;

  @override
  Widget build(BuildContext context) {
    return ComponentPageWrapper(
      title: 'DSCard',
      subtitle: 'Container card component supporting elevated, outlined & glassmorphic backdrop blur variants',
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Canvas Container (With background gradient so glass variant is clearly visible)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            gradient: _selectedVariant == DSCardVariant.glass
                ? LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.8),
                      AppColors.secondary.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: _selectedVariant == DSCardVariant.glass
                ? null
                : (isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Live Preview (${_selectedVariant.name.toUpperCase()})',
                    style: AppTypography.h3.copyWith(
                      color: _selectedVariant == DSCardVariant.glass ? Colors.white : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                    ),
                  ),
                  DSBadge(
                    label: _isClickable ? 'Tap Count: $_clickCount' : 'Static Card',
                    variant: _isClickable ? DSBadgeVariant.success : DSBadgeVariant.neutral,
                  ),
                ],
              ),
              AppSpacing.gapVerticalLg,
              DSCard(
                variant: _selectedVariant,
                onTap: _isClickable
                    ? () {
                        setState(() => _clickCount++);
                        DSSnackbar.show(context, message: 'Card tapped! (Count: $_clickCount)', variant: DSSnackbarVariant.info);
                      }
                    : null,
                header: _showHeader
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_cardTitle, style: AppTypography.h2.copyWith(color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
                          const DSBadge(label: 'PART 2', variant: DSBadgeVariant.primary),
                        ],
                      )
                    : null,
                body: _showBody
                    ? Text(
                        _cardBody,
                        style: AppTypography.bodyMd.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                      )
                    : null,
                footer: _showFooter
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Duration: 45 min', style: AppTypography.caption.copyWith(color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted)),
                          DSButton(
                            text: 'Start Practice',
                            variant: DSButtonVariant.primary,
                            size: DSButtonSize.sm,
                            onPressed: () {},
                          ),
                        ],
                      )
                    : null,
              ),
            ],
          ),
        ),
        AppSpacing.gapVerticalLg,

        // Controls Card
        DSCard(
          variant: DSCardVariant.outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Card Controls & Variant Selection', style: AppTypography.h3.copyWith(color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
              AppSpacing.gapVerticalMd,

              // Variant Pills
              Text('Variant', style: AppTypography.label.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
              AppSpacing.gapVerticalXs,
              Wrap(
                spacing: AppSpacing.xs,
                children: DSCardVariant.values.map((v) {
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

              DSInput(
                label: 'Header Title',
                controller: TextEditingController(text: _cardTitle),
                onChanged: (val) => setState(() => _cardTitle = val),
              ),
              AppSpacing.gapVerticalMd,

              DSInput(
                label: 'Body Content Text',
                controller: TextEditingController(text: _cardBody),
                onChanged: (val) => setState(() => _cardBody = val),
              ),
              AppSpacing.gapVerticalMd,

              SwitchListTile(
                title: const Text('Interactive Tap Callback'),
                subtitle: const Text('Enables hover lift and tap press scale down'),
                value: _isClickable,
                onChanged: (val) => setState(() => _isClickable = val),
              ),
              SwitchListTile(
                title: const Text('Show Header Section'),
                value: _showHeader,
                onChanged: (val) => setState(() => _showHeader = val),
              ),
              SwitchListTile(
                title: const Text('Show Body Section'),
                value: _showBody,
                onChanged: (val) => setState(() => _showBody = val),
              ),
              SwitchListTile(
                title: const Text('Show Footer Section'),
                value: _showFooter,
                onChanged: (val) => setState(() => _showFooter = val),
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
        Text('Card Variant Comparison Matrix', style: AppTypography.h2.copyWith(color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
        AppSpacing.gapVerticalSm,
        Text('Side-by-side preview of Elevated, Outlined, and Glassmorphism variants.', style: AppTypography.bodyMd.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
        AppSpacing.gapVerticalLg,

        // Gradient Canvas background for glass effect
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withValues(alpha: 0.15),
                AppColors.secondary.withValues(alpha: 0.15),
              ],
            ),
          ),
          child: Column(
            children: [
              // 1. Elevated
              _buildMatrixRow(
                context,
                title: 'Elevated Card',
                badge: 'Default',
                variant: DSCardVariant.elevated,
                description: 'Soft drop shadows creating floating elevation above background surfaces.',
              ),
              AppSpacing.gapVerticalLg,

              // 2. Outlined
              _buildMatrixRow(
                context,
                title: 'Outlined Card',
                badge: 'Clean Border',
                variant: DSCardVariant.outlined,
                description: 'Flat surface defined by a subtle 1px border stroke.',
              ),
              AppSpacing.gapVerticalLg,

              // 3. Glass
              _buildMatrixRow(
                context,
                title: 'Glassmorphic Card',
                badge: 'Backdrop Blur',
                variant: DSCardVariant.glass,
                description: 'Translucent background with 16px BackdropFilter blur and light border accent.',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMatrixRow(BuildContext context, {required String title, required String badge, required DSCardVariant variant, required String description}) {
    final isDark = widget.themeController.isDarkMode;

    return DSCard(
      variant: variant,
      onTap: () {},
      header: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTypography.h3.copyWith(color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
          DSBadge(label: badge, variant: DSBadgeVariant.primary),
        ],
      ),
      body: Text(description, style: AppTypography.bodyMd.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          DSButton(text: 'Investigate', variant: DSButtonVariant.ghost, size: DSButtonSize.sm, onPressed: () {}),
        ],
      ),
    );
  }

  // --- 3. CODE SNIPPET ---
  Widget _buildCodeSnippet(BuildContext context) {
    final isDark = widget.themeController.isDarkMode;

    final code = '''
DSCard(
  variant: DSCardVariant.${_selectedVariant.name},
  ${_isClickable ? "onTap: () {\n    // Handle tap\n  }," : ""}
  header: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text('$_cardTitle'),
      const DSBadge(label: 'PART 2'),
    ],
  ),
  body: Text('$_cardBody'),
  footer: DSButton(
    text: 'Action',
    onPressed: () {},
  ),
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
                DSSnackbar.show(context, message: 'Card code copied to clipboard!', variant: DSSnackbarVariant.success);
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
      {'name': 'variant', 'type': 'DSCardVariant', 'default': 'elevated', 'desc': 'Card style: elevated (shadow), outlined (border), glass (blur).'},
      {'name': 'child', 'type': 'Widget?', 'default': 'null', 'desc': 'Custom content child widget. Overrides header/body/footer if provided.'},
      {'name': 'header', 'type': 'Widget?', 'default': 'null', 'desc': 'Optional card header slot.'},
      {'name': 'body', 'type': 'Widget?', 'default': 'null', 'desc': 'Optional card body text/content slot.'},
      {'name': 'footer', 'type': 'Widget?', 'default': 'null', 'desc': 'Optional card footer actions slot.'},
      {'name': 'onTap', 'type': 'VoidCallback?', 'default': 'null', 'desc': 'Tap callback. Enables mouse hover lift and tap scale feedback.'},
      {'name': 'interactive', 'type': 'bool', 'default': 'true', 'desc': 'Enables micro-animation effects when onTap is provided.'},
      {'name': 'padding', 'type': 'EdgeInsetsGeometry?', 'default': 'AppSpacing.lg (24px)', 'desc': 'Internal container padding.'},
      {'name': 'margin', 'type': 'EdgeInsetsGeometry?', 'default': 'null', 'desc': 'Outer container margin.'},
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
