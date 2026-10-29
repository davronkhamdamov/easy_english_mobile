import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../design_system/components/button/ds_button.dart';
import '../../domain/entities/polysemy_vocab_item.dart';

/// Summary view displayed at the completion of a multi-meaning vocabulary practice session.
class VocabQuizSummaryView extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final List<PolysemyVocabItem> items;
  final Map<String, int> userAnswers;
  final VoidCallback onRetry;
  final VoidCallback onExit;
  final Function(String word) onPlayAudio;

  const VocabQuizSummaryView({
    super.key,
    required this.score,
    required this.totalQuestions,
    required this.items,
    required this.userAnswers,
    required this.onRetry,
    required this.onExit,
    required this.onPlayAudio,
  });

  double get percentage =>
      totalQuestions > 0 ? (score / totalQuestions) * 100 : 0;

  double get estimatedBand {
    if (percentage >= 90) return 8.5;
    if (percentage >= 80) return 7.5;
    if (percentage >= 70) return 7.0;
    if (percentage >= 60) return 6.5;
    if (percentage >= 50) return 6.0;
    return 5.5;
  }

  String get feedbackMessage {
    if (percentage >= 90) {
      return 'Outstanding! You have exceptional mastery over subtle academic connotations and secondary meanings.';
    }
    if (percentage >= 75) {
      return 'Great job! You recognize contextual shifts in meaning well. Review missed words to hit Band 8+.';
    }
    if (percentage >= 50) {
      return 'Good effort! Polysemous words are classic IELTS traps. Practice identifying secondary meanings in context.';
    }
    return 'Keep practicing! Focus on reading the entire sentence to infer the precise academic meaning.';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Trophy / Badge Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? AppColors.primary.withValues(alpha: 0.2)
                  : const Color(0xFFEEF2FF),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.4),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.workspace_premium_rounded,
              color: AppColors.primary,
              size: 42,
            ),
          ),
          const SizedBox(height: 16),

          Text(
            'Practice Complete!',
            style: AppTypography.h3.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            feedbackMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5,
              height: 1.4,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 24),

          // Score & Band Card
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
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
                  color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Score metric
                Column(
                  children: [
                    Text(
                      '$score / $totalQuestions',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Accuracy (${percentage.toInt()}%)',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.darkTextMuted
                            : AppColors.lightTextMuted,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 1,
                  height: 44,
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
                // Band metric
                Column(
                  children: [
                    Text(
                      'Band $estimatedBand',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.accentGreen,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Lexical Resource',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.darkTextMuted
                            : AppColors.lightTextMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Word-by-Word Review Header
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Word Breakdown',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Word Items list
          ...items.map((item) {
            final q = item.questions.first;
            final userPick = userAnswers[q.id];
            final isCorrect = userPick == q.correctOptionIndex;
            final targetSense = item.senses[q.targetSenseIndex];

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF16181F) : const Color(0xFFF9FAFD),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isCorrect
                      ? AppColors.success.withValues(alpha: 0.4)
                      : AppColors.danger.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isCorrect
                        ? Icons.check_circle_rounded
                        : Icons.cancel_rounded,
                    color: isCorrect ? AppColors.success : AppColors.danger,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              item.word,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '(${targetSense.partOfSpeech})',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: isDark
                                    ? AppColors.darkTextMuted
                                    : AppColors.lightTextMuted,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Context Meaning: ${targetSense.definition}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.volume_up_rounded, size: 20),
                    tooltip: 'Pronunciation',
                    onPressed: () => onPlayAudio(item.word),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 24),

          // Bottom Action Buttons
          Row(
            children: [
              Expanded(
                child: DSButton(
                  text: 'Practice Again',
                  variant: DSButtonVariant.outline,
                  onPressed: onRetry,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DSButton(
                  text: 'Done',
                  variant: DSButtonVariant.primary,
                  onPressed: onExit,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
