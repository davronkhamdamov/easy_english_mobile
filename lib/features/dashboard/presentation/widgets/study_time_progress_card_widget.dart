import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Study Time Progress Card ("Card 1") inspired by Apple Watch / Health widgets.
/// Clean monochrome design without bright accent colors.
class StudyTimeProgressCardWidget extends StatelessWidget {
  final String totalTime;
  final String grammarTime;
  final String vocabTime;
  final String practiceTime;
  final VoidCallback? onTap;

  const StudyTimeProgressCardWidget({
    super.key,
    this.totalTime = '01:47:19',
    this.grammarTime = '57m',
    this.vocabTime = '24m',
    this.practiceTime = '26m',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBgColor = isDark ? const Color(0xFF222327) : AppColors.lightSurface;
    final textPrimaryColor = isDark ? Colors.white : AppColors.lightTextPrimary;
    final textSecondaryColor =
        isDark ? Colors.white.withValues(alpha: 0.5) : AppColors.lightTextSecondary;
    final badgeBgColor = isDark ? const Color(0xFF2D2E33) : AppColors.lightSurfaceVariant;

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
                // Top Row: Graduation Cap Capsule Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: badgeBgColor,
                    borderRadius: BorderRadius.circular(20),
                    border: isDark ? null : Border.all(color: AppColors.lightBorder),
                  ),
                  child: Icon(
                    Icons.school_rounded,
                    color: textPrimaryColor,
                    size: 18,
                  ),
                ),
                const SizedBox(height: 14),

                // Digital Timer Readout
                Text(
                  totalTime,
                  style: TextStyle(
                    color: textPrimaryColor,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 6),

                // Breakdown String (e.g., 57m • 24m • 26m)
                Row(
                  children: [
                    Text(
                      grammarTime,
                      style: TextStyle(
                        color: textSecondaryColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      ' • ',
                      style: TextStyle(color: textSecondaryColor, fontSize: 13),
                    ),
                    Text(
                      vocabTime,
                      style: TextStyle(
                        color: textSecondaryColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      ' • ',
                      style: TextStyle(color: textSecondaryColor, fontSize: 13),
                    ),
                    Text(
                      practiceTime,
                      style: TextStyle(
                        color: textSecondaryColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Segmented Monochrome Timeline Bar
                _buildSegmentedBar(textPrimaryColor),
                const SizedBox(height: 10),

                // Bottom Session Dots Row (Monochrome)
                _buildDotTimeline(textPrimaryColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSegmentedBar(Color primaryColor) {
    return Container(
      height: 22,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Row(
          children: [
            Expanded(
              flex: 57,
              child: Container(color: primaryColor),
            ),
            const SizedBox(width: 2),
            Expanded(
              flex: 12,
              child: Container(color: primaryColor.withValues(alpha: 0.7)),
            ),
            const SizedBox(width: 2),
            Expanded(
              flex: 24,
              child: Container(color: primaryColor.withValues(alpha: 0.45)),
            ),
            const SizedBox(width: 2),
            Expanded(
              flex: 26,
              child: Container(color: primaryColor.withValues(alpha: 0.2)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDotTimeline(Color primaryColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(14, (index) {
        final isActive = index == 1 || index == 5 || index == 6 || index == 10 || index == 11;
        return Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? primaryColor.withValues(alpha: 0.8)
                : primaryColor.withValues(alpha: 0.2),
          ),
        );
      }),
    );
  }
}
