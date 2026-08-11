import 'package:flutter/material.dart';
import '../../../../design_system/design_system.dart';
import '../../domain/entities/speaking_evaluation.dart';

class AIEvaluationWidget extends StatelessWidget {
  final SpeakingAIEvaluation evaluation;

  const AIEvaluationWidget({super.key, required this.evaluation});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: isDark ? AppColors.darkSurface : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overall Band Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Band Score Evaluation',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Assessed via Official IELTS Scoring Rubric',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isDark
                            ? AppColors.darkTextMuted
                            : AppColors.lightTextMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 24),

            // Strengths
            if (evaluation.strengths.isNotEmpty) ...[
              _buildFeedbackSection(
                theme,
                'Key Strengths',
                evaluation.strengths,
                Icons.check_circle_rounded,
                AppColors.success,
                isDark,
              ),
              const SizedBox(height: 16),
            ],

            // Grammar Errors & Feedback
            if (evaluation.grammarErrors.isNotEmpty) ...[
              _buildFeedbackSection(
                theme,
                'Grammar Corrections',
                evaluation.grammarErrors,
                Icons.build_circle_rounded,
                AppColors.danger,
                isDark,
              ),
              const SizedBox(height: 16),
            ],

            // Vocabulary Enhancement Tips
            if (evaluation.vocabularyTips.isNotEmpty) ...[
              _buildFeedbackSection(
                theme,
                'Lexical & Vocabulary Tips',
                evaluation.vocabularyTips,
                Icons.lightbulb_rounded,
                AppColors.warning,
                isDark,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackSection(
    ThemeData theme,
    String title,
    List<String> items,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkBackground.withValues(alpha: 0.5)
            : AppColors.lightBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '• ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: Text(
                      item,
                      style: theme.textTheme.bodyMedium?.copyWith(height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
