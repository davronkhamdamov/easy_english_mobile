import 'package:flutter/material.dart';

/// Activity Progress Card ("Card 5" / Last progress card from image).
/// Features top title and a full-width monochrome activity matrix of squares.
class SkillActivityProgressCardWidget extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;

  const SkillActivityProgressCardWidget({
    super.key,
    this.title = 'Learning activity',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBgColor = theme.colorScheme.surface;
    final textPrimaryColor = theme.colorScheme.onSurface;

    final cardBorder = Border.all(
      color: theme.colorScheme.outline.withValues(alpha: isDark ? 0.15 : 0.25),
      width: 1,
    );
    final cardShadow = isDark
        ? null
        : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ];

    return Container(
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(22),
        border: cardBorder,
        boxShadow: cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Row: Learning activity
                Text(
                  title,
                  style: TextStyle(
                    color: textPrimaryColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 16),

                // Main Content: Full-width Monochrome Activity Squares Matrix
                _buildActivityGrid(theme, isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityGrid(ThemeData theme, bool isDark) {
    // 5 rows x 17 columns activity matrix
    final List<List<int>> matrixData = [
      [0, 1, 0, 2, 0, 1, 3, 0, 1, 0, 2, 1, 0, 3, 0, 1, 2],
      [1, 0, 3, 0, 2, 0, 0, 2, 0, 3, 0, 0, 1, 0, 2, 0, 3],
      [0, 2, 0, 1, 0, 3, 1, 0, 2, 0, 1, 3, 0, 2, 0, 1, 0],
      [3, 0, 1, 0, 2, 0, 3, 1, 0, 2, 0, 0, 3, 1, 3, 0, 2],
      [0, 1, 0, 0, 3, 3, 0, 2, 1, 0, 3, 1, 0, 0, 2, 3, 1],
    ];

    Color getTileColor(int level) {
      if (level == 0) {
        return isDark
            ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35)
            : theme.colorScheme.outline.withValues(alpha: 0.15);
      } else if (level == 1) {
        return theme.colorScheme.onSurface.withValues(alpha: 0.25);
      } else if (level == 2) {
        return theme.colorScheme.onSurface.withValues(alpha: 0.55);
      } else if (level == 3) {
        return theme.colorScheme.onSurface.withValues(alpha: 0.85);
      } else {
        return theme.colorScheme.onSurface;
      }
    }

    return Column(
      children: matrixData.map((row) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: row.map((level) {
              final color = getTileColor(level);
              return Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}
