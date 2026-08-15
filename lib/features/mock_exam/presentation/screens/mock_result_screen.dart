import 'package:flutter/material.dart';
import '../../domain/entities/answer_analysis.dart';
import '../../domain/entities/mock_exam_result.dart';
import '../widgets/answer_analysis_card.dart';

class MockResultScreen extends StatelessWidget {
  final MockExamResult result;

  const MockResultScreen({super.key, required this.result});

  List<AnswerAnalysis> get _analysisList {
    if (result.answerAnalysis.isNotEmpty) return result.answerAnalysis;
    return result.allQuestions.map((q) {
      final userAns = result.userAnswers[q.id] ?? '';
      final isCorrect = userAns.isNotEmpty &&
          (userAns.toLowerCase() == q.correctAnswer.toLowerCase() ||
              q.correctAnswer.toLowerCase().contains(userAns.toLowerCase()));
      return AnswerAnalysis(
        questionId: q.id,
        userAnswer: userAns,
        correctAnswer: q.correctAnswer,
        isCorrect: isCorrect,
        explanation: q.explanation,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final analysisList = _analysisList;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mock Exam Performance Report', style: TextStyle(fontWeight: FontWeight.bold)),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text('OVERALL BAND SCORE', style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  const SizedBox(height: 8),
                  Text(
                    result.overallBandScore.toStringAsFixed(1),
                    style: theme.textTheme.displayLarge?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimaryContainer),
                  ),
                  const SizedBox(height: 4),
                  Text('CEFR Equivalent: ${result.overallBandScore >= 7.0 ? "C1 Advanced" : "B2 Upper Intermediate"}', style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _badge(theme, 'Reading', result.readingBandScore.toStringAsFixed(1)),
                      _badge(theme, 'Listening', result.listeningBandScore.toStringAsFixed(1)),
                      _badge(theme, 'Correct', '${result.correctCount}/${result.totalQuestions}'),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Detailed Answer Key', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  Text('${analysisList.length} Questions', style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: analysisList.length,
              itemBuilder: (context, index) {
                return AnswerAnalysisCard(
                  analysis: analysisList[index],
                  index: index,
                );
              },
            ),
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Back to Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(ThemeData theme, String label, String value) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimaryContainer)),
        Text(label, style: theme.textTheme.labelSmall),
      ],
    );
  }
}
