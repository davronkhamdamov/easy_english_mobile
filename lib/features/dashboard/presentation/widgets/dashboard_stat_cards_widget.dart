import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Stat cards widget inspired by Apple Health/Fitness dashboard cards.
/// Displays symmetric side-by-side cards for "Learned Grammar" and "Learned Vocabularies",
/// both featuring large numeric stat readouts + inline unit labels.
/// Automatically adapts between Light and Dark theme modes using global color tokens.
class DashboardStatCardsWidget extends StatelessWidget {
  final String grammarCount;
  final String grammarUnit;
  final String grammarTitle;
  final String grammarSubtitle;
  final String vocabCount;
  final String vocabUnit;
  final String vocabTitle;
  final String vocabSubtitle;
  final VoidCallback? onGrammarTap;
  final VoidCallback? onVocabTap;

  const DashboardStatCardsWidget({
    super.key,
    this.grammarCount = '14',
    this.grammarUnit = 'topics',
    this.grammarTitle = 'Learned Grammar',
    this.grammarSubtitle = '14 topics',
    this.vocabCount = '190',
    this.vocabUnit = 'words',
    this.vocabTitle = 'Learned Vocabularies',
    this.vocabSubtitle = '31 min ago',
    this.onGrammarTap,
    this.onVocabTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left Card: Learned Grammar
        Expanded(
          child: _buildGrammarCard(context),
        ),
        const SizedBox(width: 12),
        // Right Card: Learned Vocabularies
        Expanded(
          child: _buildVocabCard(context),
        ),
      ],
    );
  }

  Widget _buildGrammarCard(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBgColor = isDark ? const Color(0xFF222327) : AppColors.lightSurface;
    final textPrimaryColor = isDark ? Colors.white : AppColors.lightTextPrimary;
    final textSecondaryColor =
        isDark ? Colors.white.withValues(alpha: 0.5) : AppColors.lightTextSecondary;

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
      height: 148,
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(22),
        border: cardBorder,
        boxShadow: cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onGrammarTap,
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Row: Big Number Stat + Unit (Matching Vocabularies Card)
                FittedBox(
                  alignment: Alignment.centerLeft,
                  fit: BoxFit.scaleDown,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        grammarCount,
                        style: TextStyle(
                          color: textPrimaryColor,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -1.0,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        grammarUnit,
                        style: TextStyle(
                          color: textSecondaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Bottom Column: Title + Subtitle
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      grammarTitle,
                      style: TextStyle(
                        color: textPrimaryColor,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      grammarSubtitle,
                      style: TextStyle(
                        color: textSecondaryColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVocabCard(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBgColor = isDark ? const Color(0xFF222327) : AppColors.lightSurface;
    final textPrimaryColor = isDark ? Colors.white : AppColors.lightTextPrimary;
    final textSecondaryColor =
        isDark ? Colors.white.withValues(alpha: 0.5) : AppColors.lightTextSecondary;

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
      height: 148,
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(22),
        border: cardBorder,
        boxShadow: cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onVocabTap,
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Row: Big Number Stat + Unit
                FittedBox(
                  alignment: Alignment.centerLeft,
                  fit: BoxFit.scaleDown,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        vocabCount,
                        style: TextStyle(
                          color: textPrimaryColor,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -1.0,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        vocabUnit,
                        style: TextStyle(
                          color: textSecondaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Bottom Column: Title + Subtitle
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vocabTitle,
                      style: TextStyle(
                        color: textPrimaryColor,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      vocabSubtitle,
                      style: TextStyle(
                        color: textSecondaryColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
