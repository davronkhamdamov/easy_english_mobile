import 'package:flutter/material.dart';
import '../design_system.dart';
import 'component_page_wrapper.dart';

class DSDialogPage extends StatefulWidget {
  final ThemeController themeController;
  final VoidCallback? onBackToOverview;

  const DSDialogPage({
    super.key,
    required this.themeController,
    this.onBackToOverview,
  });

  @override
  State<DSDialogPage> createState() => _DSDialogPageState();
}

class _DSDialogPageState extends State<DSDialogPage> {
  // Playground State
  String _title = 'Submit Speaking Test?';
  String _message = 'You have completed Part 1 & Part 2. Once submitted, your audio will be processed by AI scoring.';
  String _confirmText = 'Submit Now';
  String _cancelText = 'Keep Practicing';
  int _iconIndex = 1; // 0: None, 1: Help, 2: Warning/Danger, 3: Success, 4: Info

  Widget? _getDialogIcon() {
    switch (_iconIndex) {
      case 1:
        return const Icon(Icons.help_outline_rounded, size: 40, color: AppColors.primary);
      case 2:
        return const Icon(Icons.warning_amber_rounded, size: 40, color: AppColors.danger);
      case 3:
        return const Icon(Icons.check_circle_outline_rounded, size: 40, color: AppColors.success);
      case 4:
        return const Icon(Icons.info_outline_rounded, size: 40, color: AppColors.secondary);
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ComponentPageWrapper(
      title: 'DSDialog',
      subtitle: 'Glassmorphic modal dialog with backdrop blur, spring scale animation & custom action buttons',
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
        // Modal Trigger Canvas Card
        DSCard(
          variant: DSCardVariant.elevated,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Live Modal Dialog Launcher', style: AppTypography.h3.copyWith(color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
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
                      'Test spring scale entry transition & backdrop blur',
                      style: AppTypography.bodyMd.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                    ),
                    AppSpacing.gapVerticalLg,
                    DSButton(
                      text: 'Launch Glassmorphic Modal',
                      variant: DSButtonVariant.primary,
                      size: DSButtonSize.lg,
                      leftIcon: const Icon(Icons.open_in_new_rounded),
                      onPressed: () {
                        DSDialog.show(
                          context: context,
                          title: _title,
                          message: _message,
                          confirmText: _confirmText.isEmpty ? null : _confirmText,
                          cancelText: _cancelText.isEmpty ? null : _cancelText,
                          icon: _getDialogIcon(),
                          onConfirm: () {
                            DSSnackbar.show(context, message: 'Confirmed action!', variant: DSSnackbarVariant.success);
                          },
                          onCancel: () {
                            DSSnackbar.show(context, message: 'Cancelled modal dialog', variant: DSSnackbarVariant.info);
                          },
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

        // Customization Controls
        DSCard(
          variant: DSCardVariant.outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Modal Configuration', style: AppTypography.h3.copyWith(color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
              AppSpacing.gapVerticalMd,

              // Icon selector
              Text('Header Icon', style: AppTypography.label.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
              AppSpacing.gapVerticalXs,
              Wrap(
                spacing: AppSpacing.xs,
                children: [
                  ChoiceChip(label: const Text('None'), selected: _iconIndex == 0, onSelected: (_) => setState(() => _iconIndex = 0)),
                  ChoiceChip(label: const Text('Question'), selected: _iconIndex == 1, onSelected: (_) => setState(() => _iconIndex = 1)),
                  ChoiceChip(label: const Text('Warning'), selected: _iconIndex == 2, onSelected: (_) => setState(() => _iconIndex = 2)),
                  ChoiceChip(label: const Text('Success'), selected: _iconIndex == 3, onSelected: (_) => setState(() => _iconIndex = 3)),
                  ChoiceChip(label: const Text('Info'), selected: _iconIndex == 4, onSelected: (_) => setState(() => _iconIndex = 4)),
                ],
              ),
              AppSpacing.gapVerticalMd,

              DSInput(
                label: 'Modal Title',
                controller: TextEditingController(text: _title),
                onChanged: (val) => setState(() => _title = val),
              ),
              AppSpacing.gapVerticalMd,

              DSInput(
                label: 'Modal Message',
                controller: TextEditingController(text: _message),
                onChanged: (val) => setState(() => _message = val),
              ),
              AppSpacing.gapVerticalMd,

              Row(
                children: [
                  Expanded(
                    child: DSInput(
                      label: 'Confirm Button Label',
                      controller: TextEditingController(text: _confirmText),
                      onChanged: (val) => setState(() => _confirmText = val),
                    ),
                  ),
                  AppSpacing.gapHorizontalMd,
                  Expanded(
                    child: DSInput(
                      label: 'Cancel Button Label',
                      controller: TextEditingController(text: _cancelText),
                      onChanged: (val) => setState(() => _cancelText = val),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- 2. MATRIX & IN-PAGE PREVIEW ---
  Widget _buildMatrix(BuildContext context) {
    final isDark = widget.themeController.isDarkMode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Pre-configured Modal Use Cases', style: AppTypography.h2.copyWith(color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
        AppSpacing.gapVerticalSm,
        Text('Test standard pre-styled dialog configurations.', style: AppTypography.bodyMd.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
        AppSpacing.gapVerticalLg,

        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            // Danger Dialog Demo
            DSButton(
              text: 'Delete Confirmation (Danger)',
              variant: DSButtonVariant.danger,
              leftIcon: const Icon(Icons.delete_forever_rounded),
              onPressed: () {
                DSDialog.show(
                  context: context,
                  title: 'Delete Recording?',
                  message: 'This action cannot be undone. All saved audio clips and transcriptions for this session will be permanently erased.',
                  confirmText: 'Delete Permanently',
                  cancelText: 'Keep Recording',
                  icon: const Icon(Icons.warning_amber_rounded, size: 44, color: AppColors.danger),
                  onConfirm: () => DSSnackbar.show(context, message: 'Recording deleted', variant: DSSnackbarVariant.danger),
                );
              },
            ),

            // Success Dialog Demo
            DSButton(
              text: 'Test Complete (Success)',
              variant: DSButtonVariant.secondary,
              leftIcon: const Icon(Icons.stars_rounded),
              onPressed: () {
                DSDialog.show(
                  context: context,
                  title: 'Congratulations! Band 7.5',
                  message: 'You have completed the full Speaking Mock Exam with an estimated Overall Speaking Score of Band 7.5.',
                  confirmText: 'View Report',
                  cancelText: 'Close',
                  icon: const Icon(Icons.emoji_events_rounded, size: 44, color: AppColors.warning),
                  onConfirm: () => DSSnackbar.show(context, message: 'Opening detailed score report...', variant: DSSnackbarVariant.success),
                );
              },
            ),
          ],
        ),
        AppSpacing.gapVerticalLg,

        Text('In-Page Glassmorphism Visual Inspector', style: AppTypography.h2.copyWith(color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
        AppSpacing.gapVerticalMd,

        // Gradient Canvas for Backdrop Blur Visualization
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withValues(alpha: 0.8),
                AppColors.secondary.withValues(alpha: 0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: DSDialog(
              title: _title,
              message: _message,
              confirmText: _confirmText.isEmpty ? null : _confirmText,
              cancelText: _cancelText.isEmpty ? null : _cancelText,
              icon: _getDialogIcon(),
            ),
          ),
        ),
      ],
    );
  }

  // --- 3. CODE SNIPPET ---
  Widget _buildCodeSnippet(BuildContext context) {
    final isDark = widget.themeController.isDarkMode;

    final code = '''
DSDialog.show(
  context: context,
  title: '$_title',
  message: '$_message',
  ${_confirmText.isNotEmpty ? "confirmText: '$_confirmText'," : ""}
  ${_cancelText.isNotEmpty ? "cancelText: '$_cancelText'," : ""}
  onConfirm: () {
    // Confirm callback
  },
  onCancel: () {
    // Cancel callback
  },
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
                DSSnackbar.show(context, message: 'Dialog code copied to clipboard!', variant: DSSnackbarVariant.success);
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
      {'name': 'context', 'type': 'BuildContext', 'default': 'required', 'desc': 'BuildContext used to present modal via showGeneralDialog.'},
      {'name': 'title', 'type': 'String', 'default': 'required', 'desc': 'Bold header title displayed inside modal.'},
      {'name': 'message', 'type': 'String', 'default': 'required', 'desc': 'Body message paragraph.'},
      {'name': 'confirmText', 'type': 'String?', 'default': '"Confirm"', 'desc': 'Primary confirm button text. If null, confirm button is omitted.'},
      {'name': 'cancelText', 'type': 'String?', 'default': '"Cancel"', 'desc': 'Outline cancel button text. If null, cancel button is omitted.'},
      {'name': 'icon', 'type': 'Widget?', 'default': 'null', 'desc': 'Optional header icon displayed centered above title.'},
      {'name': 'onConfirm', 'type': 'VoidCallback?', 'default': 'null', 'desc': 'Callback function executed on confirm click before closing dialog.'},
      {'name': 'onCancel', 'type': 'VoidCallback?', 'default': 'null', 'desc': 'Callback function executed on cancel click before closing dialog.'},
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
