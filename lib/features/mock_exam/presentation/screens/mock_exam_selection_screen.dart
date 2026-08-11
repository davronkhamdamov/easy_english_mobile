import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/datasources/mock_exam_local_datasource.dart';
import '../../domain/entities/exam_enums.dart';
import '../../domain/entities/mock_exam_paper.dart';
import '../widgets/exam_paper_item.dart';
import '../widgets/exam_section_card.dart';
import 'listening_practice_screen.dart';
import 'reading_practice_screen.dart';

/// IELTS Full Mock Exam & Section Practice Selection Dashboard.
class MockExamSelectionScreen extends StatefulWidget {
  const MockExamSelectionScreen({super.key});

  @override
  State<MockExamSelectionScreen> createState() =>
      _MockExamSelectionScreenState();
}

class _MockExamSelectionScreenState extends State<MockExamSelectionScreen> {
  ExamType _selectedExamType = ExamType.academic;
  late MockExamPaper _samplePaper;

  @override
  void initState() {
    super.initState();
    _samplePaper = SampleMockExamData.getSampleAcademicPaper();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text(
          'IELTS Mock Exam Center',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.history_edu_outlined),
            tooltip: 'Past Exam Results',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Viewing past exam performance history.'),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Banner Card with Gradient
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'OFFICIAL SIMULATION',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.timer_outlined,
                        color: Colors.white70,
                        size: 24,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Full Mock Test & Section Practice',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Timed exam conditions, official band converters, and instant detailed answer keys.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Academic vs General Training Selector
            Text(
              'Exam Stream Mode',
              style: TextStyle(
                color: textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurfaceVariant
                    : AppColors.lightSurfaceVariant,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedExamType = ExamType.academic;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedExamType == ExamType.academic
                              ? AppColors.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            'Academic (AC)',
                            style: TextStyle(
                              color: _selectedExamType == ExamType.academic
                                  ? Colors.white
                                  : textSecondary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedExamType = ExamType.generalTraining;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedExamType == ExamType.generalTraining
                              ? AppColors.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            'General Training (GT)',
                            style: TextStyle(
                              color:
                                  _selectedExamType == ExamType.generalTraining
                                  ? Colors.white
                                  : textSecondary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Section Mode Selection Cards
            Text(
              'Practice by Section',
              style: TextStyle(
                color: textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.25,
              children: [
                ExamSectionCard(
                  title: 'Reading',
                  subtitle: '60 mins • 40 Qs',
                  icon: Icons.menu_book_rounded,
                  color: const Color(0xFF3B82F6),
                  onTap: () => _launchReadingSection(context),
                ),
                ExamSectionCard(
                  title: 'Listening',
                  subtitle: '30 mins • 40 Qs',
                  icon: Icons.headphones_rounded,
                  color: const Color(0xFF10B981),
                  onTap: () => _launchListeningSection(context),
                ),
                ExamSectionCard(
                  title: 'Writing',
                  subtitle: '60 mins • 2 Tasks',
                  icon: Icons.edit_note_rounded,
                  color: const Color(0xFF8B5CF6),
                  onTap: () => _showWritingInfoModal(context),
                ),
                ExamSectionCard(
                  title: 'Speaking',
                  subtitle: '11-14 mins • 3 Parts',
                  icon: Icons.record_voice_over_rounded,
                  color: const Color(0xFFF59E0B),
                  onTap: () => _showSpeakingInfoModal(context),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Full Mock Test Hero Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.5),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.primaryLight,
                        child: const Icon(
                          Icons.assignment_rounded,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Full Length IELTS Mock Test',
                              style: TextStyle(
                                color: textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Listening (30m) + Reading (60m) + Writing (60m)',
                              style: TextStyle(
                                color: textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _launchFullMock(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: const Size(double.infinity, 46),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Start Full Mock Exam (2h 45m)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Available Mock Exam Papers List
            Text(
              'Available Exam Papers (${_selectedExamType.displayName})',
              style: TextStyle(
                color: textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ExamPaperItem(
              paper: _samplePaper,
              onTap: () => _launchReadingSection(context),
            ),
            const SizedBox(height: 10),
            ExamPaperItem(
              paper: MockExamPaper(
                id: 'paper_academic_02',
                title: 'Cambridge Official Practice Test 2',
                examType: _selectedExamType,
                description:
                    'Advanced passage difficulty featuring high-frequency C1 collocations.',
                difficulty: 'Hard',
                sections: _samplePaper.sections,
              ),
              onTap: () => _launchReadingSection(context),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _launchReadingSection(BuildContext context) {
    final readingSec = _samplePaper.sections.firstWhere(
      (s) => s.skill == MockSkill.reading,
      orElse: () => _samplePaper.sections.first,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReadingPracticeScreen(
          section: readingSec,
          examType: _selectedExamType,
          paperTitle: _samplePaper.title,
        ),
      ),
    );
  }

  void _launchListeningSection(BuildContext context) {
    final listeningSec = _samplePaper.sections.firstWhere(
      (s) => s.skill == MockSkill.listening,
      orElse: () => _samplePaper.sections.first,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ListeningPracticeScreen(
          section: listeningSec,
          examType: _selectedExamType,
          paperTitle: _samplePaper.title,
        ),
      ),
    );
  }

  void _launchFullMock(BuildContext context) {
    _launchReadingSection(context);
  }

  void _showWritingInfoModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'IELTS Writing Section Practice',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 12),
              const Text(
                'Task 1 (20 mins, 150 words) & Task 2 (40 mins, 250 words) with real-time AI Band 9 criteria feedback.',
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _launchReadingSection(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 44),
                ),
                child: const Text(
                  'Start Writing Test Engine',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSpeakingInfoModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'IELTS Speaking Coach',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 12),
              const Text(
                'Part 1 (Introduction), Part 2 (Cue Card), and Part 3 (Discussion) with real-time speech analysis & pronunciation feedback.',
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _launchListeningSection(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  minimumSize: const Size(double.infinity, 44),
                ),
                child: const Text(
                  'Start Speaking Simulation',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
