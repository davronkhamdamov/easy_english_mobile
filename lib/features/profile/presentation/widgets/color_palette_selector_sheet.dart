import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';

/// Interactive modal bottom sheet for choosing minimal and monochromatic color palettes.
class ColorPaletteSelectorSheet extends StatefulWidget {
  final ThemeController? themeController;

  const ColorPaletteSelectorSheet({
    super.key,
    this.themeController,
  });

  /// Static helper to display the sheet from any context.
  static Future<void> show(BuildContext context) {
    final theme = Theme.of(context);
    final themeController = ThemeController.maybeOf(context);

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => ColorPaletteSelectorSheet(
        themeController: themeController,
      ),
    );
  }

  @override
  State<ColorPaletteSelectorSheet> createState() =>
      _ColorPaletteSelectorSheetState();
}

class _ColorPaletteSelectorSheetState extends State<ColorPaletteSelectorSheet> {
  late AppColorPalette _selectedPalette;

  @override
  void initState() {
    super.initState();
    _selectedPalette =
        widget.themeController?.palette ?? AppColors.currentPalette;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.colorScheme.onSurface;
    final subtextColor = theme.colorScheme.onSurfaceVariant;
    final activeController =
        widget.themeController ?? ThemeController.maybeOf(context);

    return SafeArea(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.82,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: subtextColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header title & subtitle
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.palette_outlined,
                    color: theme.colorScheme.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Color Palette',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Curated minimal & monochromatic color schemes',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: subtextColor,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Palette options list
            Expanded(
              child: ListView.separated(
                itemCount: AppColorPalette.allPalettes.length,
                separatorBuilder: (ctx, i) => const SizedBox(height: 10),
                itemBuilder: (ctx, index) {
                  final palette = AppColorPalette.allPalettes[index];
                  final isSelected = _selectedPalette.id == palette.id;

                  return _buildPaletteCard(
                    context: ctx,
                    palette: palette,
                    isSelected: isSelected,
                    isDark: isDark,
                    theme: theme,
                    onTap: () {
                      setState(() {
                        _selectedPalette = palette;
                      });
                      activeController?.setPalette(palette);
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Done action button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Apply & Done',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaletteCard({
    required BuildContext context,
    required AppColorPalette palette,
    required bool isSelected,
    required bool isDark,
    required ThemeData theme,
    required VoidCallback onTap,
  }) {
    final textColor = theme.colorScheme.onSurface;
    final subtextColor = theme.colorScheme.onSurfaceVariant;
    final primaryColor = theme.colorScheme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withValues(alpha: isDark ? 0.16 : 0.07)
              : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? primaryColor
                : theme.colorScheme.outline.withValues(alpha: 0.25),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Palette Swatch Preview Dots
            _buildSwatchStack(palette, isDark),
            const SizedBox(width: 14),

            // Palette Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        palette.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? primaryColor.withValues(alpha: isDark ? 0.25 : 0.12)
                              : subtextColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          palette.badge,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? primaryColor : subtextColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    palette.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: subtextColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // Selected checkmark or unselected radio
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: primaryColor,
                size: 24,
              )
            else
              Icon(
                Icons.radio_button_unchecked,
                color: subtextColor.withValues(alpha: 0.4),
                size: 22,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwatchStack(AppColorPalette palette, bool isDark) {
    final colors = palette.previewColors;

    return Container(
      width: 44,
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B1D22) : const Color(0xFFEDEDED),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08),
        ),
      ),
      child: GridView.count(
        crossAxisCount: 2,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 3,
        crossAxisSpacing: 3,
        children: colors.map((c) {
          return Container(
            decoration: BoxDecoration(
              color: c,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.black.withValues(alpha: 0.1),
                width: 0.5,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
