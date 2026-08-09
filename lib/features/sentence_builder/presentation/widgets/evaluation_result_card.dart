import 'package:flutter/material.dart';
import '../../../grammar/domain/entities/grammar_evaluation.dart';

/// Card widget displaying the evaluation feedback, corrections, and model expressions.
class EvaluationResultCard extends StatelessWidget {
  final GrammarEvaluation evaluation;

  const EvaluationResultCard({super.key, required this.evaluation});

  @override
  Widget build(BuildContext context) {
    final isCorrect = evaluation.isCorrect;
    final feedback = evaluation.feedback;
    final corrections = evaluation.corrections;
    final modelExpressions = evaluation.modelExpressions;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCorrect ? const Color(0xFF10B981) : const Color(0xFFEF4444),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle : Icons.error,
                color: isCorrect
                    ? const Color(0xFF10B981)
                    : const Color(0xFFEF4444),
              ),
              const SizedBox(width: 10),
              Text(
                isCorrect ? 'Excellent Sentence' : 'Needs Improvement',
                style: TextStyle(
                  color: isCorrect
                      ? const Color(0xFF10B981)
                      : const Color(0xFFEF4444),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            feedback,
            style: const TextStyle(
              color: Color(0xFFCBD5E1),
              fontSize: 14,
              height: 1.4,
            ),
          ),
          if (corrections.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Text(
              'Corrections:',
              style: TextStyle(
                color: Color(0xFFF87171),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            ...corrections.map(
              (c) => Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.build_circle,
                      size: 14,
                      color: Color(0xFFF87171),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        c,
                        style: const TextStyle(
                          color: Color(0xFFFCA5A5),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (modelExpressions.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Model Expressions:',
              style: TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ...modelExpressions.map(
              (expr) => Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '• ',
                      style: TextStyle(
                        color: Color(0xFF3B82F6),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        expr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
