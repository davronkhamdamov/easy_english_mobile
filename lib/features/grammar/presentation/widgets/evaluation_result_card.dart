import 'package:flutter/material.dart';
import '../../domain/entities/grammar_evaluation.dart';

class EvaluationResultCard extends StatelessWidget {
  final GrammarEvaluation evaluation;

  const EvaluationResultCard({
    super.key,
    required this.evaluation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCorrect = evaluation.isCorrect;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      color: isCorrect ? Colors.green.shade50 : Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: isCorrect ? Colors.green : Colors.red,
                  child: Icon(
                    isCorrect ? Icons.check_rounded : Icons.close_rounded,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isCorrect ? 'Grammatically Correct!' : 'Error Detected',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isCorrect ? Colors.green.shade900 : Colors.red.shade900,
                        ),
                      ),
                      if (evaluation.errorType.isNotEmpty)
                        Text(
                          'Category: ${evaluation.errorType}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isCorrect ? Colors.green.shade700 : Colors.red.shade700,
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isCorrect ? Colors.green.shade200 : Colors.red.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Score: ${evaluation.score}/100',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isCorrect ? Colors.green.shade900 : Colors.red.shade900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Text('Original Sentence:', style: theme.textTheme.labelSmall),
            Text(evaluation.originalSentence, style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey)),
            const SizedBox(height: 8),
            Text('Corrected Sentence:', style: theme.textTheme.labelSmall),
            Text(
              evaluation.correctedSentence,
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade800, fontSize: 16),
            ),
            if (evaluation.explanation.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Explanation & Rule:', style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(evaluation.explanation, style: theme.textTheme.bodySmall),
                    if (evaluation.ruleReference.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text('Reference: ${evaluation.ruleReference}', style: theme.textTheme.labelSmall?.copyWith(fontStyle: FontStyle.italic)),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
