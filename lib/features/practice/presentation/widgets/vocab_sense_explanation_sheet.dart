import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/polysemy_vocab_item.dart';

/// Card displayed after a student submits an answer, detailing why the meaning applies
/// and summarizing all other meanings of the polysemous word.
class VocabSenseExplanationCard extends StatelessWidget {
  final PolysemyVocabItem item;
  final VocabContextQuestion question;
  final bool isCorrect;
  final VoidCallback onPlayAudio;
  final VoidCallback onAddToWordBank;
  final bool isAddedToWordBank;

  const VocabSenseExplanationCard({
    super.key,
    required this.item,
    required this.question,
    required this.isCorrect,
    required this.onPlayAudio,
    required this.onAddToWordBank,
    this.isAddedToWordBank = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bannerBg = isCorrect
        ? (isDark
            ? AppColors.success.withValues(alpha: 0.15)
            : AppColors.successLight)
        : (isDark
            ? AppColors.danger.withValues(alpha: 0.15)
            : AppColors.dangerLight);

    final bannerBorder = isCorrect ? AppColors.success : AppColors.danger;
    final bannerFg = isCorrect ? AppColors.success : AppColors.danger;

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B1D24) : Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: isDark
              ? AppColors.darkBorder.withValues(alpha: 0.8)
              : AppColors.lightBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Result Status Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: bannerBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: bannerBorder.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                Icon(
                  isCorrect
                      ? Icons.check_circle_rounded
                      : Icons.error_outline_rounded,
                  color: bannerFg,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isCorrect
                        ? 'Correct! You understood the academic context.'
                        : 'Incorrect usage selected for this context.',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: bannerFg,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Context Explanation
          Text(
            'Context Analysis',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              textBaseline: TextBaseline.alphabetic,
              color: isDark ? AppColors.titaniumGrey : AppColors.secondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            question.explanation,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 13.5,
              height: 1.4,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 14),

          // Word Header with Audio & Word Bank action
          Row(
            children: [
              Text(
                item.word,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                item.phonetic,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? AppColors.darkTextMuted
                      : AppColors.lightTextMuted,
                ),
              ),
              const Spacer(),
              // Audio Play button
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.volume_up_rounded, size: 22),
                tooltip: 'Listen pronunciation',
                onPressed: onPlayAudio,
              ),
              // Add to Word Bank button
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  isAddedToWordBank
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  size: 22,
                  color: isAddedToWordBank ? AppColors.accentGreen : null,
                ),
                tooltip: isAddedToWordBank
                    ? 'Saved in Word Bank'
                    : 'Save word to Word Bank',
                onPressed: onAddToWordBank,
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Multiple Meanings Breakdown
          Text(
            'All Meanings of "${item.word}" in IELTS:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.titaniumGrey : AppColors.secondary,
            ),
          ),
          const SizedBox(height: 8),

          ...item.senses.asMap().entries.map((entry) {
            final index = entry.key;
            final sense = entry.value;
            final isTargetSense = index == question.targetSenseIndex;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isTargetSense
                    ? (isDark
                        ? AppColors.primary.withValues(alpha: 0.15)
                        : const Color(0xFFEFF6FF))
                    : (isDark
                        ? Colors.white.withValues(alpha: 0.03)
                        : Colors.black.withValues(alpha: 0.02)),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isTargetSense
                      ? (isDark
                          ? AppColors.primary.withValues(alpha: 0.5)
                          : const Color(0xFF93C5FD))
                      : (isDark
                          ? AppColors.darkBorder.withValues(alpha: 0.4)
                          : AppColors.lightBorder.withValues(alpha: 0.6)),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isTargetSense
                              ? AppColors.primary
                              : (isDark ? Colors.white12 : Colors.black12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Sense ${index + 1} (${sense.partOfSpeech})',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: isTargetSense
                                ? Colors.white
                                : (isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary),
                          ),
                        ),
                      ),
                      if (isTargetSense) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.accentGreenDark
                                : AppColors.accentGreenLight,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Active Context',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.accentGreen
                                  : AppColors.accentGreenDark,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    sense.definition,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight:
                          isTargetSense ? FontWeight.w600 : FontWeight.normal,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Example: "${sense.exampleSentence}"',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontStyle: FontStyle.italic,
                      color: isDark
                          ? AppColors.darkTextMuted
                          : AppColors.lightTextMuted,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
