import 'package:flutter/material.dart';
import '../../domain/entities/writing_evaluation.dart';

class WritingEvaluationWidget extends StatelessWidget {
  final WritingEvaluation evaluation;

  const WritingEvaluationWidget({super.key, required this.evaluation});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: theme.colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI Evaluation Feedback',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 24),

            // Strengths
            if (evaluation.strengths.isNotEmpty) ...[
              Text(
                'Strengths:',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              ...evaluation.strengths.map(
                (s) => Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        size: 16,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 6),
                      Expanded(child: Text(s)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Weaknesses
            if (evaluation.weaknesses.isNotEmpty) ...[
              Text(
                'Areas for Improvement:',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              ...evaluation.weaknesses.map(
                (w) => Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Row(
                    children: [
                      const Icon(Icons.warning, size: 16, color: Colors.orange),
                      const SizedBox(width: 6),
                      Expanded(child: Text(w)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Grammar Corrections
            if (evaluation.grammarCorrections.isNotEmpty) ...[
              Text(
                'Grammar Corrections:',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
              ),
              ...evaluation.grammarCorrections.map(
                (g) => Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.build_circle,
                        size: 16,
                        color: Colors.redAccent,
                      ),
                      const SizedBox(width: 6),
                      Expanded(child: Text(g)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Improved Sample Answer
            if (evaluation.improvedSample.isNotEmpty) ...[
              Text(
                'Improved Model Sample:',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
                ),
                child: Text(
                  evaluation.improvedSample,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.4,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
