import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/exam_enums.dart';
import '../../domain/entities/mock_exam_result.dart';
import '../../domain/entities/mock_exam_section.dart';
import '../../domain/entities/mock_question.dart';
import '../../domain/services/mock_exam_scoring_service.dart';
import 'mock_result_screen.dart';

/// IELTS Reading Section Practice Screen.
class ReadingPracticeScreen extends StatefulWidget {
  final MockExamSection section;
  final ExamType examType;
  final String paperTitle;

  const ReadingPracticeScreen({
    Key? key,
    required this.section,
    this.examType = ExamType.academic,
    this.paperTitle = 'Academic Reading Test',
  }) : super(key: key);

  @override
  State<ReadingPracticeScreen> createState() => _ReadingPracticeScreenState();
}

class _ReadingPracticeScreenState extends State<ReadingPracticeScreen> {
  int _activePassageIndex = 0;
  int _activeQuestionIndex = 0;
  double _fontSize = 15.0;

  // Question State Maps
  final Map<String, String> _userAnswers = {};
  final Set<String> _flaggedQuestions = {};

  // Countdown Timer
  late int _remainingSeconds;
  Timer? _timer;
  late int _elapsedSeconds;

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

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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

    final passages = widget.section.passages;
    final currentPassage = passages.isNotEmpty
        ? passages[_activePassageIndex]
        : null;

    final currentQuestion = _allQuestions.isNotEmpty
        ? _allQuestions[_activeQuestionIndex.clamp(0, _allQuestions.length - 1)]
        : null;

    final isLowTime = _remainingSeconds < 300; // < 5 mins

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
            Text(
              'Academic Reading • Section ${_activePassageIndex + 1}',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          // Text Size Controls
          IconButton(
            icon: const Icon(Icons.text_fields, size: 20),
            tooltip: 'Adjust Text Size',
            onPressed: () {
              setState(() {
                _fontSize = _fontSize >= 19.0 ? 13.0 : _fontSize + 2.0;
              });
            },
          ),
          // Timer Widget
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isLowTime
                  ? AppColors.danger.withOpacity(0.2)
                  : AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isLowTime ? AppColors.danger : AppColors.primary,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.alarm_rounded,
                  size: 16,
                  color: isLowTime ? AppColors.danger : AppColors.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatTimer(_remainingSeconds),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isLowTime ? AppColors.danger : AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.grid_view_rounded),
            tooltip: 'Question Palette',
            onPressed: () => _openQuestionPaletteModal(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Passage Selector Tabs
          if (passages.length > 1)
            Container(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              child: Row(
                children: List.generate(passages.length, (idx) {
                  final isSelected = idx == _activePassageIndex;
                  return Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _activePassageIndex = idx;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.transparent,
                              width: 2.5,
                            ),
                          ),
                        ),
                        child: Text(
                          'Passage ${idx + 1}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? AppColors.primary
                                : (isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

          // Main Split / Scroll View (Passage Viewer Top, Question Bottom)
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Flex(
                  direction: constraints.maxWidth > 800
                      ? Axis.horizontal
                      : Axis.vertical,
                  children: [
                    // Passage Viewer Panel
                    Expanded(
                      flex: constraints.maxWidth > 800 ? 1 : 1,
                      child: Container(
                        margin: const EdgeInsets.all(12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkSurface
                              : AppColors.lightSurface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder,
                          ),
                        ),
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (currentPassage != null) ...[
                                Text(
                                  currentPassage.title,
                                  style: TextStyle(
                                    fontSize: _fontSize + 3,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? AppColors.darkTextPrimary
                                        : AppColors.lightTextPrimary,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                SelectableText(
                                  currentPassage.content,
                                  style: TextStyle(
                                    fontSize: _fontSize,
                                    height: 1.6,
                                    color: isDark
                                        ? AppColors.darkTextPrimary
                                        : AppColors.lightTextPrimary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Question Card Panel
                    Expanded(
                      flex: constraints.maxWidth > 800 ? 1 : 1,
                      child: Container(
                        margin: const EdgeInsets.all(12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkSurface
                              : AppColors.lightSurface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder,
                          ),
                        ),
                        child: currentQuestion != null
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Question Header & Flag Toggle
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.secondary
                                              .withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          'Question ${_activeQuestionIndex + 1} of ${_allQuestions.length}',
                                          style: const TextStyle(
                                            color: AppColors.secondary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          _flaggedQuestions.contains(
                                                currentQuestion.id,
                                              )
                                              ? Icons.bookmark_rounded
                                              : Icons.bookmark_border_rounded,
                                          color:
                                              _flaggedQuestions.contains(
                                                currentQuestion.id,
                                              )
                                              ? AppColors.warning
                                              : Colors.grey,
                                        ),
                                        tooltip: 'Flag for Review',
                                        onPressed: () {
                                          setState(() {
                                            if (_flaggedQuestions.contains(
                                              currentQuestion.id,
                                            )) {
                                              _flaggedQuestions.remove(
                                                currentQuestion.id,
                                              );
                                            } else {
                                              _flaggedQuestions.add(
                                                currentQuestion.id,
                                              );
                                            }
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),

                                  // Question Prompt
                                  Text(
                                    currentQuestion.prompt,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? AppColors.darkTextPrimary
                                          : AppColors.lightTextPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Question Options Builder
                                  Expanded(
                                    child: SingleChildScrollView(
                                      child: _buildQuestionInputWidget(
                                        currentQuestion,
                                        isDark,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : const Center(child: Text('No questions found.')),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // Bottom Navigation Bar
          Container(
            padding: const EdgeInsets.all(12),
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_rounded),
                  onPressed: _activeQuestionIndex > 0
                      ? () {
                          setState(() {
                            _activeQuestionIndex--;
                          });
                        }
                      : null,
                ),
                Text(
                  'Q ${_activeQuestionIndex + 1} / ${_allQuestions.length}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios_rounded),
                  onPressed: _activeQuestionIndex < _allQuestions.length - 1
                      ? () {
                          setState(() {
                            _activeQuestionIndex++;
                          });
                        }
                      : null,
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () => _showSubmitConfirmationDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Submit Section',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionInputWidget(MockQuestion question, bool isDark) {
    switch (question.questionType) {
      case QuestionType.multipleChoice:
        return Column(
          children: question.options.map((opt) {
            final isSelected = _userAnswers[question.id] == opt;
            return Material(
              color: isSelected
                  ? AppColors.primary.withOpacity(0.12)
                  : (isDark
                        ? AppColors.darkSurfaceVariant
                        : AppColors.lightSurfaceVariant),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: ListTile(
                  title: Text(
                    opt,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  leading: Radio<String>(
                    value: opt,
                    groupValue: _userAnswers[question.id],
                    activeColor: AppColors.primary,
                    onChanged: (val) {
                      setState(() {
                        if (val != null) _userAnswers[question.id] = val;
                      });
                    },
                  ),
                  onTap: () {
                    setState(() {
                      _userAnswers[question.id] = opt;
                    });
                  },
                ),
              ),
            );
          }).toList(),
        );

      case QuestionType.trueFalseNotGiven:
        final options = ['True', 'False', 'Not Given'];
        return Column(
          children: options.map((opt) {
            final isSelected = _userAnswers[question.id] == opt;
            Color optColor = AppColors.primary;
            if (opt == 'True') optColor = AppColors.success;
            if (opt == 'False') optColor = AppColors.danger;
            if (opt == 'Not Given') optColor = AppColors.warning;

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _userAnswers[question.id] = opt;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? optColor.withOpacity(0.15)
                        : (isDark
                              ? AppColors.darkSurfaceVariant
                              : AppColors.lightSurfaceVariant),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? optColor : Colors.transparent,
                      width: 2.0,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        opt,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? optColor
                              : (isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary),
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_circle_rounded,
                          color: optColor,
                          size: 20,
                        ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );

      case QuestionType.sentenceCompletion:
        final textController = TextEditingController(
          text: _userAnswers[question.id] ?? '',
        );
        textController.selection = TextSelection.fromPosition(
          TextPosition(offset: textController.text.length),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Type your answer exactly as it appears in the passage (1-3 words):',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: textController,
              onChanged: (val) {
                _userAnswers[question.id] = val.trim();
              },
              decoration: InputDecoration(
                hintText: 'Enter answer...',
                filled: true,
                fillColor: isDark
                    ? AppColors.darkSurfaceVariant
                    : AppColors.lightSurfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
              ),
            ),
          ],
        );
    }
  }

  void _openQuestionPaletteModal(BuildContext context) {
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
            children: [
              const Text(
                'Question Palette',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 14),
              GridView.builder(
                shrinkWrap: true,
                itemCount: _allQuestions.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemBuilder: (context, idx) {
                  final q = _allQuestions[idx];
                  final isAnswered =
                      _userAnswers.containsKey(q.id) &&
                      _userAnswers[q.id]!.isNotEmpty;
                  final isFlagged = _flaggedQuestions.contains(q.id);

                  Color bg = Colors.grey.shade300;
                  if (isAnswered) bg = AppColors.primary;
                  if (isFlagged) bg = AppColors.warning;

                  return InkWell(
                    onTap: () {
                      Navigator.pop(ctx);
                      setState(() {
                        _activeQuestionIndex = idx;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${idx + 1}',
                          style: TextStyle(
                            color: isAnswered || isFlagged
                                ? Colors.white
                                : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
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

  void _showSubmitConfirmationDialog(BuildContext context) {
    final answeredCount = _userAnswers.values.where((v) => v.isNotEmpty).length;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Submit Reading Section?'),
        content: Text(
          'You have answered $answeredCount of ${_allQuestions.length} questions.\n'
          'Time remaining: ${_formatTimer(_remainingSeconds)}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _submitSection();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            child: const Text(
              'Confirm Submit',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _submitSection({bool autoSubmitted = false}) {
    _timer?.cancel();

    // Calculate raw score
    int rawScore = 0;
    for (final q in _allQuestions) {
      final userAns = (_userAnswers[q.id] ?? '').trim().toLowerCase();
      final correctAns = q.correctAnswer.trim().toLowerCase();

      if (userAns.isNotEmpty &&
          (userAns == correctAns || correctAns.contains(userAns))) {
        rawScore++;
      }
    }

    final readingBand = IeltsBandConverter.calculateSectionBand(
      skill: MockSkill.reading,
      rawScore: rawScore,
      examType: widget.examType,
    );

    final overallBand = IeltsBandConverter.calculateOverallBand([
      readingBand,
      6.5,
    ]);

    final result = MockExamResult(
      id: 'res_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'student_user_1',
      examPaperId: widget.section.id,
      examTitle: widget.paperTitle,
      examType: widget.examType,
      overallBand: overallBand,
      readingBand: readingBand,
      listeningBand: 0.0,
      writingBand: 6.5,
      speakingBand: 6.5,
      readingRawScore: rawScore,
      listeningRawScore: 0,
      totalReadingQuestions: _allQuestions.length,
      totalListeningQuestions: 0,
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
