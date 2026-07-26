import 'package:flutter/material.dart';
import 'design_system.dart';

enum ShowcasePage {
  overview,
  button,
  input,
  card,
  badge,
  snackbar,
  dialog,
  tokens,
}

class DSShowcaseScreen extends StatefulWidget {
  final ThemeController themeController;

  const DSShowcaseScreen({super.key, required this.themeController});

  @override
  State<DSShowcaseScreen> createState() => _DSShowcaseScreenState();
}

class _DSShowcaseScreenState extends State<DSShowcaseScreen> {
  ShowcasePage _activePage = ShowcasePage.overview;

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
    switch (_activePage) {
      case ShowcasePage.button:
        return DSButtonPage(
          themeController: widget.themeController,
          onBackToOverview: () => setState(() => _activePage = ShowcasePage.overview),
        );
      case ShowcasePage.input:
        return DSInputPage(
          themeController: widget.themeController,
          onBackToOverview: () => setState(() => _activePage = ShowcasePage.overview),
        );
      case ShowcasePage.card:
        return DSCardPage(
          themeController: widget.themeController,
          onBackToOverview: () => setState(() => _activePage = ShowcasePage.overview),
        );
      case ShowcasePage.badge:
        return DSBadgePage(
          themeController: widget.themeController,
          onBackToOverview: () => setState(() => _activePage = ShowcasePage.overview),
        );
      case ShowcasePage.snackbar:
        return DSSnackbarPage(
          themeController: widget.themeController,
          onBackToOverview: () => setState(() => _activePage = ShowcasePage.overview),
        );
      case ShowcasePage.dialog:
        return DSDialogPage(
          themeController: widget.themeController,
          onBackToOverview: () => setState(() => _activePage = ShowcasePage.overview),
        );
      case ShowcasePage.tokens:
        return DSTokensPage(
          themeController: widget.themeController,
          onBackToOverview: () => setState(() => _activePage = ShowcasePage.overview),
        );
      case ShowcasePage.overview:
        return _buildOverviewScreen(context);
    }
  }

  Widget _buildOverviewScreen(BuildContext context) {
    final isDark = widget.themeController.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
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
                // Component Navigator Hub Header Box
                _buildNavigationHubCard(isDark),
                AppSpacing.gapVerticalLg,

                // Interactive State Controls Header Bar
                _buildStateControlsCard(isDark),
                AppSpacing.gapVerticalLg,

                // Section 1: Tokens Foundation
                _buildSectionHeader('1. Design Tokens & Styling Foundation', Icons.token_rounded, isDark, ShowcasePage.tokens),
                AppSpacing.gapVerticalMd,
                _buildColorTokensGallery(isDark),
                AppSpacing.gapVerticalMd,
                _buildTypographyGallery(isDark),
                AppSpacing.gapVerticalLg,

                // Section 2: Button Components
                _buildSectionHeader('2.1 Button Components (DSButton)', Icons.smart_button_rounded, isDark, ShowcasePage.button),
                AppSpacing.gapVerticalMd,
                _buildButtonVariantsGallery(isDark),
                AppSpacing.gapVerticalMd,
                _buildButtonSizesGallery(isDark),
                AppSpacing.gapVerticalLg,

                // Section 3: Input Components
                _buildSectionHeader('2.2 Input & Form Fields (DSInput)', Icons.input_rounded, isDark, ShowcasePage.input),
                AppSpacing.gapVerticalMd,
                _buildInputFieldsGallery(isDark),
                AppSpacing.gapVerticalLg,

                // Section 4: Card Components
                _buildSectionHeader('2.3 Card Container Components (DSCard)', Icons.crop_portrait_rounded, isDark, ShowcasePage.card),
                AppSpacing.gapVerticalMd,
                _buildCardVariantsGallery(isDark),
                AppSpacing.gapVerticalLg,

                // Section 5: Badges & Overlays
                _buildSectionHeader('2.4 Badges & Overlays (DSBadge, DSSnackbar, DSDialog)', Icons.auto_awesome_motion_rounded, isDark, null),
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

  // --- NAVIGATION HUB GRID ---
  Widget _buildNavigationHubCard(bool isDark) {
    final navItems = [
      {'page': ShowcasePage.button, 'title': 'DSButton', 'desc': '5 Variants • 3 Sizes • Animations', 'icon': Icons.smart_button_rounded, 'color': AppColors.primary},
      {'page': ShowcasePage.input, 'title': 'DSInput', 'desc': 'Text • Password • Email • Search', 'icon': Icons.input_rounded, 'color': AppColors.secondary},
      {'page': ShowcasePage.card, 'title': 'DSCard', 'desc': 'Elevated • Outlined • Glassmorphism', 'icon': Icons.crop_portrait_rounded, 'color': AppColors.success},
      {'page': ShowcasePage.badge, 'title': 'DSBadge', 'desc': 'Pills • Status Colors • Outlined', 'icon': Icons.stars_rounded, 'color': AppColors.warning},
      {'page': ShowcasePage.snackbar, 'title': 'DSSnackbar', 'desc': 'Success • Warning • Danger • Info', 'icon': Icons.notifications_active_rounded, 'color': AppColors.danger},
      {'page': ShowcasePage.dialog, 'title': 'DSDialog', 'desc': 'Glass Modal • Backdrop Blur', 'icon': Icons.open_in_new_rounded, 'color': AppColors.primaryHover},
      {'page': ShowcasePage.tokens, 'title': 'Design Tokens', 'desc': 'Colors • Typography • Shadows', 'icon': Icons.token_rounded, 'color': AppColors.secondary},
    ];

    return DSCard(
      variant: DSCardVariant.elevated,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Component Investigation Hub',
                      style: AppTypography.h2.copyWith(
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    Text(
                      'Select a component below to open its dedicated investigation page with interactive playground & API specs.',
                      style: AppTypography.caption.copyWith(
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const DSBadge(label: '7 DEDICATED PAGES AVAILABLE', variant: DSBadgeVariant.primary),
            ],
          ),
          AppSpacing.gapVerticalLg,

          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: navItems.map((item) {
              final page = item['page'] as ShowcasePage;
              final title = item['title'] as String;
              final desc = item['desc'] as String;
              final icon = item['icon'] as IconData;
              final color = item['color'] as Color;

              return InkWell(
                onTap: () => setState(() => _activePage = page),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                child: Container(
                  width: 215,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.xs + 2),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                            ),
                            child: Icon(icon, color: color, size: 20),
                          ),
                          const Icon(Icons.arrow_forward_rounded, size: 16, color: Colors.grey),
                        ],
                      ),
                      AppSpacing.gapVerticalSm,
                      Text(
                        title,
                        style: AppTypography.label.copyWith(
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        desc,
                        style: AppTypography.caption.copyWith(
                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStateControlsCard(bool isDark) {
    return DSCard(
      variant: DSCardVariant.outlined,
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.tune_rounded, color: AppColors.primary, size: 20),
              AppSpacing.gapHorizontalSm,
              Text(
                'Global Showcase State Controls:',
                style: AppTypography.label.copyWith(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
            ],
          ),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              FilterChip(
                label: const Text('Loading Spinner'),
                selected: _globalLoading,
                onSelected: (val) => setState(() => _globalLoading = val),
                selectedColor: AppColors.primaryLight,
                checkmarkColor: AppColors.primary,
              ),
              FilterChip(
                label: const Text('Disabled State'),
                selected: _globalDisabled,
                onSelected: (val) => setState(() => _globalDisabled = val),
                selectedColor: AppColors.primaryLight,
                checkmarkColor: AppColors.primary,
              ),
              FilterChip(
                label: const Text('Error Validation'),
                selected: _globalError,
                onSelected: (val) => setState(() => _globalError = val),
                selectedColor: AppColors.dangerLight,
                checkmarkColor: AppColors.danger,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, bool isDark, ShowcasePage? page) {
    return Row(
      children: [
        Icon(icon, size: 22, color: AppColors.primary),
        AppSpacing.gapHorizontalSm,
        Text(
          title,
          style: AppTypography.h2.copyWith(
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        const Spacer(),
        if (page != null)
          DSButton(
            text: 'Investigate Page →',
            variant: DSButtonVariant.ghost,
            size: DSButtonSize.sm,
            onPressed: () => setState(() => _activePage = page),
          ),
      ],
    );
  }

  Widget _buildColorTokensGallery(bool isDark) {
    return DSCard(
      variant: DSCardVariant.elevated,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Color Palette Tokens (Light/Dark Reactive)',
            style: AppTypography.label.copyWith(
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          AppSpacing.gapVerticalMd,
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.sm,
            children: [
              _buildColorChip('Primary', AppColors.primary),
              _buildColorChip('Secondary', AppColors.secondary),
              _buildColorChip('Success', AppColors.success),
              _buildColorChip('Warning', AppColors.warning),
              _buildColorChip('Danger', AppColors.danger),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColorChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTypographyGallery(bool isDark) {
    return DSCard(
      variant: DSCardVariant.elevated,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Display Title (32px Bold)', style: AppTypography.display.copyWith(color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
          Text('H1 Section Header (24px W700)', style: AppTypography.h1.copyWith(color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
          Text('H2 Subsection Header (20px W600)', style: AppTypography.h2.copyWith(color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
          Text('Body Medium (16px Regular) — Clean legible typography hierarchy.', style: AppTypography.bodyMd.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
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
          Text('Button Variants (Primary, Secondary, Outline, Ghost, Danger)', style: AppTypography.label.copyWith(color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
          AppSpacing.gapVerticalMd,
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              DSButton(text: 'Primary', variant: DSButtonVariant.primary, isLoading: _globalLoading, disabled: _globalDisabled, onPressed: () => _showActionToast('Primary clicked')),
              DSButton(text: 'Secondary', variant: DSButtonVariant.secondary, isLoading: _globalLoading, disabled: _globalDisabled, onPressed: () => _showActionToast('Secondary clicked')),
              DSButton(text: 'Outline', variant: DSButtonVariant.outline, isLoading: _globalLoading, disabled: _globalDisabled, onPressed: () => _showActionToast('Outline clicked')),
              DSButton(text: 'Ghost', variant: DSButtonVariant.ghost, isLoading: _globalLoading, disabled: _globalDisabled, onPressed: () => _showActionToast('Ghost clicked')),
              DSButton(text: 'Danger', variant: DSButtonVariant.danger, isLoading: _globalLoading, disabled: _globalDisabled, onPressed: () => _showActionToast('Danger clicked')),
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
          Text('Button Sizes (Small: 36px, Medium: 44px, Large: 52px)', style: AppTypography.label.copyWith(color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
          AppSpacing.gapVerticalMd,
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              DSButton(text: 'Small (sm)', size: DSButtonSize.sm, leftIcon: const Icon(Icons.flash_on), onPressed: () {}),
              DSButton(text: 'Medium (md)', size: DSButtonSize.md, leftIcon: const Icon(Icons.flash_on), onPressed: () {}),
              DSButton(text: 'Large (lg)', size: DSButtonSize.lg, leftIcon: const Icon(Icons.flash_on), onPressed: () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputFieldsGallery(bool isDark) {
    return DSCard(
      variant: DSCardVariant.elevated,
      child: Column(
        children: [
          DSInput(
            label: 'Full Name (Text Input)',
            placeholder: 'Enter full name...',
            controller: _textController,
            disabled: _globalDisabled,
            errorText: _globalError ? 'Invalid name provided' : null,
          ),
          AppSpacing.gapVerticalMd,
          DSInput(
            label: 'Email Address (Email Input)',
            placeholder: 'student@ielts.com',
            type: DSInputType.email,
            controller: _emailController,
            disabled: _globalDisabled,
          ),
          AppSpacing.gapVerticalMd,
          DSInput(
            label: 'Account Password (Password with Toggle Eye)',
            placeholder: '••••••••••••',
            type: DSInputType.password,
            controller: _passController,
            disabled: _globalDisabled,
          ),
          AppSpacing.gapVerticalMd,
          DSInput(
            label: 'Search Query (Search with Clear Button)',
            placeholder: 'Search topics...',
            type: DSInputType.search,
            controller: _searchController,
            disabled: _globalDisabled,
          ),
        ],
      ),
    );
  }

  Widget _buildCardVariantsGallery(bool isDark) {
    return Wrap(
      spacing: AppSpacing.lg,
      runSpacing: AppSpacing.lg,
      children: [
        DSCard(
          variant: DSCardVariant.elevated,
          onTap: () => _showActionToast('Elevated Card tapped!'),
          header: Row(
            children: [
              const Icon(Icons.layers_rounded, color: AppColors.primary, size: 20),
              AppSpacing.gapHorizontalSm,
              Text('Elevated Card Variant', style: AppTypography.h3.copyWith(color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
            ],
          ),
          body: Text('Elevated surface with smooth ambient shadow and hover lift animation.', style: AppTypography.bodySm.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
        ),
        DSCard(
          variant: DSCardVariant.outlined,
          onTap: () => _showActionToast('Outlined Card tapped!'),
          header: Row(
            children: [
              const Icon(Icons.border_style_rounded, color: AppColors.warning, size: 20),
              AppSpacing.gapHorizontalSm,
              Text('Outlined Card Variant', style: AppTypography.h3.copyWith(color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
            ],
          ),
          body: Text('Clean flat border container with subtle hover border highlight.', style: AppTypography.bodySm.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
        ),
        DSCard(
          variant: DSCardVariant.glass,
          onTap: () => _showActionToast('Glass Card tapped!'),
          header: Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, color: AppColors.secondary, size: 20),
              AppSpacing.gapHorizontalSm,
              Text('Glassmorphism Card Backdrop', style: AppTypography.h3.copyWith(color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
            ],
          ),
          body: Text('Features real-time ImageFilter.blur with translucent backdrop and subtle gradient borders.', style: AppTypography.bodySm.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Status Badges & Interactive Overlays', style: AppTypography.label.copyWith(color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
              Row(
                children: [
                  DSButton(
                    text: 'Badge Page →',
                    variant: DSButtonVariant.ghost,
                    size: DSButtonSize.sm,
                    onPressed: () => setState(() => _activePage = ShowcasePage.badge),
                  ),
                  DSButton(
                    text: 'Snackbar Page →',
                    variant: DSButtonVariant.ghost,
                    size: DSButtonSize.sm,
                    onPressed: () => setState(() => _activePage = ShowcasePage.snackbar),
                  ),
                  DSButton(
                    text: 'Dialog Page →',
                    variant: DSButtonVariant.ghost,
                    size: DSButtonSize.sm,
                    onPressed: () => setState(() => _activePage = ShowcasePage.dialog),
                  ),
                ],
              ),
            ],
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
