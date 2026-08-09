import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/grammar_exercise.dart';
import '../../domain/entities/grammar_mistake_record.dart';
import '../../domain/entities/grammar_rule.dart';
import '../../domain/entities/grammar_topic.dart';

/// Interactive Grammar Exercise Screen with Rule Explanations, Feedback Cards, and Summary.
class GrammarExerciseScreen extends StatefulWidget {
  final GrammarTopic topic;

  const GrammarExerciseScreen({Key? key, required this.topic})
    : super(key: key);

  @override
  State<GrammarExerciseScreen> createState() => _GrammarExerciseScreenState();
}

class _GrammarExerciseScreenState extends State<GrammarExerciseScreen> {
  int _currentIndex = 0;
  String? _selectedOption;
  final TextEditingController _fillBlankController = TextEditingController();
  bool _isAnswerSubmitted = false;
  bool _isCorrect = false;

  int _score = 0;
  final List<GrammarMistakeRecord> _sessionMistakes = [];
  bool _showRuleCard = false;

  List<GrammarExercise> get _exercises => widget.topic.exercises;
  GrammarExercise get _currentExercise => _exercises[_currentIndex];

  GrammarRule? get _currentRule {
    try {
      return widget.topic.rules.firstWhere(
        (r) => r.id == _currentExercise.ruleId,
      );
    } catch (_) {
      return widget.topic.rules.isNotEmpty ? widget.topic.rules.first : null;
    }
  }

  @override
  void dispose() {
    _fillBlankController.dispose();
    super.dispose();
  }

  void _submitAnswer() {
    if (_isAnswerSubmitted) return;

    final exercise = _currentExercise;
    String userAnswer = '';

    if (exercise.type == ExerciseType.multipleChoice) {
      if (_selectedOption == null) return;
      userAnswer = _selectedOption!;
    } else {
      userAnswer = _fillBlankController.text.trim();
      if (userAnswer.isEmpty) return;
    }

    final isRight =
        userAnswer.toLowerCase() == exercise.correctAnswer.toLowerCase();

    setState(() {
      _isAnswerSubmitted = true;
      _isCorrect = isRight;
      if (isRight) {
        _score++;
      } else {
        // Log mistake record for instant feedback and long-term tracking
        _sessionMistakes.add(
          GrammarMistakeRecord(
            id: 'session_mistake_${DateTime.now().millisecondsSinceEpoch}',
            topicCategory: widget.topic.title.split('(').first.trim(),
            originalSentence: exercise.sentenceWithBlank != null
                ? exercise.sentenceWithBlank!.replaceAll(
                    '_____',
                    '"$userAnswer"',
                  )
                : 'User selected: "$userAnswer"',
            correctedSentence: exercise.sentenceWithBlank != null
                ? exercise.sentenceWithBlank!.replaceAll(
                    '_____',
                    '"${exercise.correctAnswer}"',
                  )
                : 'Correct answer: "${exercise.correctAnswer}"',
            explanation: exercise.explanation,
            occurrenceCount: 1,
            firstSeenAt: DateTime.now(),
            lastSeenAt: DateTime.now(),
          ),
        );
      }
    });
  }

  void _nextQuestion() {
    if (_currentIndex < _exercises.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOption = null;
        _fillBlankController.clear();
        _isAnswerSubmitted = false;
        _isCorrect = false;
        _showRuleCard = false;
      });
    } else {
      _showMasterySummaryDialog();
    }
  }

  double get _calculatedMastery {
    if (_exercises.isEmpty) return widget.topic.masteryPercentage;
    final ratio = _score / _exercises.length;
    final newScore = (ratio * 100.0);
    // Blend with previous mastery level
    return (widget.topic.masteryPercentage * 0.4 + newScore * 0.6).clamp(
      0.0,
      100.0,
    );
  }

  void _showMasterySummaryDialog() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final finalMastery = _calculatedMastery;
    final isPassed = finalMastery >= 70.0;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDark
              ? AppColors.darkSurface
              : AppColors.lightSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Column(
            children: [
              Icon(
                isPassed
                    ? Icons.emoji_events_rounded
                    : Icons.replay_circle_filled_rounded,
                size: 56,
                color: isPassed ? AppColors.warning : AppColors.primary,
              ),
              const SizedBox(height: 12),
              Text(
                isPassed
                    ? 'Topic Mastery Achieved!'
                    : 'Practice Session Complete',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'You scored $_score out of ${_exercises.length} correct.',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 16),

              // Updated Mastery Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurfaceVariant
                      : AppColors.lightSurfaceVariant,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isPassed ? AppColors.success : AppColors.primary,
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      'New Topic Mastery Rating',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${finalMastery.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: isPassed ? AppColors.success : AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: finalMastery / 100.0,
                        minHeight: 8,
                        backgroundColor: Colors.grey.withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isPassed ? AppColors.success : AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              if (_sessionMistakes.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  '${_sessionMistakes.length} mistake(s) logged to your long-term mistake tracker.',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.danger,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(
                  context,
                  finalMastery,
                ); // Return updated mastery to roadmap
              },
              child: const Text('Back to Roadmap'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                setState(() {
                  _currentIndex = 0;
                  _score = 0;
                  _selectedOption = null;
                  _fillBlankController.clear();
                  _isAnswerSubmitted = false;
                  _sessionMistakes.clear();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry Session'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final exercise = _currentExercise;
    final rule = _currentRule;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          widget.topic.title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          if (rule != null)
            IconButton(
              icon: Icon(
                _showRuleCard ? Icons.lightbulb : Icons.lightbulb_outline,
                color: _showRuleCard ? AppColors.warning : null,
              ),
              tooltip: 'Rule Explanation',
              onPressed: () {
                setState(() {
                  _showRuleCard = !_showRuleCard;
                });
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Question ${_currentIndex + 1} of ${_exercises.length}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Score: $_score',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: (_currentIndex + 1) / _exercises.length,
                minHeight: 6,
                backgroundColor: isDark
                    ? AppColors.darkSurfaceVariant
                    : AppColors.lightSurfaceVariant,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primary,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Expandable Rule Explanation Card
            if (rule != null && _showRuleCard) ...[
              _buildRuleExplanationCard(rule, theme, isDark),
              const SizedBox(height: 16),
            ],

            // Question Card
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Prompt
                  Text(
                    exercise.prompt,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Sentence with blank
                  if (exercise.sentenceWithBlank != null)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurfaceVariant
                            : AppColors.lightSurfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        exercise.sentenceWithBlank!,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Input choices: Multiple Choice or Fill-in-the-blank
                  if (exercise.type == ExerciseType.multipleChoice) ...[
                    ...exercise.options.map((opt) {
                      final isSelected = _selectedOption == opt;
                      Color optionBorder = isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder;
                      Color optionBg = isDark
                          ? AppColors.darkSurfaceVariant
                          : AppColors.lightSurfaceVariant;

                      if (_isAnswerSubmitted) {
                        if (opt.toLowerCase() ==
                            exercise.correctAnswer.toLowerCase()) {
                          optionBorder = AppColors.success;
                          optionBg = AppColors.success.withOpacity(0.15);
                        } else if (isSelected && !_isCorrect) {
                          optionBorder = AppColors.danger;
                          optionBg = AppColors.danger.withOpacity(0.15);
                        }
                      } else if (isSelected) {
                        optionBorder = AppColors.primary;
                        optionBg = AppColors.primary.withOpacity(0.12);
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: InkWell(
                          onTap: _isAnswerSubmitted
                              ? null
                              : () {
                                  setState(() {
                                    _selectedOption = opt;
                                  });
                                },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: optionBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: optionBorder,
                                width: isSelected || _isAnswerSubmitted
                                    ? 2.0
                                    : 1.0,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _isAnswerSubmitted &&
                                          opt.toLowerCase() ==
                                              exercise.correctAnswer
                                                  .toLowerCase()
                                      ? Icons.check_circle_rounded
                                      : (_isAnswerSubmitted &&
                                                isSelected &&
                                                !_isCorrect
                                            ? Icons.cancel_rounded
                                            : (isSelected
                                                  ? Icons.radio_button_checked
                                                  : Icons.radio_button_off)),
                                  color:
                                      _isAnswerSubmitted &&
                                          opt.toLowerCase() ==
                                              exercise.correctAnswer
                                                  .toLowerCase()
                                      ? AppColors.success
                                      : (_isAnswerSubmitted &&
                                                isSelected &&
                                                !_isCorrect
                                            ? AppColors.danger
                                            : (isSelected
                                                  ? AppColors.primary
                                                  : Colors.grey)),
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    opt,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      color: isDark
                                          ? AppColors.darkTextPrimary
                                          : AppColors.lightTextPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ] else ...[
                    // Fill-in-the-blank TextField
                    TextField(
                      controller: _fillBlankController,
                      enabled: !_isAnswerSubmitted,
                      decoration: InputDecoration(
                        hintText: 'Type your answer here...',
                        filled: true,
                        fillColor: isDark
                            ? AppColors.darkSurfaceVariant
                            : AppColors.lightSurfaceVariant,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Submit Button if not submitted
            if (!_isAnswerSubmitted)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      (_selectedOption != null ||
                          _fillBlankController.text.trim().isNotEmpty)
                      ? _submitAnswer
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Check Answer',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

            // Instant Explanation Feedback Card upon answer selection
            if (_isAnswerSubmitted) ...[
              _buildFeedbackCard(exercise, isDark),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _nextQuestion,
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: Text(
                    _currentIndex < _exercises.length - 1
                        ? 'Next Question'
                        : 'View Session Results',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isCorrect
                        ? AppColors.success
                        : AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildRuleExplanationCard(
    GrammarRule rule,
    ThemeData theme,
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2638) : AppColors.primaryLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.4)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.lightbulb_rounded,
                color: AppColors.warning,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Grammar Rule: ${rule.title}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            rule.detailedExplanation,
            style: TextStyle(
              fontSize: 12,
              height: 1.4,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
          if (rule.examples.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text(
              'Example:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11,
                color: Colors.grey,
              ),
            ),
            Text(
              '• ${rule.examples.first}',
              style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFeedbackCard(GrammarExercise exercise, bool isDark) {
    final color = _isCorrect ? AppColors.success : AppColors.danger;
    final bgColor = _isCorrect
        ? (isDark ? const Color(0xFF064E3B) : AppColors.successLight)
        : (isDark ? const Color(0xFF7F1D1D) : AppColors.dangerLight);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.6), width: 1.5),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: color,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                _isCorrect ? 'Correct! Excellent job.' : 'Incorrect Answer',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          if (!_isCorrect) ...[
            Text(
              'Correct Answer: ${exercise.correctAnswer}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
          ],

          Text(
            exercise.explanation,
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: isDark
                  ? Colors.white.withOpacity(0.9)
                  : Colors.black.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}
