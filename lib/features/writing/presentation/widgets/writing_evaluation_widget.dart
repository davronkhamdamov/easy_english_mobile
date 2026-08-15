import 'package:flutter/material.dart';
import '../../domain/entities/writing_evaluation.dart';
import 'writing_criterion_row.dart';
import 'writing_grammar_corrections_card.dart';
import 'writing_vocabulary_card.dart';

class WritingEvaluationWidget extends StatelessWidget {
  final WritingEvaluation evaluation;

  const WritingEvaluationWidget({super.key, required this.evaluation});

  Color _getScoreColor(double score) {
    if (score >= 8.0) return Colors.green;
    if (score >= 7.0) return Colors.teal;
    if (score >= 6.0) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Overall Band Score Header Card
        Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: _getScoreColor(evaluation.overallBandScore),
                  child: Text(
                    evaluation.overallBandScore.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Overall IELTS Band Score',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Evaluated Essay Word Count: ${evaluation.wordCount} words',
                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 4 Sub-score Progress Bars
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'IELTS Criteria Breakdown',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                WritingCriterionRow(
                  label: 'Task Achievement',
                  criterionScore: evaluation.taskAchievement,
                ),
                const SizedBox(height: 12),
                WritingCriterionRow(
                  label: 'Coherence & Cohesion',
                  criterionScore: evaluation.coherenceCohesion,
                ),
                const SizedBox(height: 12),
                WritingCriterionRow(
                  label: 'Lexical Resource',
                  criterionScore: evaluation.lexicalResource,
                ),
                const SizedBox(height: 12),
                WritingCriterionRow(
                  label: 'Grammatical Range',
                  criterionScore: evaluation.grammaticalRange,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Expandable Accordions
        WritingGrammarCorrectionsCard(corrections: evaluation.grammarCorrections),

        if (evaluation.vocabularySuggestions.isNotEmpty) ...[
          const SizedBox(height: 8),
          WritingVocabularyCard(vocabularySuggestions: evaluation.vocabularySuggestions),
        ],

        if (evaluation.sampleAnswer.isNotEmpty) ...[
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ExpansionTile(
              leading: const Icon(Icons.star, color: Colors.amber),
              title: const Text(
                'Band 9 Sample Model Answer',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                    ),
                    child: SelectableText(
                      evaluation.sampleAnswer,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
