import 'package:flutter/material.dart';
import '../../domain/entities/writing_evaluation.dart';

class WritingCriterionRow extends StatelessWidget {
  final String label;
  final WritingCriterionScore criterionScore;

  const WritingCriterionRow({
    super.key,
    required this.label,
    required this.criterionScore,
  });

  Color _getScoreColor(double score) {
    if (score >= 8.0) return Colors.green;
    if (score >= 7.0) return Colors.teal;
    if (score >= 6.0) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final score = criterionScore.score;
    final progress = (score / 9.0).clamp(0.0, 1.0);
    final color = _getScoreColor(score);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(
              'Band ${score.toStringAsFixed(1)}',
              style: TextStyle(fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: Colors.grey.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        if (criterionScore.feedback.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            criterionScore.feedback,
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade700),
          ),
        ],
      ],
    );
  }
}
