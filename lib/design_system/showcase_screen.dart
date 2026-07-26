import 'package:flutter/material.dart';
import 'design_system.dart';

class DSShowcaseScreen extends StatefulWidget {
  final ThemeController themeController;

  const DSShowcaseScreen({super.key, required this.themeController});

  @override
  State<DSShowcaseScreen> createState() => _DSShowcaseScreenState();
}

class _DSShowcaseScreenState extends State<DSShowcaseScreen> {
  bool _globalLoading = false;
  bool _globalDisabled = false;
  bool _globalError = false;

  final TextEditingController _textController = TextEditingController(text: 'John Doe');
  final TextEditingController _emailController = TextEditingController(text: 'user@example.com');
  final TextEditingController _passController = TextEditingController(text: 'SecretPassword123');
  final TextEditingController _searchController = TextEditingController(text: 'IELTS Speaking topics');

  @override
  void dispose() {
    _textController.dispose();
    _emailController.dispose();
    _passController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.themeController.isDarkMode;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Modern Animated Sliver App Bar
          SliverAppBar(
            floating: true,
            pinned: true,
            expandedHeight: 120.0,
            backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            surfaceTintColor: Colors.transparent,
            shadowColor: Colors.black12,
            elevation: 2,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: AppSpacing.lg, bottom: AppSpacing.md),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xs + 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: const Icon(Icons.palette_rounded, color: Colors.white, size: 18),
                  ),
                  AppSpacing.gapHorizontalSm,
                  Text(
                    'Design System Spec',
                    style: AppTypography.h2.copyWith(
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              // Theme Mode Switcher Button
              IconButton(
                onPressed: () {
                  widget.themeController.toggleTheme();
                },
                tooltip: 'Toggle Light/Dark Theme',
                icon: AnimatedSwitcher(
                  duration: AppAnimations.fast,
                  transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                  child: Icon(
                    isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                    key: ValueKey<bool>(isDark),
                    color: isDark ? AppColors.warning : AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
            ],
          ),

          // Main Showcase Content List
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Interactive State Controls Header Bar
                _buildStateControlsCard(isDark),
                AppSpacing.gapVerticalLg,

                // Section 1: Tokens Foundation
                _buildSectionHeader('1. Design Tokens & Styling Foundation', Icons.token_rounded, isDark),
                AppSpacing.gapVerticalMd,
                _buildColorTokensGallery(isDark),
                AppSpacing.gapVerticalMd,
                _buildTypographyGallery(isDark),
                AppSpacing.gapVerticalLg,

                // Section 2: Button Components
                _buildSectionHeader('2.1 Button Components (DSButton)', Icons.smart_button_rounded, isDark),
                AppSpacing.gapVerticalMd,
                _buildButtonVariantsGallery(isDark),
                AppSpacing.gapVerticalMd,
                _buildButtonSizesGallery(isDark),
                AppSpacing.gapVerticalLg,

                // Section 3: Input Components
                _buildSectionHeader('2.2 Input & Form Fields (DSInput)', Icons.input_rounded, isDark),
                AppSpacing.gapVerticalMd,
                _buildInputFieldsGallery(isDark),
                AppSpacing.gapVerticalLg,

                // Section 4: Card Components
                _buildSectionHeader('2.3 Card Components (DSCard)', Icons.style_rounded, isDark),
                AppSpacing.gapVerticalMd,
                _buildCardsGallery(isDark),
                AppSpacing.gapVerticalLg,

                // Section 5: Badges, Dialogs & Toast Notifications
                _buildSectionHeader('2.4 Feedback & Overlays (Badge, Dialog, Toast)', Icons.notifications_active_rounded, isDark),
                AppSpacing.gapVerticalMd,
                _buildFeedbackGallery(isDark),
                AppSpacing.gapVerticalXl,
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStateControlsCard(bool isDark) {
    return DSCard(
      variant: DSCardVariant.glass,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tune_rounded, color: AppColors.primary, size: 20),
              AppSpacing.gapHorizontalSm,
              Text(
                'Interactive State Switcher',
                style: AppTypography.h3.copyWith(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
            ],
          ),
          AppSpacing.gapVerticalXs,
          Text(
            'Toggle state controls to test real-time component reactivity across all variants.',
            style: AppTypography.bodySm.copyWith(
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          AppSpacing.gapVerticalMd,
          Wrap(
            spacing: AppSpacing.lg,
            runSpacing: AppSpacing.sm,
            children: [
              _buildFilterChip('Loading Spinner', _globalLoading, (val) => setState(() => _globalLoading = val)),
              _buildFilterChip('Disabled State', _globalDisabled, (val) => setState(() => _globalDisabled = val)),
              _buildFilterChip('Error Highlight', _globalError, (val) => setState(() => _globalError = val)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool value, ValueChanged<bool> onChanged) {
    return FilterChip(
      selected: value,
      label: Text(label),
      selectedColor: AppColors.primaryLight,
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: value ? AppColors.primary : null,
        fontWeight: value ? FontWeight.w600 : FontWeight.w400,
      ),
      onSelected: onChanged,
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        AppSpacing.gapHorizontalSm,
        Expanded(
          child: Text(
            title,
            style: AppTypography.h2.copyWith(
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildColorTokensGallery(bool isDark) {
    return DSCard(
      variant: DSCardVariant.outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Color Palette Tokens (HSL Tailored)',
            style: AppTypography.label.copyWith(
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          AppSpacing.gapVerticalMd,
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              _buildColorSwatch('Primary', AppColors.primary),
              _buildColorSwatch('Secondary', AppColors.secondary),
              _buildColorSwatch('Success', AppColors.success),
              _buildColorSwatch('Warning', AppColors.warning),
              _buildColorSwatch('Danger', AppColors.danger),
              _buildColorSwatch(
                'Surface',
                isDark ? AppColors.darkSurface : AppColors.lightSurface,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColorSwatch(String name, Color color) {
    return Column(
      children: [
        AnimatedContainer(
          duration: AppAnimations.fast,
          width: 64,
          height: 48,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            boxShadow: AppShadows.sm(false),
            border: Border.all(color: Colors.white24, width: 1),
          ),
        ),
        AppSpacing.gapVerticalXs,
        Text(name, style: AppTypography.caption),
      ],
    );
  }

  Widget _buildTypographyGallery(bool isDark) {
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    return DSCard(
      variant: DSCardVariant.outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Typography Scale', style: AppTypography.label.copyWith(color: textColor)),
          AppSpacing.gapVerticalSm,
          Text('Display Heading (32px)', style: AppTypography.display.copyWith(color: textColor)),
          Text('Heading 1 (24px)', style: AppTypography.h1.copyWith(color: textColor)),
          Text('Heading 2 (20px)', style: AppTypography.h2.copyWith(color: textColor)),
          Text('Heading 3 (18px)', style: AppTypography.h3.copyWith(color: textColor)),
          Text('Body Medium (16px) - Modern & Clean typography tokens', style: AppTypography.bodyMd.copyWith(color: textColor)),
          Text('Caption Small (12px) - Helper & micro labels', style: AppTypography.caption.copyWith(color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted)),
        ],
      ),
    );
  }

  Widget _buildButtonVariantsGallery(bool isDark) {
    return DSCard(
      variant: DSCardVariant.elevated,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Variants (Hover over buttons for glow/lift micro-animations)',
            style: AppTypography.label.copyWith(
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          AppSpacing.gapVerticalMd,
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              DSButton(
                text: 'Primary Button',
                variant: DSButtonVariant.primary,
                isLoading: _globalLoading,
                disabled: _globalDisabled,
                leftIcon: const Icon(Icons.add_rounded),
                onPressed: () => _showActionToast('Primary button tapped!'),
              ),
              DSButton(
                text: 'Secondary',
                variant: DSButtonVariant.secondary,
                isLoading: _globalLoading,
                disabled: _globalDisabled,
                onPressed: () => _showActionToast('Secondary button tapped!'),
              ),
              DSButton(
                text: 'Outline',
                variant: DSButtonVariant.outline,
                isLoading: _globalLoading,
                disabled: _globalDisabled,
                rightIcon: const Icon(Icons.arrow_forward_rounded),
                onPressed: () => _showActionToast('Outline button tapped!'),
              ),
              DSButton(
                text: 'Ghost',
                variant: DSButtonVariant.ghost,
                isLoading: _globalLoading,
                disabled: _globalDisabled,
                onPressed: () => _showActionToast('Ghost button tapped!'),
              ),
              DSButton(
                text: 'Danger',
                variant: DSButtonVariant.danger,
                isLoading: _globalLoading,
                disabled: _globalDisabled,
                leftIcon: const Icon(Icons.delete_outline_rounded),
                onPressed: () => _showActionToast('Danger button tapped!'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildButtonSizesGallery(bool isDark) {
    return DSCard(
      variant: DSCardVariant.elevated,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Button Sizes & Full-Width Layout',
            style: AppTypography.label.copyWith(
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          AppSpacing.gapVerticalMd,
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              DSButton(
                text: 'Small (36px)',
                size: DSButtonSize.sm,
                isLoading: _globalLoading,
                disabled: _globalDisabled,
                onPressed: () {},
              ),
              DSButton(
                text: 'Medium (44px)',
                size: DSButtonSize.md,
                isLoading: _globalLoading,
                disabled: _globalDisabled,
                onPressed: () {},
              ),
              DSButton(
                text: 'Large (52px)',
                size: DSButtonSize.lg,
                isLoading: _globalLoading,
                disabled: _globalDisabled,
                onPressed: () {},
              ),
            ],
          ),
          AppSpacing.gapVerticalMd,
          DSButton(
            text: 'Full Width Action Button',
            fullWidth: true,
            size: DSButtonSize.lg,
            isLoading: _globalLoading,
            disabled: _globalDisabled,
            onPressed: () => _showActionToast('Full width button clicked!'),
          ),
        ],
      ),
    );
  }

  Widget _buildInputFieldsGallery(bool isDark) {
    return Column(
      children: [
        DSInput(
          label: 'User Name',
          placeholder: 'Enter your full name',
          controller: _textController,
          disabled: _globalDisabled,
          errorText: _globalError ? 'Name is required' : null,
          helperText: 'Enter your legal first and last name',
        ),
        AppSpacing.gapVerticalMd,
        DSInput(
          label: 'Email Address',
          type: DSInputType.email,
          placeholder: 'name@example.com',
          controller: _emailController,
          disabled: _globalDisabled,
          errorText: _globalError ? 'Invalid email address format' : null,
        ),
        AppSpacing.gapVerticalMd,
        DSInput(
          label: 'Account Password',
          type: DSInputType.password,
          placeholder: '••••••••••••',
          controller: _passController,
          disabled: _globalDisabled,
          errorText: _globalError ? 'Password must be at least 8 characters' : null,
        ),
        AppSpacing.gapVerticalMd,
        DSInput(
          label: 'Search Catalog',
          type: DSInputType.search,
          placeholder: 'Type search query...',
          controller: _searchController,
          disabled: _globalDisabled,
          onClear: () => _showActionToast('Search cleared'),
        ),
      ],
    );
  }

  Widget _buildCardsGallery(bool isDark) {
    return Column(
      children: [
        // Elevated Card
        DSCard(
          variant: DSCardVariant.elevated,
          onTap: () => _showActionToast('Elevated Card clicked!'),
          header: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Elevated Card (Clickable)',
                style: AppTypography.h3.copyWith(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              const DSBadge(label: 'Popular', variant: DSBadgeVariant.primary),
            ],
          ),
          body: Text(
            'This elevated card demonstrates smooth zoom and glow animation on press/hover. Tap or hover over me!',
            style: AppTypography.bodySm.copyWith(
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          footer: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              DSButton(
                text: 'View Details',
                size: DSButtonSize.sm,
                variant: DSButtonVariant.ghost,
                onPressed: () {},
              ),
            ],
          ),
        ),
        AppSpacing.gapVerticalMd,

        // Outlined Card
        DSCard(
          variant: DSCardVariant.outlined,
          header: Text(
            'Outlined Card',
            style: AppTypography.h3.copyWith(
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          body: Text(
            'Clean vector outlined border container matching border design tokens.',
            style: AppTypography.bodySm.copyWith(
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
        ),
        AppSpacing.gapVerticalMd,

        // Glassmorphism Card
        DSCard(
          variant: DSCardVariant.glass,
          onTap: () => _showActionToast('Glass Card tapped!'),
          header: Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, color: AppColors.secondary, size: 20),
              AppSpacing.gapHorizontalSm,
              Text(
                'Glassmorphism Card Backdrop',
                style: AppTypography.h3.copyWith(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
            ],
          ),
          body: Text(
            'Features real-time ImageFilter.blur with translucent backdrop and subtle gradient borders.',
            style: AppTypography.bodySm.copyWith(
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeedbackGallery(bool isDark) {
    return DSCard(
      variant: DSCardVariant.outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Status Badges & Interactive Overlays',
            style: AppTypography.label.copyWith(
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          AppSpacing.gapVerticalMd,
          const Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              DSBadge(label: 'Active', variant: DSBadgeVariant.success, icon: Icon(Icons.check_circle)),
              DSBadge(label: 'Pending', variant: DSBadgeVariant.warning),
              DSBadge(label: 'Failed', variant: DSBadgeVariant.danger),
              DSBadge(label: 'Featured', variant: DSBadgeVariant.primary),
              DSBadge(label: 'Draft', variant: DSBadgeVariant.neutral),
              DSBadge(label: 'Outlined', variant: DSBadgeVariant.primary, isOutlined: true),
            ],
          ),
          AppSpacing.gapVerticalLg,
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              DSButton(
                text: 'Show Glass Dialog',
                variant: DSButtonVariant.outline,
                onPressed: () {
                  DSDialog.show(
                    context: context,
                    icon: Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.stars_rounded, color: AppColors.primary, size: 32),
                    ),
                    title: 'Design System Modal',
                    message: 'This interactive dialog features smooth backdrop blur and scale-in spring micro-animation.',
                    onConfirm: () => _showActionToast('Confirmed!'),
                  );
                },
              ),
              DSButton(
                text: 'Show Toast Notification',
                variant: DSButtonVariant.secondary,
                onPressed: () {
                  DSSnackbar.show(
                    context,
                    title: 'System Notification',
                    message: 'Design system components rendered cleanly with zero errors!',
                    variant: DSSnackbarVariant.success,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showActionToast(String message) {
    DSSnackbar.show(
      context,
      message: message,
      variant: DSSnackbarVariant.info,
    );
  }
}
