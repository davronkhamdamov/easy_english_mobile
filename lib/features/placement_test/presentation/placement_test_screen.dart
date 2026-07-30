import 'dart:async';
import 'package:flutter/material.dart';
import '../domain/placement_model.dart';
import '../../../core/theme/app_colors.dart';

/// Flutter Placement Test Screen featuring multi-skill diagnostic questions,
/// real-time progress indicator, countdown timer, question navigation,
/// automatic band score calculation, and interactive personalized study plan results.
class PlacementTestScreen extends StatefulWidget {
  const PlacementTestScreen({super.key});

  @override
  State<PlacementTestScreen> createState() => _PlacementTestScreenState();
}

class _PlacementTestScreenState extends State<PlacementTestScreen>
    with SingleTickerProviderStateMixin {
  late DiagnosticSession _session;
  Timer? _timer;
  bool _isPlayingAudio = false;
  double _audioProgress = 0.0;
  Timer? _audioTimer;

  EstimatedBandScore? _calculatedScore;
  StudyPlanRecommendation? _studyPlan;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _initDiagnosticSession();
    _startCountdownTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioTimer?.cancel();
    super.dispose();
  }

  void _initDiagnosticSession() {
    final mockQuestions = [
      // 1. Grammar
      PlacementQuestion(
        id: 'q1_grammar',
        skill: DiagnosticSkill.grammar,
        prompt: 'Choose the sentence with correct grammatical structure for Task 2 academic writing:',
        options: [
          'Neither the researchers nor the professor were able to prove the hypothesis.',
          'Neither the researchers nor the professor was able to prove the hypothesis.',
          'Neither the researchers or the professor were able to prove the hypothesis.',
          'Neither of the researchers nor professor are able to prove the hypothesis.',
        ],
        correctOptionIndex: 1,
        explanation: 'When using "neither... nor", the verb agrees with the subject closer to it ("the professor" -> singular "was").',
        cefrLevel: 'B2',
      ),
      PlacementQuestion(
        id: 'q2_grammar',
        skill: DiagnosticSkill.grammar,
        prompt: 'Complete the sentence: "Had the government implemented strict regulations earlier, carbon emissions _______ reduced significantly."',
        options: [
          'would be',
          'will have been',
          'would have been',
          'had been',
        ],
        correctOptionIndex: 2,
        explanation: 'Inverted third conditional requires "would have been" in the main clause.',
        cefrLevel: 'C1',
      ),

      // 2. Vocabulary
      PlacementQuestion(
        id: 'q3_vocab',
        skill: DiagnosticSkill.vocabulary,
        prompt: 'Which word is the most appropriate academic synonym for "gradually increase over time"?',
        options: [
          'Escalate',
          'Accumulate',
          'Proliferate',
          'Fluctuate',
        ],
        correctOptionIndex: 1,
        explanation: '"Accumulate" specifically means to gather or increase gradually over time.',
        cefrLevel: 'B2',
      ),
      PlacementQuestion(
        id: 'q4_vocab',
        skill: DiagnosticSkill.vocabulary,
        prompt: 'Select the correct collocation: "The new renewable energy policy aims to _______ a pivotal role in urban sustainability."',
        options: [
          'make',
          'play',
          'give',
          'take',
        ],
        correctOptionIndex: 1,
        explanation: 'The standard academic collocation is "play a pivotal role".',
        cefrLevel: 'B2',
      ),

      // 3. Reading
      PlacementQuestion(
        id: 'q5_reading',
        skill: DiagnosticSkill.reading,
        passage:
            'Urbanization in the 21st century has shifted demographic patterns worldwide. Cities now host over 55% of the global population, a figure projected to reach 68% by 2050. While urban areas generate 80% of global GDP, they are also responsible for over 70% of greenhouse gas emissions. Managing infrastructure resilience while mitigating environmental degradation represents the primary challenge for municipal planning committees.',
        prompt: 'According to the passage, which of the following statements is TRUE?',
        options: [
          'More than two-thirds of the world population currently lives in cities.',
          'Cities produce less than half of global greenhouse gas emissions.',
          'Urban centers generate the vast majority of global economic output.',
          'Municipal planning committees have successfully solved urban emissions.',
        ],
        correctOptionIndex: 2,
        explanation: 'The text states cities generate 80% of global GDP, which represents the vast majority of economic output.',
        cefrLevel: 'B2',
      ),
      PlacementQuestion(
        id: 'q6_reading',
        skill: DiagnosticSkill.reading,
        passage:
            'Cognitive neuroscientists studying bilingualism have observed enhanced executive function in individuals who regularly navigate two languages. This "bilingual advantage" manifests primarily in task-switching, conflict resolution, and working memory retention. Critics argue that pubic publication bias inflates these findings, yet recent neuroimaging confirms structural increases in grey matter density in left inferior parietal cortex.',
        prompt: 'What is the main purpose of mentioning critics in the passage?',
        options: [
          'To disprove the existence of any bilingual brain advantages.',
          'To introduce a counter-perspective regarding published study reliability.',
          'To argue that neuroimaging data is fundamentally flawed.',
          'To recommend publishing fewer bilingual studies in scientific journals.',
        ],
        correctOptionIndex: 1,
        explanation: 'The mention of critics introduces a counter-argument regarding publication bias.',
        cefrLevel: 'C1',
      ),

      // 4. Listening
      PlacementQuestion(
        id: 'q7_listening',
        audioUrl: 'https://cdn.easyenglish.app/audio/diagnostic_sec1.mp3',
        prompt: 'Audio Transcript: [Lecturer: "The deadline for submitting the environmental impact assessment has been extended from Thursday the 12th to Monday the 16th at noon."]\n\nWhen is the final deadline for the environmental impact assessment?',
        options: [
          'Thursday 12th at midnight',
          'Friday 13th at noon',
          'Monday 16th at noon',
          'Monday 16th at midnight',
        ],
        correctOptionIndex: 2,
        explanation: 'The speaker explicitly states the new extended deadline is Monday the 16th at noon.',
        cefrLevel: 'B1',
      ),
      PlacementQuestion(
        id: 'q8_listening',
        audioUrl: 'https://cdn.easyenglish.app/audio/diagnostic_sec2.mp3',
        prompt: 'Audio Transcript: [Student: "I was planning to focus my case study on solar microgrids, but Professor Vance suggested offshore wind farms might offer richer data."]\n\nWhat topic did Professor Vance recommend for the case study?',
        options: [
          'Solar microgrids',
          'Offshore wind farms',
          'Hydroelectric dams',
          'Geothermal energy',
        ],
        correctOptionIndex: 1,
        explanation: 'The professor recommended offshore wind farms because they offer richer data.',
        cefrLevel: 'B2',
      ),
    ];

    _session = DiagnosticSession(
      id: 'diag_${DateTime.now().millisecondsSinceEpoch}',
      startTime: DateTime.now(),
      durationSeconds: 600, // 10 minutes countdown
      questions: mockQuestions,
    );
  }

  void _startCountdownTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_session.isCompleted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_session.remainingSeconds > 0) {
          _session.remainingSeconds--;
        } else {
          _timer?.cancel();
          _submitTest();
        }
      });
    });
  }

  void _toggleAudioPlay() {
    if (_isPlayingAudio) {
      _audioTimer?.cancel();
      setState(() => _isPlayingAudio = false);
    } else {
      setState(() {
        _isPlayingAudio = true;
      });
      _audioTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
        setState(() {
          _audioProgress += 0.05;
          if (_audioProgress >= 1.0) {
            _audioProgress = 0.0;
            _isPlayingAudio = false;
            timer.cancel();
          }
        });
      });
    }
  }

  void _selectOption(int index) {
    if (_session.isCompleted) return;
    setState(() {
      final currentQ = _session.currentQuestion;
      _session.userAnswers[currentQ.id] = index;
    });
  }

  void _nextQuestion() {
    if (_session.currentQuestionIndex < _session.questions.length - 1) {
      setState(() {
        _session.currentQuestionIndex++;
        _isPlayingAudio = false;
        _audioProgress = 0.0;
        _audioTimer?.cancel();
      });
    } else {
      _showSubmitConfirmationDialog();
    }
  }

  void _previousQuestion() {
    if (_session.currentQuestionIndex > 0) {
      setState(() {
        _session.currentQuestionIndex--;
        _isPlayingAudio = false;
        _audioProgress = 0.0;
        _audioTimer?.cancel();
      });
    }
  }

  void _submitTest() {
    setState(() {
      _isSubmitting = true;
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() {
        _session.isCompleted = true;
        _isSubmitting = false;
        _calculatedScore = EstimatedBandScore.fromSession(_session);
        _studyPlan = StudyPlanRecommendation.generate(
          bandScore: _calculatedScore!,
          targetBand: 7.5,
        );
      });
    });
  }

  void _showSubmitConfirmationDialog() {
    final unanswered = _session.questions.length - _session.userAnswers.length;
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
              _submitTest();
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
                  Text('Question Navigator',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                itemCount: _session.questions.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemBuilder: (context, index) {
                  final q = _session.questions[index];
                  final isAnswered = _session.userAnswers.containsKey(q.id);
                  final isCurrent = index == _session.currentQuestionIndex;

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
                      setState(() {
                        _session.currentQuestionIndex = index;
                      });
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
                              : (isAnswered ? AppColors.success : AppColors.lightBorder),
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

  String _formatTimer(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('IELTS Diagnostic Placement Test'),
        elevation: 0,
        actions: [
          if (!_session.isCompleted)
            IconButton(
              icon: const Icon(Icons.grid_view_rounded),
              tooltip: 'Question Palette',
              onPressed: _showQuestionPalette,
            ),
        ],
      ),
      body: _session.isCompleted
          ? _buildResultsView(theme, isDark)
          : _buildTestInterfaceView(theme, isDark),
    );
  }

  // --- Active Test UI View ---
  Widget _buildTestInterfaceView(ThemeData theme, bool isDark) {
    final q = _session.currentQuestion;
    final selectedOption = _session.userAnswers[q.id];
    final remainingSecs = _session.remainingSeconds;

    Color timerColor = AppColors.primary;
    if (remainingSecs < 60) {
      timerColor = AppColors.danger;
    } else if (remainingSecs < 180) {
      timerColor = AppColors.warning;
    }

    return Column(
      children: [
        // Top Header: Timer + Skill Badge + Question Palette Button
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Skill Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getSkillIcon(q.skill),
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${q.skill.displayName} (${q.cefrLevel})',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              // Countdown Timer Widget
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: timerColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: timerColor.withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.timer_outlined, size: 18, color: timerColor),
                    const SizedBox(width: 6),
                    Text(
                      _formatTimer(remainingSecs),
                      style: TextStyle(
                        color: timerColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Progress Bar
        LinearProgressIndicator(
          value: (_session.currentQuestionIndex + 1) / _session.totalQuestions,
          backgroundColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          minHeight: 4,
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
                      'Question ${_session.currentQuestionIndex + 1} of ${_session.totalQuestions}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                    Text(
                      '${_session.answeredCount} answered',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Audio Player (If Listening Skill)
                if (q.skill == DiagnosticSkill.listening && q.audioUrl != null)
                  _buildAudioPlayerCard(theme, isDark, q),

                // Reading Passage Card (If Reading Skill)
                if (q.skill == DiagnosticSkill.reading && q.passage != null)
                  _buildReadingPassageCard(theme, isDark, q),

                // Question Prompt Card
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      q.prompt,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Answer Options List
                ...List.generate(q.options.length, (index) {
                  final isSelected = selectedOption == index;
                  final optionLabel = String.fromCharCode(65 + index); // A, B, C, D

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: InkWell(
                      onTap: () => _selectOption(index),
                      borderRadius: BorderRadius.circular(12),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withOpacity(0.12)
                              : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected ? AppColors.primary : (isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                optionLabel,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Colors.white : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                q.options[index],
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: isSelected ? AppColors.primary : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
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
              if (_session.currentQuestionIndex > 0)
                OutlinedButton.icon(
                  onPressed: _previousQuestion,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Previous'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                )
              else
                const SizedBox.shrink(),

              const Spacer(),

              // Next / Submit Button
              ElevatedButton.icon(
                onPressed: _isSubmitting
                    ? null
                    : () {
                        if (_session.currentQuestionIndex == _session.questions.length - 1) {
                          _showSubmitConfirmationDialog();
                        } else {
                          _nextQuestion();
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Icon(_session.currentQuestionIndex == _session.questions.length - 1
                        ? Icons.check_circle_outline
                        : Icons.arrow_forward),
                label: Text(
                  _session.currentQuestionIndex == _session.questions.length - 1
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

  // --- Audio Player Component ---
  Widget _buildAudioPlayerCard(ThemeData theme, bool isDark, PlacementQuestion q) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      color: AppColors.secondaryLight.withOpacity(0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.secondary, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.headphones, color: AppColors.secondary),
                const SizedBox(width: 8),
                Text(
                  'Listening Audio Stimulus',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                IconButton(
                  onPressed: _toggleAudioPlay,
                  icon: Icon(_isPlayingAudio ? Icons.pause_circle_filled : Icons.play_circle_fill),
                  iconSize: 40,
                  color: AppColors.secondary,
                ),
                Expanded(
                  child: LinearProgressIndicator(
                    value: _audioProgress,
                    backgroundColor: Colors.white,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondary),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${(_audioProgress * 30).round()}s / 30s',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- Reading Passage Component ---
  Widget _buildReadingPassageCard(ThemeData theme, bool isDark, PlacementQuestion q) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.menu_book, size: 18, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  'Reading Passage',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              q.passage!,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  // --- Results & Personalized Study Plan View ---
  Widget _buildResultsView(ThemeData theme, bool isDark) {
    final score = _calculatedScore!;
    final plan = _studyPlan!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner: Estimated Overall IELTS Band Score
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            gradient: const LinearGradient(
              colors: [Color(0xFF4F46E5), Color(0xFF0EA5E9)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Estimated IELTS Band Score',
                          style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              score.overallBand.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 44,
                                fontWeight: FontWeight.extrabold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              '/ 9.0',
                              style: TextStyle(fontSize: 18, color: Colors.white70, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'CEFR Level: ${score.cefrEquivalent}',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.15),
                      border: Border.all(color: Colors.white.withOpacity(0.4), width: 3),
                    ),
                    child: const Icon(Icons.workspace_premium_rounded, size: 40, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Skill Score Breakdown Grid
          Text(
            'Skill Proficiency Breakdown',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          GridView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.2,
            ),
            children: [
              _buildSkillBadgeCard('Grammar', score.grammarBand, Icons.spellcheck, AppColors.primary),
              _buildSkillBadgeCard('Vocabulary', score.vocabularyBand, Icons.translate, AppColors.secondary),
              _buildSkillBadgeCard('Reading', score.readingBand, Icons.menu_book, AppColors.success),
              _buildSkillBadgeCard('Listening', score.listeningBand, Icons.headphones, AppColors.warning),
            ],
          ),
          const SizedBox(height: 24),

          // Strengths & Weaknesses
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildFeedbackListCard(
                  title: 'Strengths',
                  items: score.strengths,
                  icon: Icons.check_circle_outline,
                  color: AppColors.success,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFeedbackListCard(
                  title: 'Focus Areas',
                  items: score.weaknesses,
                  icon: Icons.lightbulb_outline,
                  color: AppColors.warning,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Personalized Study Plan Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.auto_awesome, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text(
                            'Personalized IELTS Study Plan',
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Chip(
                        label: Text('Target Band ${plan.targetBand}'),
                        backgroundColor: AppColors.primaryLight,
                        labelStyle: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMetricTile('Daily Target', '${plan.recommendedDailyMinutes} mins/day'),
                      _buildMetricTile('Estimated Time', '${plan.estimatedWeeksToTarget} weeks'),
                      _buildMetricTile('Weekly Goals', '${plan.weeklySchedule.length} modules'),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Weekly Schedule List
                  Text(
                    'Recommended Daily Schedule:',
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ...plan.weeklySchedule.map((item) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 80,
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                item.day,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.focusSkill,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                  Text(
                                    item.action,
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${item.durationMinutes}m',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Action Buttons
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Study Plan saved to your profile!')),
                );
              },
              icon: const Icon(Icons.bookmark_added),
              label: const Text('Save Study Plan to Dashboard'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _initDiagnosticSession();
                });
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retake Diagnostic Test'),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillBadgeCard(String label, double score, IconData icon, Color color) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(
                    'Band ${score.toStringAsFixed(1)}',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.extrabold, color: color),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackListCard({
    required String title,
    required List<String> items,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 6),
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 8),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: Text('• $item', style: const TextStyle(fontSize: 12, height: 1.3)),
              )),
        ],
      ),
    );
  }

  Widget _buildMetricTile(String title, String value) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
      ],
    );
  }

  IconData _getSkillIcon(DiagnosticSkill skill) {
    switch (skill) {
      case DiagnosticSkill.grammar:
        return Icons.spellcheck;
      case DiagnosticSkill.vocabulary:
        return Icons.translate;
      case DiagnosticSkill.reading:
        return Icons.menu_book;
      case DiagnosticSkill.listening:
        return Icons.headphones;
    }
  }
}
