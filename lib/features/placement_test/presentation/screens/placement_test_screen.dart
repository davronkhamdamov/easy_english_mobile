import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/placement_test_provider.dart';
import '../widgets/placement_progress_indicator.dart';
import '../widgets/placement_question_card.dart';
import '../widgets/placement_result_card.dart';
import '../widgets/study_plan_card.dart';

/// Flutter Placement Test Screen featuring multi-skill diagnostic questions,
/// real-time progress indicator, countdown timer, question navigation,
/// automatic band score calculation, and interactive personalized study plan results.
class PlacementTestScreen extends StatefulWidget {
  final PlacementTestProvider? provider;

  const PlacementTestScreen({super.key, this.provider});

  @override
  State<PlacementTestScreen> createState() => _PlacementTestScreenState();
}

class _PlacementTestScreenState extends State<PlacementTestScreen> {
  late final PlacementTestProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = widget.provider ?? PlacementTestProvider();
    _provider.addListener(_onProviderStateChanged);
  }

  @override
  void dispose() {
    _provider.removeListener(_onProviderStateChanged);
    if (widget.provider == null) {
      _provider.dispose();
    }
    super.dispose();
  }

  void _onProviderStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _showSubmitConfirmationDialog() {
    final session = _provider.session;
    final unanswered = session.questions.length - session.userAnswers.length;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Complete Diagnostic Test?'),
        content: Text(
          unanswered > 0
              ? 'You still have $unanswered unanswered question(s). Are you ready to submit your diagnostic test and calculate your band score?'
              : 'You have answered all questions! Ready to submit and receive your personalized IELTS study plan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Review Questions'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _provider.submitTest();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Submit Test'),
          ),
        ],
      ),
    );
  }

  void _showQuestionPalette() {
    final session = _provider.session;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Question Navigator',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                itemCount: session.questions.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemBuilder: (context, index) {
                  final q = session.questions[index];
                  final isAnswered = session.userAnswers.containsKey(q.id);
                  final isCurrent = index == session.currentQuestionIndex;

                  Color btnColor = AppColors.lightSurfaceVariant;
                  Color textColor = AppColors.lightTextPrimary;

                  if (isCurrent) {
                    btnColor = AppColors.primary;
                    textColor = Colors.white;
                  } else if (isAnswered) {
                    btnColor = AppColors.successLight;
                    textColor = AppColors.success;
                  }

                  return InkWell(
                    onTap: () {
                      _provider.goToQuestion(index);
                      Navigator.of(ctx).pop();
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: btnColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isCurrent
                              ? AppColors.primary
                              : (isAnswered
                                    ? AppColors.success
                                    : AppColors.lightBorder),
                          width: isCurrent ? 2 : 1,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Q${index + 1}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final session = _provider.session;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('IELTS Diagnostic Placement Test'),
        elevation: 0,
        actions: [
          if (!session.isCompleted)
            IconButton(
              icon: const Icon(Icons.grid_view_rounded),
              tooltip: 'Question Palette',
              onPressed: _showQuestionPalette,
            ),
        ],
      ),
      body: session.isCompleted
          ? _buildResultsView(theme, isDark)
          : _buildTestInterfaceView(theme, isDark),
    );
  }

  // --- Active Test UI View ---
  Widget _buildTestInterfaceView(ThemeData theme, bool isDark) {
    final session = _provider.session;
    final q = session.currentQuestion;
    final selectedOption = session.userAnswers[q.id];

    return Column(
      children: [
        PlacementProgressIndicator(
          session: session,
          onOpenPalette: _showQuestionPalette,
        ),

        // Question Details & Body
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Question Header Counter
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Question ${session.currentQuestionIndex + 1} of ${session.totalQuestions}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                    Text(
                      '${session.answeredCount} answered',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Question Card (Audio, Reading, Prompt & Options)
                PlacementQuestionCard(
                  question: q,
                  selectedOptionIndex: selectedOption,
                  onSelectOption: (index) => _provider.selectOption(index),
                  isPlayingAudio: _provider.isPlayingAudio,
                  audioProgress: _provider.audioProgress,
                  onToggleAudioPlay: () => _provider.toggleAudioPlay(),
                ),
              ],
            ),
          ),
        ),

        // Bottom Navigation Bar
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            border: Border(
              top: BorderSide(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
          ),
          child: Row(
            children: [
              // Previous Button
              if (session.currentQuestionIndex > 0)
                OutlinedButton.icon(
                  onPressed: () => _provider.previousQuestion(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Previous'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                )
              else
                const SizedBox.shrink(),

              const Spacer(),

              // Next / Submit Button
              ElevatedButton.icon(
                onPressed: _provider.isSubmitting
                    ? null
                    : () {
                        if (session.currentQuestionIndex ==
                            session.questions.length - 1) {
                          _showSubmitConfirmationDialog();
                        } else {
                          _provider.nextQuestion();
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: _provider.isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(
                        session.currentQuestionIndex ==
                                session.questions.length - 1
                            ? Icons.check_circle_outline
                            : Icons.arrow_forward,
                      ),
                label: Text(
                  session.currentQuestionIndex == session.questions.length - 1
                      ? 'Submit Test'
                      : 'Next Question',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Results & Personalized Study Plan View ---
  Widget _buildResultsView(ThemeData theme, bool isDark) {
    final score = _provider.calculatedScore;
    final plan = _provider.studyPlan;

    if (score == null || plan == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PlacementResultCard(score: score),
          const SizedBox(height: 28),
          StudyPlanCard(
            plan: plan,
            onSavePlan: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Study Plan saved to your profile!'),
                ),
              );
            },
            onRetakeTest: () {
              _provider.initDiagnosticSession();
            },
          ),
        ],
      ),
    );
  }
}
