import 'package:flutter/material.dart';
import '../../../../design_system/design_system.dart';
import '../../domain/entities/speaking_evaluation.dart';

class AIEvaluationCard extends StatelessWidget {
  final SpeakingAIEvaluation evaluation;

  const AIEvaluationCard({super.key, required this.evaluation});

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
            _buildOverallHeader(theme, isDark),
            const Divider(height: 24),
            _buildCriteriaSection(theme, isDark),
            const SizedBox(height: 16),
            if (evaluation.pronunciationTips.isNotEmpty)
              _buildTipsAccordion(theme, isDark),
            if (evaluation.pauseCount > 0)
              _buildPauseCountAccordion(theme, isDark),
            if (evaluation.sampleAnswer.isNotEmpty)
              _buildSampleAnswerAccordion(theme, isDark),
            if (evaluation.strengths.isNotEmpty)
              _buildListSection(theme, 'Key Strengths', evaluation.strengths, Icons.check_circle, AppColors.success, isDark),
            if (evaluation.grammarErrors.isNotEmpty)
              _buildListSection(theme, 'Grammar Corrections', evaluation.grammarErrors, Icons.build_circle, AppColors.danger, isDark),
            if (evaluation.vocabularyTips.isNotEmpty)
              _buildListSection(theme, 'Vocabulary Advice', evaluation.vocabularyTips, Icons.lightbulb, AppColors.warning, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallHeader(ThemeData theme, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('AI Band Score Evaluation', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text('Official IELTS Rubric', style: theme.textTheme.labelSmall?.copyWith(color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted)),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            'Band ${evaluation.overallScore.toStringAsFixed(1)}',
            style: theme.textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildCriteriaSection(ThemeData theme, bool isDark) {
    final criteria = [
      {'name': 'Fluency & Coherence', 'score': evaluation.fluencyScore, 'feedback': evaluation.fluencyFeedback},
      {'name': 'Pronunciation', 'score': evaluation.pronunciationScore, 'feedback': evaluation.pronunciationFeedback},
      {'name': 'Lexical Resource', 'score': evaluation.lexicalScore, 'feedback': evaluation.lexicalFeedback},
      {'name': 'Grammatical Range', 'score': evaluation.grammarScore, 'feedback': evaluation.grammarFeedback},
    ];

    return Column(
      children: criteria.map((c) {
        final name = c['name'] as String;
        final score = c['score'] as double;
        final fb = c['feedback'] as String;
        final progress = (score / 9.0).clamp(0.0, 1.0);

        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(name, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                  Text('Band ${score.toStringAsFixed(1)}', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary)),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(value: progress, minHeight: 6, color: AppColors.primary, backgroundColor: AppColors.primary.withValues(alpha: 0.15)),
              ),
              if (fb.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(fb, style: theme.textTheme.bodySmall?.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary, fontStyle: FontStyle.italic)),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTipsAccordion(ThemeData theme, bool isDark) {
    return ExpansionTile(
      title: Text('Pronunciation Tips (${evaluation.pronunciationTips.length})', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
      leading: const Icon(Icons.record_voice_over, color: AppColors.secondary, size: 20),
      childrenPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      children: evaluation.pronunciationTips.map((t) => Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${t.word} ', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary)),
            Text('${t.phonetic}: ', style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic)),
            Expanded(child: Text(t.tip, style: theme.textTheme.bodySmall)),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildPauseCountAccordion(ThemeData theme, bool isDark) {
    return ExpansionTile(
      title: Text('Pause Count Analysis (${evaluation.pauseCount} pauses detected)', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
      leading: const Icon(Icons.pause_circle_outline, color: AppColors.warning, size: 20),
      childrenPadding: const EdgeInsets.all(12),
      children: [
        Text(
          evaluation.pauseCount <= 2
              ? 'Great fluency! Very few hesitation pauses detected.'
              : 'Noticeable pause count (${evaluation.pauseCount}). Try linking ideas using connectors like "Furthermore" or "As a matter of fact".',
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildSampleAnswerAccordion(ThemeData theme, bool isDark) {
    return ExpansionTile(
      title: Text('Band 9 Model Answer', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.success)),
      leading: const Icon(Icons.stars, color: AppColors.success, size: 20),
      childrenPadding: const EdgeInsets.all(12),
      children: [
        Text(evaluation.sampleAnswer, style: theme.textTheme.bodyMedium?.copyWith(height: 1.4, fontStyle: FontStyle.italic)),
      ],
    );
  }

  Widget _buildListSection(ThemeData theme, String title, List<String> items, IconData icon, Color color, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: color)),
            ],
          ),
          const SizedBox(height: 4),
          ...items.map((i) => Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
            child: Text('• $i', style: theme.textTheme.bodySmall?.copyWith(height: 1.3)),
          )),
        ],
      ),
    );
  }
}
