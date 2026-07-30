import 'package:flutter/material.dart';
import '../design_system.dart';

class DSInputPage extends StatefulWidget {
  final ThemeController themeController;
  final VoidCallback? onBackToOverview;

  const DSInputPage({
    super.key,
    required this.themeController,
    this.onBackToOverview,
  });

  @override
  State<DSInputPage> createState() => _DSInputPageState();
}

class _DSInputPageState extends State<DSInputPage> {
  // Playground State
  DSInputType _selectedType = DSInputType.text;
  String _label = 'User Full Name';
  String _placeholder = 'e.g. Jane Doe';
  String _helperText = 'Enter your legal first and last name';
  String _errorText = 'Name cannot be empty or contain numbers';
  bool _showError = false;
  bool _disabled = false;
  String _currentValue = '';

  final TextEditingController _playgroundController = TextEditingController();

  @override
  void dispose() {
    _playgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ComponentPageWrapper(
      title: 'DSInput',
      subtitle: 'Form field component supporting text, password, email, search with focus glow & validation states',
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
                    label: _disabled ? 'Disabled' : (_showError ? 'Validation Error' : 'Active'),
                    variant: _disabled ? DSBadgeVariant.neutral : (_showError ? DSBadgeVariant.danger : DSBadgeVariant.success),
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
                child: DSInput(
                  label: _label,
                  placeholder: _placeholder,
                  helperText: _helperText,
                  errorText: _showError ? _errorText : null,
                  type: _selectedType,
                  disabled: _disabled,
                  controller: _playgroundController,
                  onChanged: (val) => setState(() => _currentValue = val),
                ),
              ),
              AppSpacing.gapVerticalMd,
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.primary),
                    AppSpacing.gapHorizontalSm,
                    Text('Current Value: ', style: AppTypography.label.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                    Expanded(
                      child: Text(
                        _currentValue.isEmpty ? '(Empty)' : _currentValue,
                        style: AppTypography.bodySm.copyWith(
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        AppSpacing.gapVerticalLg,

        // Controls Grid
        DSCard(
          variant: DSCardVariant.outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Field Configuration & State', style: AppTypography.h3.copyWith(color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
              AppSpacing.gapVerticalMd,

              // Type Choice Chips
              Text('Input Type', style: AppTypography.label.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
              AppSpacing.gapVerticalXs,
              Wrap(
                spacing: AppSpacing.xs,
                children: DSInputType.values.map((t) {
                  final isSelected = t == _selectedType;
                  return ChoiceChip(
                    label: Text(t.name.toUpperCase()),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(color: isSelected ? Colors.white : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
                    onSelected: (_) => setState(() => _selectedType = t),
                  );
                }).toList(),
              ),
              AppSpacing.gapVerticalMd,

              Row(
                children: [
                  Expanded(
                    child: DSInput(
                      label: 'Label Text',
                      controller: TextEditingController(text: _label),
                      onChanged: (val) => setState(() => _label = val),
                    ),
                  ),
                  AppSpacing.gapHorizontalMd,
                  Expanded(
                    child: DSInput(
                      label: 'Placeholder Text',
                      controller: TextEditingController(text: _placeholder),
                      onChanged: (val) => setState(() => _placeholder = val),
                    ),
                  ),
                ],
              ),
              AppSpacing.gapVerticalMd,

              Row(
                children: [
                  Expanded(
                    child: DSInput(
                      label: 'Helper Subtitle',
                      controller: TextEditingController(text: _helperText),
                      onChanged: (val) => setState(() => _helperText = val),
                    ),
                  ),
                  AppSpacing.gapHorizontalMd,
                  Expanded(
                    child: DSInput(
                      label: 'Error Message',
                      controller: TextEditingController(text: _errorText),
                      onChanged: (val) => setState(() => _errorText = val),
                    ),
                  ),
                ],
              ),
              AppSpacing.gapVerticalMd,

              SwitchListTile(
                title: const Text('Trigger Validation Error'),
                subtitle: const Text('Toggles glowing red border and animated error message reveal'),
                value: _showError,
                onChanged: (val) => setState(() => _showError = val),
              ),
              SwitchListTile(
                title: const Text('Disabled State'),
                subtitle: const Text('Greys out input and prevents focus'),
                value: _disabled,
                onChanged: (val) => setState(() => _disabled = val),
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
        Text('Input Variant Types Showcase', style: AppTypography.h2.copyWith(color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
        AppSpacing.gapVerticalSm,
        Text('Explore all built-in input field configurations and interactive states.', style: AppTypography.bodyMd.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
        AppSpacing.gapVerticalLg,

        DSCard(
          variant: DSCardVariant.elevated,
          child: Column(
            children: [
              // 1. Text Field
              const DSInput(
                label: 'Standard Text Input',
                placeholder: 'Enter text...',
                helperText: 'Standard text input field',
                type: DSInputType.text,
              ),
              AppSpacing.gapVerticalLg,

              // 2. Password Field
              const DSInput(
                label: 'Password Input (with Toggle Eye)',
                placeholder: '••••••••••••',
                helperText: 'Click the eye icon to toggle visibility',
                type: DSInputType.password,
              ),
              AppSpacing.gapVerticalLg,

              // 3. Email Field
              const DSInput(
                label: 'Email Address Input',
                placeholder: 'student@university.edu',
                helperText: 'Validated email format',
                type: DSInputType.email,
              ),
              AppSpacing.gapVerticalLg,

              // 4. Search Field
              const DSInput(
                label: 'Search Field (with Clear Button)',
                placeholder: 'Search IELTS vocabulary...',
                type: DSInputType.search,
              ),
              AppSpacing.gapVerticalLg,

              // 5. Error State
              const DSInput(
                label: 'Error State Demonstration',
                placeholder: 'Invalid input value',
                errorText: 'This field is required and cannot be blank',
                type: DSInputType.text,
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
DSInput(
  label: '$_label',
  placeholder: '$_placeholder',
  helperText: '${_showError ? "" : _helperText}',
  ${_showError ? "errorText: '$_errorText'," : ""}
  type: DSInputType.${_selectedType.name},
  disabled: $_disabled,
  onChanged: (value) {
    print('Typed value: \$value');
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
                DSSnackbar.show(context, message: 'Input code copied to clipboard!', variant: DSSnackbarVariant.success);
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
      {'name': 'label', 'type': 'String?', 'default': 'null', 'desc': 'Top label text for the input field.'},
      {'name': 'placeholder', 'type': 'String?', 'default': 'null', 'desc': 'Hint placeholder text displayed when empty.'},
      {'name': 'helperText', 'type': 'String?', 'default': 'null', 'desc': 'Subtext instruction below the input field.'},
      {'name': 'errorText', 'type': 'String?', 'default': 'null', 'desc': 'Error message text. When provided, field turns red with focus glow.'},
      {'name': 'type', 'type': 'DSInputType', 'default': 'text', 'desc': 'Input variant: text, password, email, search.'},
      {'name': 'disabled', 'type': 'bool', 'default': 'false', 'desc': 'Disables text editing and applies muted surface colors.'},
      {'name': 'leftIcon', 'type': 'Widget?', 'default': 'auto', 'desc': 'Custom icon prefix widget (auto-inferred for email/search/password).'},
      {'name': 'rightIcon', 'type': 'Widget?', 'default': 'auto', 'desc': 'Custom icon suffix widget (auto-inferred for password toggle & search clear).'},
      {'name': 'controller', 'type': 'TextEditingController?', 'default': 'null', 'desc': 'Optional external TextEditingController.'},
      {'name': 'onChanged', 'type': 'ValueChanged<String>?', 'default': 'null', 'desc': 'Callback invoked whenever text changes.'},
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

