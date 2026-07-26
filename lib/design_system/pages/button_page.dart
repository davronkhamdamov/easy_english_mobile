import 'package:flutter/material.dart';
import '../design_system.dart';
import 'component_page_wrapper.dart';

class DSButtonPage extends StatefulWidget {
  final ThemeController themeController;
  final VoidCallback? onBackToOverview;

  const DSButtonPage({
    super.key,
    required this.themeController,
    this.onBackToOverview,
  });

  @override
  State<DSButtonPage> createState() => _DSButtonPageState();
}

class _DSButtonPageState extends State<DSButtonPage> {
  // Playground State
  String _buttonText = 'Click Me';
  DSButtonVariant _selectedVariant = DSButtonVariant.primary;
  DSButtonSize _selectedSize = DSButtonSize.md;
  bool _isLoading = false;
  bool _disabled = false;
  bool _fullWidth = false;
  bool _showLeftIcon = false;
  bool _showRightIcon = false;

  final List<String> _tapLogs = [];

  void _logTap() {
    setState(() {
      final time = DateTime.now().toString().split(' ')[1].substring(0, 8);
      _tapLogs.insert(0, '[$time] DSButton tapped! (variant: ${_selectedVariant.name}, size: ${_selectedSize.name})');
      if (_tapLogs.length > 8) _tapLogs.removeLast();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ComponentPageWrapper(
      title: 'DSButton',
      subtitle: 'Interactive button component with 5 variants, 3 sizes, micro-animations & loading states',
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
        // Live Preview Canvas Card
        DSCard(
          variant: DSCardVariant.elevated,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Live Preview', style: AppTypography.h3.copyWith(color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
                  DSBadge(
                    label: _disabled ? 'Disabled' : (_isLoading ? 'Loading State' : 'Interactive'),
                    variant: _disabled ? DSBadgeVariant.neutral : (_isLoading ? DSBadgeVariant.warning : DSBadgeVariant.success),
                  ),
                ],
              ),
              AppSpacing.gapVerticalLg,
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
                child: Center(
                  child: AnimatedContainer(
                    duration: AppAnimations.fast,
                    width: _fullWidth ? double.infinity : null,
                    child: DSButton(
                      text: _buttonText,
                      variant: _selectedVariant,
                      size: _selectedSize,
                      isLoading: _isLoading,
                      disabled: _disabled,
                      fullWidth: _fullWidth,
                      leftIcon: _showLeftIcon ? const Icon(Icons.flash_on_rounded) : null,
                      rightIcon: _showRightIcon ? const Icon(Icons.arrow_forward_rounded) : null,
                      onPressed: _logTap,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        AppSpacing.gapVerticalLg,

        // Controls Grid
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Controls Panel
            Expanded(
              flex: 3,
              child: DSCard(
                variant: DSCardVariant.outlined,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Controls & Configuration', style: AppTypography.h3.copyWith(color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
                    AppSpacing.gapVerticalMd,

                    // Label Input
                    DSInput(
                      label: 'Button Text Label',
                      controller: TextEditingController(text: _buttonText),
                      onChanged: (val) => setState(() => _buttonText = val.isEmpty ? 'Button' : val),
                    ),
                    AppSpacing.gapVerticalMd,

                    // Variant Selector
                    Text('Variant', style: AppTypography.label.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                    AppSpacing.gapVerticalXs,
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: DSButtonVariant.values.map((v) {
                        final isSelected = v == _selectedVariant;
                        return ChoiceChip(
                          label: Text(v.name),
                          selected: isSelected,
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(color: isSelected ? Colors.white : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
                          onSelected: (_) => setState(() => _selectedVariant = v),
                        );
                      }).toList(),
                    ),
                    AppSpacing.gapVerticalMd,

                    // Size Selector
                    Text('Size', style: AppTypography.label.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                    AppSpacing.gapVerticalXs,
                    Wrap(
                      spacing: AppSpacing.xs,
                      children: DSButtonSize.values.map((s) {
                        final isSelected = s == _selectedSize;
                        return ChoiceChip(
                          label: Text(s.name.toUpperCase()),
                          selected: isSelected,
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(color: isSelected ? Colors.white : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
                          onSelected: (_) => setState(() => _selectedSize = s),
                        );
                      }).toList(),
                    ),
                    AppSpacing.gapVerticalMd,

                    // Boolean Toggles
                    Text('States & Icons', style: AppTypography.label.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                    SwitchListTile(
                      title: const Text('Loading Spinner'),
                      subtitle: const Text('Shows active loading indicator'),
                      value: _isLoading,
                      onChanged: (val) => setState(() => _isLoading = val),
                    ),
                    SwitchListTile(
                      title: const Text('Disabled State'),
                      subtitle: const Text('Prevents clicks & updates styling'),
                      value: _disabled,
                      onChanged: (val) => setState(() => _disabled = val),
                    ),
                    SwitchListTile(
                      title: const Text('Full Width'),
                      subtitle: const Text('Expands horizontally'),
                      value: _fullWidth,
                      onChanged: (val) => setState(() => _fullWidth = val),
                    ),
                    SwitchListTile(
                      title: const Text('Left Icon'),
                      value: _showLeftIcon,
                      onChanged: (val) => setState(() => _showLeftIcon = val),
                    ),
                    SwitchListTile(
                      title: const Text('Right Icon'),
                      value: _showRightIcon,
                      onChanged: (val) => setState(() => _showRightIcon = val),
                    ),
                  ],
                ),
              ),
            ),
            AppSpacing.gapHorizontalLg,

            // Event Logs Card
            Expanded(
              flex: 2,
              child: DSCard(
                variant: DSCardVariant.outlined,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Event Console Log', style: AppTypography.h3.copyWith(color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
                        if (_tapLogs.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, size: 18),
                            onPressed: () => setState(() => _tapLogs.clear()),
                            tooltip: 'Clear Logs',
                          ),
                      ],
                    ),
                    AppSpacing.gapVerticalSm,
                    Container(
                      height: 320,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                        fontFamily: 'monospace',
                      ),
                      child: _tapLogs.isEmpty
                          ? Center(
                              child: Text(
                                'Click the button in live preview to log press events...',
                                style: AppTypography.caption.copyWith(color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                                textAlign: TextAlign.center,
                              ),
                            )
                          : ListView.builder(
                              itemCount: _tapLogs.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                                  child: Text(
                                    _tapLogs[index],
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark ? AppColors.success : AppColors.primaryHover,
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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
        Text('Variant & Size Matrix', style: AppTypography.h2.copyWith(color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
        AppSpacing.gapVerticalSm,
        Text('Inspect all 5 button variants across all 3 sizes side-by-side.', style: AppTypography.bodyMd.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
        AppSpacing.gapVerticalLg,

        DSCard(
          variant: DSCardVariant.elevated,
          child: Column(
            children: DSButtonVariant.values.map((v) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        DSBadge(label: v.name.toUpperCase(), variant: DSBadgeVariant.primary),
                        AppSpacing.gapHorizontalSm,
                        Text('${v.name} Variant', style: AppTypography.h3.copyWith(color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
                      ],
                    ),
                    AppSpacing.gapVerticalMd,
                    Wrap(
                      spacing: AppSpacing.lg,
                      runSpacing: AppSpacing.md,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        DSButton(text: '${v.name} Small', variant: v, size: DSButtonSize.sm, onPressed: () {}),
                        DSButton(text: '${v.name} Medium', variant: v, size: DSButtonSize.md, onPressed: () {}),
                        DSButton(text: '${v.name} Large', variant: v, size: DSButtonSize.lg, onPressed: () {}),
                      ],
                    ),
                    const Divider(height: 32),
                  ],
                ),
              );
            }).toList(),
          ),
        ),

        AppSpacing.gapVerticalLg,
        Text('States Matrix (Loading & Disabled)', style: AppTypography.h2.copyWith(color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
        AppSpacing.gapVerticalMd,

        DSCard(
          variant: DSCardVariant.elevated,
          child: Wrap(
            spacing: AppSpacing.lg,
            runSpacing: AppSpacing.lg,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Loading State (Primary)', style: AppTypography.label.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                  AppSpacing.gapVerticalSm,
                  const DSButton(text: 'Saving Data...', isLoading: true, variant: DSButtonVariant.primary),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Loading State (Danger)', style: AppTypography.label.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                  AppSpacing.gapVerticalSm,
                  const DSButton(text: 'Deleting...', isLoading: true, variant: DSButtonVariant.danger),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Disabled State', style: AppTypography.label.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                  AppSpacing.gapVerticalSm,
                  const DSButton(text: 'Cannot Click', disabled: true, variant: DSButtonVariant.primary),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- 3. CODE SNIPPET ---
  Widget _buildCodeSnippet(BuildContext context) {
    final isDark = widget.themeController.isDarkMode;

    final code = '''
DSButton(
  text: '$_buttonText',
  variant: DSButtonVariant.${_selectedVariant.name},
  size: DSButtonSize.${_selectedSize.name},
  isLoading: $_isLoading,
  disabled: $_disabled,
  fullWidth: $_fullWidth,
  ${_showLeftIcon ? 'leftIcon: const Icon(Icons.flash_on_rounded),' : ''}
  ${_showRightIcon ? 'rightIcon: const Icon(Icons.arrow_forward_rounded),' : ''}
  onPressed: () {
    // Action handler
  },
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
                DSSnackbar.show(context, message: 'Code copied to clipboard!', variant: DSSnackbarVariant.success);
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
      {'name': 'text', 'type': 'String', 'default': 'required', 'desc': 'Button text label display.'},
      {'name': 'onPressed', 'type': 'VoidCallback?', 'default': 'null', 'desc': 'Callback function when clicked. If null, button is disabled.'},
      {'name': 'variant', 'type': 'DSButtonVariant', 'default': 'primary', 'desc': 'Visual variant: primary, secondary, outline, ghost, danger.'},
      {'name': 'size', 'type': 'DSButtonSize', 'default': 'md', 'desc': 'Button sizing height & padding: sm (36px), md (44px), lg (52px).'},
      {'name': 'isLoading', 'type': 'bool', 'default': 'false', 'desc': 'Shows inline progress spinner and disables interactions.'},
      {'name': 'disabled', 'type': 'bool', 'default': 'false', 'desc': 'Disables click events and applies muted background/text colors.'},
      {'name': 'leftIcon', 'type': 'Widget?', 'default': 'null', 'desc': 'Optional icon widget rendered left of the text.'},
      {'name': 'rightIcon', 'type': 'Widget?', 'default': 'null', 'desc': 'Optional icon widget rendered right of the text.'},
      {'name': 'fullWidth', 'type': 'bool', 'default': 'false', 'desc': 'If true, button stretches to fill available horizontal width.'},
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
