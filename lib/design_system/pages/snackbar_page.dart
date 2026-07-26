import 'package:flutter/material.dart';
import '../design_system.dart';
import 'component_page_wrapper.dart';

class DSSnackbarPage extends StatefulWidget {
  final ThemeController themeController;
  final VoidCallback? onBackToOverview;

  const DSSnackbarPage({
    super.key,
    required this.themeController,
    this.onBackToOverview,
  });

  @override
  State<DSSnackbarPage> createState() => _DSSnackbarPageState();
}

class _DSSnackbarPageState extends State<DSSnackbarPage> {
  // Playground State
  String _message = 'Your speaking practice audio recording was saved successfully!';
  String _title = 'Action Completed';
  DSSnackbarVariant _selectedVariant = DSSnackbarVariant.success;
  double _durationSeconds = 4.0;

  @override
  Widget build(BuildContext context) {
    return ComponentPageWrapper(
      title: 'DSSnackbar',
      subtitle: 'Floating notification system with success, warning, danger & info variants',
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
        // Launch Canvas Card
        DSCard(
          variant: DSCardVariant.elevated,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Toast Notification Trigger', style: AppTypography.h3.copyWith(color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
                  DSBadge(label: _selectedVariant.name.toUpperCase(), variant: _getBadgeVariant(_selectedVariant)),
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
                child: Column(
                  children: [
                    Text(
                      'Click below to trigger live floating snackbar toast',
                      style: AppTypography.bodyMd.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                    ),
                    AppSpacing.gapVerticalLg,
                    DSButton(
                      text: 'Trigger Floating Toast Notification',
                      variant: DSButtonVariant.primary,
                      size: DSButtonSize.lg,
                      leftIcon: const Icon(Icons.notifications_active_rounded),
                      onPressed: () {
                        DSSnackbar.show(
                          context,
                          title: _title.isEmpty ? null : _title,
                          message: _message,
                          variant: _selectedVariant,
                          duration: Duration(seconds: _durationSeconds.toInt()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        AppSpacing.gapVerticalLg,

        // Configuration Controls
        DSCard(
          variant: DSCardVariant.outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Snackbar Customization', style: AppTypography.h3.copyWith(color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
              AppSpacing.gapVerticalMd,

              // Variant Selector
              Text('Notification Variant', style: AppTypography.label.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
              AppSpacing.gapVerticalXs,
              Wrap(
                spacing: AppSpacing.xs,
                children: DSSnackbarVariant.values.map((v) {
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
                label: 'Notification Title (Optional)',
                controller: TextEditingController(text: _title),
                onChanged: (val) => setState(() => _title = val),
              ),
              AppSpacing.gapVerticalMd,

              DSInput(
                label: 'Notification Message Content',
                controller: TextEditingController(text: _message),
                onChanged: (val) => setState(() => _message = val),
              ),
              AppSpacing.gapVerticalMd,

              Text('Auto-Dismiss Duration: ${_durationSeconds.toInt()} Seconds', style: AppTypography.label.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
              Slider(
                value: _durationSeconds,
                min: 1,
                max: 10,
                divisions: 9,
                activeColor: AppColors.primary,
                label: '${_durationSeconds.toInt()}s',
                onChanged: (val) => setState(() => _durationSeconds = val),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- 2. MATRIX & STATIC LAYOUT ---
  Widget _buildMatrix(BuildContext context) {
    final isDark = widget.themeController.isDarkMode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Variant Quick Triggers', style: AppTypography.h2.copyWith(color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
        AppSpacing.gapVerticalSm,
        Text('Click any button to trigger live notification variants.', style: AppTypography.bodyMd.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
        AppSpacing.gapVerticalLg,

        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            DSButton(
              text: 'Trigger Success',
              variant: DSButtonVariant.secondary,
              leftIcon: const Icon(Icons.check_circle_rounded, color: AppColors.success),
              onPressed: () => DSSnackbar.show(context, title: 'Success', message: 'Pronunciation score updated to Band 8.0', variant: DSSnackbarVariant.success),
            ),
            DSButton(
              text: 'Trigger Warning',
              variant: DSButtonVariant.outline,
              leftIcon: const Icon(Icons.warning_rounded, color: AppColors.warning),
              onPressed: () => DSSnackbar.show(context, title: 'Warning', message: 'Microphone audio level is slightly quiet', variant: DSSnackbarVariant.warning),
            ),
            DSButton(
              text: 'Trigger Danger',
              variant: DSButtonVariant.danger,
              leftIcon: const Icon(Icons.error_rounded),
              onPressed: () => DSSnackbar.show(context, title: 'Connection Error', message: 'Failed to upload response audio clip', variant: DSSnackbarVariant.danger),
            ),
            DSButton(
              text: 'Trigger Info',
              variant: DSButtonVariant.primary,
              leftIcon: const Icon(Icons.info_rounded),
              onPressed: () => DSSnackbar.show(context, title: 'New Cue Card Available', message: 'Topic: Describe a memorable journey', variant: DSSnackbarVariant.info),
            ),
          ],
        ),
        AppSpacing.gapVerticalLg,

        Text('Static Card Inspector (Layout & Tokens)', style: AppTypography.h2.copyWith(color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
        AppSpacing.gapVerticalMd,

        DSCard(
          variant: DSCardVariant.elevated,
          child: Column(
            children: [
              _buildStaticToastCard(isDark, title: 'Success Toast', msg: 'Audio recording process complete.', icon: Icons.check_circle_rounded, color: AppColors.success),
              AppSpacing.gapVerticalMd,
              _buildStaticToastCard(isDark, title: 'Warning Toast', msg: 'Time remaining: 30 seconds for Part 2.', icon: Icons.warning_rounded, color: AppColors.warning),
              AppSpacing.gapVerticalMd,
              _buildStaticToastCard(isDark, title: 'Danger Toast', msg: 'Network timeout during speech recognition.', icon: Icons.error_rounded, color: AppColors.danger),
              AppSpacing.gapVerticalMd,
              _buildStaticToastCard(isDark, title: 'Info Toast', msg: 'Tap microphone to start speaking.', icon: Icons.info_rounded, color: AppColors.primary),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStaticToastCard(bool isDark, {required String title, required String msg, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        boxShadow: AppShadows.md(isDark),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          AppSpacing.gapHorizontalMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.label.copyWith(color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
                Text(msg, style: AppTypography.bodySm.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  DSBadgeVariant _getBadgeVariant(DSSnackbarVariant v) {
    switch (v) {
      case DSSnackbarVariant.success:
        return DSBadgeVariant.success;
      case DSSnackbarVariant.warning:
        return DSBadgeVariant.warning;
      case DSSnackbarVariant.danger:
        return DSBadgeVariant.danger;
      case DSSnackbarVariant.info:
        return DSBadgeVariant.primary;
    }
  }

  // --- 3. CODE SNIPPET ---
  Widget _buildCodeSnippet(BuildContext context) {
    final isDark = widget.themeController.isDarkMode;

    final code = '''
DSSnackbar.show(
  context,
  ${_title.isNotEmpty ? "title: '$_title'," : ""}
  message: '$_message',
  variant: DSSnackbarVariant.${_selectedVariant.name},
  duration: const Duration(seconds: ${_durationSeconds.toInt()}),
);
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
                DSSnackbar.show(context, message: 'Snackbar code copied to clipboard!', variant: DSSnackbarVariant.success);
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
      {'name': 'context', 'type': 'BuildContext', 'default': 'required', 'desc': 'BuildContext used to locate nearest ScaffoldMessenger.'},
      {'name': 'message', 'type': 'String', 'default': 'required', 'desc': 'Body message text displayed inside toast.'},
      {'name': 'title', 'type': 'String?', 'default': 'null', 'desc': 'Optional bold title displayed above message text.'},
      {'name': 'variant', 'type': 'DSSnackbarVariant', 'default': 'info', 'desc': 'Notification variant: success, warning, danger, info.'},
      {'name': 'duration', 'type': 'Duration', 'default': '4 seconds', 'desc': 'Display time before toast automatically dismisses.'},
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
