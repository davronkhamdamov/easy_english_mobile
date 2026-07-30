import 'package:flutter/material.dart';
import '../design_system.dart';

class DSTokensPage extends StatefulWidget {
  final ThemeController themeController;
  final VoidCallback? onBackToOverview;

  const DSTokensPage({
    super.key,
    required this.themeController,
    this.onBackToOverview,
  });

  @override
  State<DSTokensPage> createState() => _DSTokensPageState();
}

class _DSTokensPageState extends State<DSTokensPage> {
  String _sampleTypographyText = 'The quick brown fox jumps over the lazy dog';

  @override
  Widget build(BuildContext context) {
    return ComponentPageWrapper(
      title: 'Design Tokens',
      subtitle: 'Color palettes, typography scale, spacing rules, shadows & animation tokens',
      category: 'Foundation',
      themeController: widget.themeController,
      onBackToOverview: widget.onBackToOverview,
      playground: _buildColorPalette(context),
      matrix: _buildTypographyScale(context),
      codeSnippet: _buildSpacingAndRadii(context),
      specs: _buildShadowsAndAnimations(context),
    );
  }

  // --- 1. COLOR PALETTES (Playground Tab) ---
  Widget _buildColorPalette(BuildContext context) {
    final isDark = widget.themeController.isDarkMode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Color Token Swatches', style: AppTypography.h2.copyWith(color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
        AppSpacing.gapVerticalSm,
        Text('Click any color tile to copy its HEX value.', style: AppTypography.bodyMd.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
        AppSpacing.gapVerticalLg,

        // Brand Accents
        Text('Brand Accent Tokens', style: AppTypography.h3.copyWith(color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
        AppSpacing.gapVerticalMd,
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            _buildColorSwatch(context, 'Primary', AppColors.primary, '#6366F1'),
            _buildColorSwatch(context, 'Primary Hover', AppColors.primaryHover, '#4F46E5'),
            _buildColorSwatch(context, 'Primary Light', AppColors.primaryLight, '#EEF2FF', isDarkText: true),
            _buildColorSwatch(context, 'Secondary', AppColors.secondary, '#0EA5E9'),
            _buildColorSwatch(context, 'Secondary Light', AppColors.secondaryLight, '#E0F2FE', isDarkText: true),
          ],
        ),
        AppSpacing.gapVerticalLg,

        // Status Colors
        Text('Status & Feedback Tokens', style: AppTypography.h3.copyWith(color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
        AppSpacing.gapVerticalMd,
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            _buildColorSwatch(context, 'Success', AppColors.success, '#10B981'),
            _buildColorSwatch(context, 'Success Light', AppColors.successLight, '#ECFDF5', isDarkText: true),
            _buildColorSwatch(context, 'Warning', AppColors.warning, '#F59E0B'),
            _buildColorSwatch(context, 'Warning Light', AppColors.warningLight, '#FFFBEB', isDarkText: true),
            _buildColorSwatch(context, 'Danger', AppColors.danger, '#EF4444'),
            _buildColorSwatch(context, 'Danger Hover', AppColors.dangerHover, '#DC2626'),
            _buildColorSwatch(context, 'Danger Light', AppColors.dangerLight, '#FEF2F2', isDarkText: true),
          ],
        ),
        AppSpacing.gapVerticalLg,

        // Theme Surfaces
        Text('Surface & Border Tokens (${isDark ? "Dark Theme Active" : "Light Theme Active"})', style: AppTypography.h3.copyWith(color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
        AppSpacing.gapVerticalMd,
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: isDark
              ? [
                  _buildColorSwatch(context, 'Dark Background', AppColors.darkBackground, '#0B0F19'),
                  _buildColorSwatch(context, 'Dark Surface', AppColors.darkSurface, '#151D2A'),
                  _buildColorSwatch(context, 'Dark Surface Variant', AppColors.darkSurfaceVariant, '#1E293B'),
                  _buildColorSwatch(context, 'Dark Border', AppColors.darkBorder, '#2A364F'),
                  _buildColorSwatch(context, 'Dark Text Primary', AppColors.darkTextPrimary, '#F8FAFC'),
                  _buildColorSwatch(context, 'Dark Text Secondary', AppColors.darkTextSecondary, '#94A3B8'),
                ]
              : [
                  _buildColorSwatch(context, 'Light Background', AppColors.lightBackground, '#F8FAFC', isDarkText: true),
                  _buildColorSwatch(context, 'Light Surface', AppColors.lightSurface, '#FFFFFF', isDarkText: true),
                  _buildColorSwatch(context, 'Light Surface Variant', AppColors.lightSurfaceVariant, '#F1F5F9', isDarkText: true),
                  _buildColorSwatch(context, 'Light Border', AppColors.lightBorder, '#E2E8F0', isDarkText: true),
                  _buildColorSwatch(context, 'Light Text Primary', AppColors.lightTextPrimary, '#0F172A', isDarkText: true),
                  _buildColorSwatch(context, 'Light Text Secondary', AppColors.lightTextSecondary, '#475569', isDarkText: true),
                ],
        ),
      ],
    );
  }

  Widget _buildColorSwatch(BuildContext context, String name, Color color, String hex, {bool isDarkText = false}) {
    return GestureDetector(
      onTap: () {
        DSSnackbar.show(context, message: 'Copied $name ($hex) to clipboard', variant: DSSnackbarVariant.info);
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          width: 170,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: Colors.black12),
            boxShadow: AppShadows.sm(false),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: isDarkText ? Colors.black87 : Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                hex,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: isDarkText ? Colors.black54 : Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- 2. TYPOGRAPHY SCALE (Matrix Tab) ---
  Widget _buildTypographyScale(BuildContext context) {
    final isDark = widget.themeController.isDarkMode;

    final typeStyles = [
      {'name': 'Display', 'size': '32px', 'weight': 'Bold', 'style': AppTypography.display},
      {'name': 'H1 Title', 'size': '24px', 'weight': 'W700', 'style': AppTypography.h1},
      {'name': 'H2 Title', 'size': '20px', 'weight': 'W600', 'style': AppTypography.h2},
      {'name': 'H3 Title', 'size': '18px', 'weight': 'W600', 'style': AppTypography.h3},
      {'name': 'Body Large', 'size': '18px', 'weight': 'Regular', 'style': AppTypography.bodyLg},
      {'name': 'Body Medium', 'size': '16px', 'weight': 'Regular', 'style': AppTypography.bodyMd},
      {'name': 'Body Small', 'size': '14px', 'weight': 'Regular', 'style': AppTypography.bodySm},
      {'name': 'Caption', 'size': '12px', 'weight': 'Regular', 'style': AppTypography.caption},
      {'name': 'Label', 'size': '14px', 'weight': 'W600', 'style': AppTypography.label},
      {'name': 'Button', 'size': '14px', 'weight': 'W600', 'style': AppTypography.button},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Typography Scale Inspector', style: AppTypography.h2.copyWith(color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
        AppSpacing.gapVerticalSm,
        Text('Preview typography hierarchy with custom sample text.', style: AppTypography.bodyMd.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
        AppSpacing.gapVerticalLg,

        DSInput(
          label: 'Custom Sample Text',
          controller: TextEditingController(text: _sampleTypographyText),
          onChanged: (val) => setState(() => _sampleTypographyText = val.isEmpty ? 'Sample Text' : val),
        ),
        AppSpacing.gapVerticalLg,

        DSCard(
          variant: DSCardVariant.elevated,
          padding: EdgeInsets.zero,
          child: Column(
            children: typeStyles.map((item) {
              final style = (item['style'] as TextStyle).copyWith(
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              );

              return Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    SizedBox(
                      width: 140,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item['name'] as String, style: AppTypography.label.copyWith(color: AppColors.primary)),
                          Text('${item["size"]} • ${item["weight"]}', style: AppTypography.caption.copyWith(color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Text(_sampleTypographyText, style: style),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // --- 3. SPACING & RADII (Code Tab) ---
  Widget _buildSpacingAndRadii(BuildContext context) {
    final isDark = widget.themeController.isDarkMode;

    final spacings = [
      {'name': 'xxs', 'val': '2.0 px'},
      {'name': 'xs', 'val': '4.0 px'},
      {'name': 'sm', 'val': '8.0 px'},
      {'name': 'md', 'val': '16.0 px'},
      {'name': 'lg', 'val': '24.0 px'},
      {'name': 'xl', 'val': '32.0 px'},
      {'name': 'xxl', 'val': '48.0 px'},
    ];

    final radii = [
      {'name': 'radiusSm', 'val': '6.0 px'},
      {'name': 'radiusMd', 'val': '12.0 px'},
      {'name': 'radiusLg', 'val': '18.0 px'},
      {'name': 'radiusXl', 'val': '24.0 px'},
      {'name': 'radiusFull', 'val': '999.0 px'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Spacing Tokens Scale', style: AppTypography.h2.copyWith(color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
        AppSpacing.gapVerticalMd,
        DSCard(
          variant: DSCardVariant.elevated,
          child: Column(
            children: spacings.map((s) {
              final double px = double.parse(s['val']!.split(' ')[0]);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: Row(
                  children: [
                    SizedBox(width: 80, child: Text(s['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace'))),
                    SizedBox(width: 80, child: Text(s['val']!, style: const TextStyle(color: Colors.grey, fontFamily: 'monospace'))),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          height: 16,
                          width: px,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),

        AppSpacing.gapVerticalLg,
        Text('Border Radius Tokens Scale', style: AppTypography.h2.copyWith(color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
        AppSpacing.gapVerticalMd,
        DSCard(
          variant: DSCardVariant.elevated,
          child: Wrap(
            spacing: AppSpacing.lg,
            runSpacing: AppSpacing.lg,
            children: radii.map((r) {
              final double px = double.parse(r['val']!.split(' ')[0]);
              return Column(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(px > 100 ? 35 : px),
                    ),
                  ),
                  AppSpacing.gapVerticalXs,
                  Text(r['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  Text(r['val']!, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // --- 4. SHADOWS & ANIMATIONS (Specs Tab) ---
  Widget _buildShadowsAndAnimations(BuildContext context) {
    final isDark = widget.themeController.isDarkMode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Shadows & Elevation Scale', style: AppTypography.h2.copyWith(color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
        AppSpacing.gapVerticalMd,

        Wrap(
          spacing: AppSpacing.lg,
          runSpacing: AppSpacing.lg,
          children: [
            _buildShadowBox(isDark, 'Shadow SM', AppShadows.sm(isDark)),
            _buildShadowBox(isDark, 'Shadow MD', AppShadows.md(isDark)),
            _buildShadowBox(isDark, 'Shadow LG', AppShadows.lg(isDark)),
            _buildShadowBox(isDark, 'Primary Glow', AppShadows.glow(AppColors.primary, blurRadius: 16)),
            _buildShadowBox(isDark, 'Danger Glow', AppShadows.glow(AppColors.danger, blurRadius: 16)),
          ],
        ),

        AppSpacing.gapVerticalLg,
        Text('Micro-Animations Timings & Curves', style: AppTypography.h2.copyWith(color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
        AppSpacing.gapVerticalMd,

        DSCard(
          variant: DSCardVariant.elevated,
          child: Column(
            children: [
              _buildAnimRow('fast', '150 ms', 'Curves.easeOutCubic', 'Instant hover scale & button tap feedback'),
              const Divider(),
              _buildAnimRow('normal', '300 ms', 'Curves.easeInOutCubic', 'Color transitions & expansion panels'),
              const Divider(),
              _buildAnimRow('slow', '500 ms', 'Curves.easeOutBack', 'Modal entry spring animations & page transitions'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildShadowBox(bool isDark, String name, List<BoxShadow> shadows) {
    return Container(
      width: 140,
      height: 100,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        boxShadow: shadows,
      ),
      child: Center(
        child: Text(
          name,
          style: AppTypography.label.copyWith(
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildAnimRow(String name, String duration, String curve, String useCase) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace'))),
          Expanded(flex: 2, child: Text(duration, style: const TextStyle(color: AppColors.primary, fontFamily: 'monospace'))),
          Expanded(flex: 3, child: Text(curve, style: const TextStyle(color: Colors.grey, fontFamily: 'monospace'))),
          Expanded(flex: 4, child: Text(useCase, style: AppTypography.caption)),
        ],
      ),
    );
  }
}
