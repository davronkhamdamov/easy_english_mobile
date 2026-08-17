import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Activity Progress Card ("Card 5" / Last progress card from image).
/// Features top total/best stats and a full-width Github-style green activity matrix of squares.
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

    final cardBgColor = isDark ? const Color(0xFF222327) : AppColors.lightSurface;
    final textPrimaryColor = isDark ? Colors.white : AppColors.lightTextPrimary;

    final cardBorder = isDark
        ? null
        : Border.all(color: AppColors.lightBorder, width: 1);
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

                // Main Content: Full-width Green Activity Squares Matrix
                _buildActivityGrid(isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityGrid(bool isDark) {
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
        return isDark ? const Color(0xFF2D2E33) : const Color(0xFFE9ECEF);
      } else if (level == 1) {
        return const Color(0xFFD8F3DC); // Light green
      } else if (level == 2) {
        return const Color(0xFF74C69D); // Medium green
      } else if (level == 3) {
        return const Color(0xFF2D6A4F); // Deep green
      } else {
        return const Color(0xFF1B4332); // Dark green
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
                  boxShadow: level == 3
                      ? [
                          BoxShadow(
                            color: const Color(0xFF00FF87).withValues(alpha: 0.6),
                            blurRadius: 4,
                          ),
                        ]
                      : null,
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}
