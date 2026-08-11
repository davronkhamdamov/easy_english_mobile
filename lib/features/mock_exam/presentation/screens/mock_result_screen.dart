import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/mock_exam_result.dart';
import '../widgets/sub_score_card.dart';

/// IELTS Mock Exam Results & Detailed Answer Key Review Screen.
class MockResultScreen extends StatefulWidget {
  final MockExamResult result;

  const MockResultScreen({super.key, required this.result});

  @override
  State<MockResultScreen> createState() => _MockResultScreenState();
}

class _MockResultScreenState extends State<MockResultScreen> {
  String _selectedFilter = 'All';

  String _getCefrEquivalent(double band) {
    if (band >= 8.0) return 'C2 Expert';
    if (band >= 7.0) return 'C1 Advanced';
    if (band >= 6.0) return 'B2 Upper Intermediate';
    if (band >= 5.0) return 'B1 Intermediate';
    return 'A2 Elementary';
  }

  String _formatTimeTaken(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins}m ${secs}s';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;
    final cardBg = isDark ? AppColors.darkSurface : AppColors.lightSurface;

    final res = widget.result;
    final totalQs = res.allQuestions.length;

    int correctCount = 0;

    for (final q in res.allQuestions) {
      final userAns = (res.userAnswers[q.id] ?? '').trim().toLowerCase();
      final correctAns = q.correctAnswer.trim().toLowerCase();

      if (userAns.isNotEmpty &&
          (userAns == correctAns || correctAns.contains(userAns))) {
        correctCount++;
      }
    }

    final accuracyPct = totalQs > 0
        ? (correctCount / totalQs * 100).toStringAsFixed(1)
        : '0.0';

    // Filter questions
    final filteredQuestions = res.allQuestions.where((q) {
      final userAns = (res.userAnswers[q.id] ?? '').trim().toLowerCase();
      final correctAns = q.correctAnswer.trim().toLowerCase();

      if (_selectedFilter == 'Correct') {
        return userAns.isNotEmpty &&
            (userAns == correctAns || correctAns.contains(userAns));
      } else if (_selectedFilter == 'Incorrect') {
        return userAns.isNotEmpty &&
            userAns != correctAns &&
            !correctAns.contains(userAns);
      } else if (_selectedFilter == 'Unanswered') {
        return userAns.isEmpty;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text(
          'Mock Exam Performance Report',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined),
            onPressed: () =>
                Navigator.popUntil(context, (route) => route.isFirst),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Score Banner Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'OFFICIAL IELTS BAND SCORE',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        res.overallBand.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 54,
                          fontWeight: FontWeight.bold,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '/ 9.0',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'CEFR Equivalent: ${_getCefrEquivalent(res.overallBand)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    res.examTitle,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Sub-scores Breakdown Grid
            Text(
              'Section Band Breakdown',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.4,
              children: [
                SubScoreCard(
                  title: 'Reading Band',
                  band: res.readingBand,
                  rawRatio:
                      '${res.readingRawScore}/${res.totalReadingQuestions > 0 ? res.totalReadingQuestions : 40}',
                  icon: Icons.menu_book_rounded,
                  color: const Color(0xFF3B82F6),
                ),
                SubScoreCard(
                  title: 'Listening Band',
                  band: res.listeningBand,
                  rawRatio:
                      '${res.listeningRawScore}/${res.totalListeningQuestions > 0 ? res.totalListeningQuestions : 40}',
                  icon: Icons.headphones_rounded,
                  color: const Color(0xFF10B981),
                ),
                SubScoreCard(
                  title: 'Writing Band',
                  band: res.writingBand,
                  rawRatio: 'Task 1 & 2',
                  icon: Icons.edit_note_rounded,
                  color: const Color(0xFF8B5CF6),
                ),
                SubScoreCard(
                  title: 'Speaking Band',
                  band: res.speakingBand,
                  rawRatio: 'Parts 1-3',
                  icon: Icons.record_voice_over_rounded,
                  color: const Color(0xFFF59E0B),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Stats Summary Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _statItem(
                    'Time Taken',
                    _formatTimeTaken(res.timeTakenSeconds),
                    Icons.timer_outlined,
                    AppColors.primary,
                  ),
                  _statItem(
                    'Accuracy',
                    '$accuracyPct%',
                    Icons.pie_chart_outline,
                    AppColors.success,
                  ),
                  _statItem(
                    'Correct',
                    '$correctCount/$totalQs',
                    Icons.check_circle_outline,
                    AppColors.secondary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Detailed Answer Key Header & Filter Chips
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Detailed Answer Key',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: textPrimary,
                  ),
                ),
                Text(
                  '${filteredQuestions.length} Questions',
                  style: TextStyle(color: textSecondary, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'Correct', 'Incorrect', 'Unanswered'].map((
                  f,
                ) {
                  final isSel = _selectedFilter == f;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(f),
                      selected: isSel,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSel ? Colors.white : textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedFilter = f;
                          });
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 14),

            // Answer Key Questions List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredQuestions.length,
              itemBuilder: (context, idx) {
                final q = filteredQuestions[idx];
                final userAns = (res.userAnswers[q.id] ?? '').trim();
                final isCorrect =
                    userAns.isNotEmpty &&
                    (userAns.toLowerCase() == q.correctAnswer.toLowerCase() ||
                        q.correctAnswer.toLowerCase().contains(
                          userAns.toLowerCase(),
                        ));
                final isUnanswered = userAns.isEmpty;

                return Material(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder,
                      ),
                    ),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      leading: CircleAvatar(
                        radius: 14,
                        backgroundColor: isUnanswered
                            ? AppColors.warning.withValues(alpha: 0.2)
                            : (isCorrect
                                  ? AppColors.success.withValues(alpha: 0.2)
                                  : AppColors.danger.withValues(alpha: 0.2)),
                        child: Icon(
                          isUnanswered
                              ? Icons.help_outline
                              : (isCorrect ? Icons.check : Icons.close),
                          size: 16,
                          color: isUnanswered
                              ? AppColors.warning
                              : (isCorrect
                                    ? AppColors.success
                                    : AppColors.danger),
                        ),
                      ),
                      title: Text(
                        'Q${q.orderIndex}: ${q.prompt}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: textPrimary,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Row(
                          children: [
                            Text(
                              'Your Answer: ${userAns.isNotEmpty ? userAns : "Unanswered"}',
                              style: TextStyle(
                                fontSize: 12,
                                color: isUnanswered
                                    ? AppColors.warning
                                    : (isCorrect
                                          ? AppColors.success
                                          : AppColors.danger),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            bottom: 16,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Divider(),
                              const SizedBox(height: 4),
                              Text(
                                'Correct Answer: ${q.correctAnswer}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.success,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.darkSurfaceVariant
                                      : AppColors.lightSurfaceVariant,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  q.explanation.isNotEmpty
                                      ? q.explanation
                                      : 'The correct answer is derived directly from the section passage or audio transcript text.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    height: 1.4,
                                    color: textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Retake Practice'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        Navigator.popUntil(context, (route) => route.isFirst),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: const Size(0, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Back to Dashboard',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
      ],
    );
  }
}
