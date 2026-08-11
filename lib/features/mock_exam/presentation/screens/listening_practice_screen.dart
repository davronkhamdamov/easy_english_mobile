import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/exam_enums.dart';
import '../../domain/entities/mock_exam_result.dart';
import '../../domain/entities/mock_exam_section.dart';
import '../../domain/entities/mock_question.dart';
import '../../domain/services/mock_exam_scoring_service.dart';
import 'mock_result_screen.dart';

/// IELTS Listening Section Practice Screen.
class ListeningPracticeScreen extends StatefulWidget {
  final MockExamSection section;
  final ExamType examType;
  final String paperTitle;

  const ListeningPracticeScreen({
    super.key,
    required this.section,
    this.examType = ExamType.academic,
    this.paperTitle = 'Listening Section Practice',
  });

  @override
  State<ListeningPracticeScreen> createState() =>
      _ListeningPracticeScreenState();
}

class _ListeningPracticeScreenState extends State<ListeningPracticeScreen> {
  // Audio Player State Simulation
  bool _isPlaying = false;
  double _audioProgressSeconds = 0.0;
  final double _totalAudioDurationSeconds = 1800.0; // 30 minutes
  double _playbackSpeed = 1.0;
  bool _showTranscript = false;

  // Question Form State
  final Map<String, String> _userAnswers = {};

  // Section Countdown Timer
  late int _remainingSeconds;
  late int _elapsedSeconds;
  Timer? _timer;
  Timer? _audioTimer;

  List<MockQuestion> get _allQuestions => widget.section.allQuestions;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.section.timeLimitMinutes * 60;
    _elapsedSeconds = 0;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
          _elapsedSeconds++;
        });
      } else {
        _timer?.cancel();
        _submitSection(autoSubmitted: true);
      }
    });
  }

  void _toggleAudioPlayback() {
    setState(() {
      _isPlaying = !_isPlaying;
    });

    if (_isPlaying) {
      _audioTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_audioProgressSeconds < _totalAudioDurationSeconds) {
          setState(() {
            _audioProgressSeconds =
                (_audioProgressSeconds + (1.0 * _playbackSpeed)).clamp(
                  0.0,
                  _totalAudioDurationSeconds,
                );
          });
        } else {
          _audioTimer?.cancel();
          setState(() {
            _isPlaying = false;
          });
        }
      });
    } else {
      _audioTimer?.cancel();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioTimer?.cancel();
    super.dispose();
  }

  String _formatTimer(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String _formatAudioTime(double seconds) {
    final s = seconds.toInt();
    final mins = s ~/ 60;
    final secs = s % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
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

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.paperTitle,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Listening Practice • 10-Question Completion Form',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          // Timer Widget
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.alarm_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatTimer(_remainingSeconds),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Audio Player Control Panel Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
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
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.primaryLight,
                        child: Icon(
                          Icons.multitrack_audio_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.section.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: textPrimary,
                            ),
                          ),
                          const Text(
                            'Official Audio Track',
                            style: TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Speed Dropdown Pill
                      PopupMenuButton<double>(
                        initialValue: _playbackSpeed,
                        onSelected: (spd) {
                          setState(() {
                            _playbackSpeed = spd;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_playbackSpeed}x Speed',
                            style: const TextStyle(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        itemBuilder: (ctx) => [
                          const PopupMenuItem(
                            value: 0.8,
                            child: Text('0.8x Speed'),
                          ),
                          const PopupMenuItem(
                            value: 1.0,
                            child: Text('1.0x Speed (Normal)'),
                          ),
                          const PopupMenuItem(
                            value: 1.25,
                            child: Text('1.25x Speed'),
                          ),
                          const PopupMenuItem(
                            value: 1.5,
                            child: Text('1.5x Speed'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Slider & Timestamps
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      thumbColor: AppColors.primary,
                      activeTrackColor: AppColors.primary,
                      inactiveTrackColor: Colors.grey.shade300,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 6,
                      ),
                    ),
                    child: Slider(
                      value: _audioProgressSeconds,
                      max: _totalAudioDurationSeconds,
                      onChanged: (val) {
                        setState(() {
                          _audioProgressSeconds = val;
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatAudioTime(_audioProgressSeconds),
                          style: TextStyle(
                            fontSize: 12,
                            color: textSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _formatAudioTime(_totalAudioDurationSeconds),
                          style: TextStyle(fontSize: 12, color: textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Play / Pause & Rewind / Forward Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.replay_10_rounded, size: 28),
                        onPressed: () {
                          setState(() {
                            _audioProgressSeconds = (_audioProgressSeconds - 10)
                                .clamp(0.0, _totalAudioDurationSeconds);
                          });
                        },
                      ),
                      const SizedBox(width: 16),
                      FloatingActionButton.small(
                        backgroundColor: AppColors.primary,
                        onPressed: _toggleAudioPlayback,
                        child: Icon(
                          _isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: const Icon(Icons.forward_10_rounded, size: 28),
                        onPressed: () {
                          setState(() {
                            _audioProgressSeconds = (_audioProgressSeconds + 10)
                                .clamp(0.0, _totalAudioDurationSeconds);
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Transcript Toggle & Collapsible Box
            Material(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                  ),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(
                        Icons.subtitles_outlined,
                        color: AppColors.secondary,
                      ),
                      title: const Text(
                        'Audio Transcript',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        _showTranscript
                            ? 'Tap to hide transcript'
                            : 'Tap to reveal transcript text',
                        style: const TextStyle(fontSize: 11),
                      ),
                      trailing: Icon(
                        _showTranscript ? Icons.expand_less : Icons.expand_more,
                      ),
                      onTap: () {
                        setState(() {
                          _showTranscript = !_showTranscript;
                        });
                      },
                    ),
                    if (_showTranscript && widget.section.transcript != null)
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          bottom: 16,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkSurfaceVariant
                                : AppColors.lightSurfaceVariant,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            widget.section.transcript!,
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.5,
                              color: textPrimary,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 10-Question Completion Form Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Questions (${_allQuestions.length})',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: textPrimary,
                  ),
                ),
                Text(
                  'Completed ${_userAnswers.values.where((v) => v.isNotEmpty).length}/${_allQuestions.length}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Questions List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _allQuestions.length,
              itemBuilder: (context, index) {
                final q = _allQuestions[index];
                return _buildQuestionCard(
                  context,
                  q,
                  index,
                  isDark,
                  textPrimary,
                );
              },
            ),
            const SizedBox(height: 24),

            // Submit Button
            ElevatedButton(
              onPressed: () => _submitSection(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Submit Listening Answers',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard(
    BuildContext context,
    MockQuestion q,
    int index,
    bool isDark,
    Color textPrimary,
  ) {
    final cardColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    q.prompt,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildListeningInput(q, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildListeningInput(MockQuestion q, bool isDark) {
    switch (q.questionType) {
      case QuestionType.multipleChoice:
        return RadioGroup<String>(
          groupValue: _userAnswers[q.id],
          onChanged: (val) {
            setState(() {
              if (val != null) _userAnswers[q.id] = val;
            });
          },
          child: Column(
            children: q.options.map((opt) {
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                child: RadioListTile<String>(
                  value: opt,
                  title: Text(opt, style: const TextStyle(fontSize: 13)),
                  activeColor: AppColors.primary,
                  dense: true,
                ),
              );
            }).toList(),
          ),
        );

      case QuestionType.trueFalseNotGiven:
        final options = ['True', 'False', 'Not Given'];
        return Row(
          children: options.map((opt) {
            final isSelected = _userAnswers[q.id] == opt;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: ChoiceChip(
                  label: Text(opt),
                  selected: isSelected,
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) _userAnswers[q.id] = opt;
                    });
                  },
                ),
              ),
            );
          }).toList(),
        );

      case QuestionType.sentenceCompletion:
        final controller = TextEditingController(
          text: _userAnswers[q.id] ?? '',
        );
        controller.selection = TextSelection.fromPosition(
          TextPosition(offset: controller.text.length),
        );

        return TextField(
          controller: controller,
          onChanged: (val) {
            _userAnswers[q.id] = val.trim();
          },
          decoration: InputDecoration(
            hintText: 'Type answer heard in audio...',
            hintStyle: const TextStyle(fontSize: 12),
            filled: true,
            fillColor: isDark
                ? AppColors.darkSurfaceVariant
                : AppColors.lightSurfaceVariant,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        );
    }
  }

  void _submitSection({bool autoSubmitted = false}) {
    _timer?.cancel();
    _audioTimer?.cancel();

    int rawScore = 0;
    for (final q in _allQuestions) {
      final userAns = (_userAnswers[q.id] ?? '').trim().toLowerCase();
      final correctAns = q.correctAnswer.trim().toLowerCase();

      if (userAns.isNotEmpty &&
          (userAns == correctAns || correctAns.contains(userAns))) {
        rawScore++;
      }
    }

    final listeningBand = IeltsBandConverter.calculateSectionBand(
      skill: MockSkill.listening,
      rawScore: rawScore,
      examType: widget.examType,
    );

    final overallBand = IeltsBandConverter.calculateOverallBand([
      listeningBand,
      6.5,
    ]);

    final result = MockExamResult(
      id: 'res_listening_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'student_user_1',
      examPaperId: widget.section.id,
      examTitle: widget.paperTitle,
      examType: widget.examType,
      overallBand: overallBand,
      readingBand: 0.0,
      listeningBand: listeningBand,
      writingBand: 6.5,
      speakingBand: 6.5,
      readingRawScore: 0,
      listeningRawScore: rawScore,
      totalReadingQuestions: 0,
      totalListeningQuestions: _allQuestions.length,
      timeTakenSeconds: _elapsedSeconds,
      userAnswers: _userAnswers,
      allQuestions: _allQuestions,
      createdAt: DateTime.now(),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => MockResultScreen(result: result)),
    );
  }
}
