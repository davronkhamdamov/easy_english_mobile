import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../design_system/components/badge/ds_badge.dart';
import '../../../../design_system/components/button/ds_button.dart';
import '../../../../design_system/components/rich_markdown/ds_rich_markdown.dart';
import '../../../../design_system/components/rich_markdown/ds_rich_markdown_theme.dart';
import '../../data/ielts_article_test_data.dart';
import '../../domain/entities/ielts_test_models.dart';

/// Full comprehensive IELTS Reading & Testing Screen featuring:
/// 1. Rich article format with [DSRichMarkdown], paragraph identifiers, callouts, and interactive dictionary lookups.
/// 2. Comprehensive support for EVERY IELTS question type:
///    - Multiple Choice (Single answer)
///    - Multiple Choice (Multi-select: pick 2 or more)
///    - True / False / Not Given (TFNG) & Yes / No / Not Given (YNNG)
///    - Sentence Completion & Fill in the Blanks (with word limits)
///    - Matching Headings (Roman numerals to paragraphs)
///    - Matching Features / Information (Statements to researchers/theories)
///    - Short Answer Questions (with strict word count restrictions)
/// 3. Split-view & Quick-peek floating sheet for instantaneous passage lookup while answering questions.
/// 4. Timed exam mode with countdown, score calculation, Band score estimation (1.0 - 9.0), and full answer explanations.
class IeltsArticleTestScreen extends StatefulWidget {
  final IeltsArticleTestData? initialTest;
  final VoidCallback? onBack;

  const IeltsArticleTestScreen({
    super.key,
    this.initialTest,
    this.onBack,
  });

  @override
  State<IeltsArticleTestScreen> createState() => _IeltsArticleTestScreenState();
}

class _IeltsArticleTestScreenState extends State<IeltsArticleTestScreen>
    with SingleTickerProviderStateMixin {
  late IeltsArticleTestData _currentTest;
  late TabController _tabController;

  // Passage styling state
  double _fontSize = 15.0;
  final bool _enableWordLookup = true;

  // User answers map: questionId -> value
  // - single MCQ / TFNG: String (e.g. 'B', 'TRUE')
  // - multi MCQ: Set<String> (e.g. {'A', 'C'})
  // - fill in the blank / short answer: String
  // - matching headings: Map<String, String> (paragraphId -> headingId)
  // - matching features: Map<String, String> (statement -> optionKey)
  final Map<String, dynamic> _userAnswers = {};

  // Controllers for text input questions
  final Map<String, TextEditingController> _textControllers = {};

  // Exam timer state
  late int _remainingSeconds;
  Timer? _examTimer;
  bool _isTimerRunning = false;

  // Test completion state
  bool _isSubmitted = false;
  int _score = 0;
  int _totalPossiblePoints = 0;
  double _estimatedBandScore = 0.0;

  @override
  void initState() {
    super.initState();
    _currentTest = widget.initialTest ?? IeltsArticleTestPresets.urbanCanopyTest;
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    _initTestState();
  }

  void _initTestState() {
    _userAnswers.clear();
    for (final controller in _textControllers.values) {
      controller.dispose();
    }
    _textControllers.clear();

    for (final q in _currentTest.questions) {
      if (q.type == IeltsQuestionType.fillInTheBlank ||
          q.type == IeltsQuestionType.shortAnswer) {
        _textControllers[q.id] = TextEditingController();
      } else if (q.type == IeltsQuestionType.matchingHeadings) {
        _userAnswers[q.id] = <String, String>{};
      } else if (q.type == IeltsQuestionType.matchingFeatures) {
        _userAnswers[q.id] = <String, String>{};
      } else if (q.type == IeltsQuestionType.multipleChoiceMulti) {
        _userAnswers[q.id] = <String>{};
      }
    }

    _isSubmitted = false;
    _score = 0;
    _totalPossiblePoints = 0;
    _estimatedBandScore = 0.0;

    _remainingSeconds = _currentTest.recommendedMinutes * 60;
    _startTimer();
  }

  void _startTimer() {
    _examTimer?.cancel();
    _isTimerRunning = true;
    _examTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        timer.cancel();
        _isTimerRunning = false;
        _showTimeUpDialog();
      }
    });
  }

  void _toggleTimer() {
    if (_isTimerRunning) {
      _examTimer?.cancel();
      setState(() => _isTimerRunning = false);
    } else {
      _startTimer();
    }
  }

  @override
  void dispose() {
    _examTimer?.cancel();
    _tabController.dispose();
    for (final controller in _textControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _switchTest(IeltsArticleTestData newTest) {
    setState(() {
      _currentTest = newTest;
      _initTestState();
      _tabController.index = 0;
    });
  }

  // Answer recording helpers
  void _recordSingleAnswer(String questionId, String val) {
    if (_isSubmitted) return;
    HapticFeedback.selectionClick();
    setState(() {
      _userAnswers[questionId] = val;
    });
  }

  void _toggleMultiAnswer(String questionId, String optionLetter, int maxPicks) {
    if (_isSubmitted) return;
    HapticFeedback.selectionClick();
    setState(() {
      final current = Set<String>.from((_userAnswers[questionId] as Set?) ?? {});
      if (current.contains(optionLetter)) {
        current.remove(optionLetter);
      } else {
        if (current.length < maxPicks) {
          current.add(optionLetter);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('You can only select up to $maxPicks options for this question.'),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
      _userAnswers[questionId] = current;
    });
  }

  void _recordTextAnswer(String questionId, String text) {
    if (_isSubmitted) return;
    _userAnswers[questionId] = text.trim();
  }

  void _recordHeadingMatch(String questionId, String paragraphId, String headingId) {
    if (_isSubmitted) return;
    HapticFeedback.selectionClick();
    setState(() {
      final map = Map<String, String>.from((_userAnswers[questionId] as Map?) ?? {});
      map[paragraphId] = headingId;
      _userAnswers[questionId] = map;
    });
  }

  void _recordFeatureMatch(String questionId, String statement, String optionKey) {
    if (_isSubmitted) return;
    HapticFeedback.selectionClick();
    setState(() {
      final map = Map<String, String>.from((_userAnswers[questionId] as Map?) ?? {});
      map[statement] = optionKey;
      _userAnswers[questionId] = map;
    });
  }

  // ==========================================
  // SCORING & BAND CONVERSION
  // ==========================================

  void _submitTest() {
    int points = 0;
    int total = 0;

    for (final q in _currentTest.questions) {
      switch (q.type) {
        case IeltsQuestionType.multipleChoiceSingle:
        case IeltsQuestionType.trueFalseNotGiven:
        case IeltsQuestionType.yesNoNotGiven:
          total += 1;
          final userAns = (_userAnswers[q.id] as String?)?.trim().toUpperCase();
          final corrAns = (q.correctAnswer as String).trim().toUpperCase();
          if (userAns == corrAns) points += 1;
          break;

        case IeltsQuestionType.multipleChoiceMulti:
          final expected = Set<String>.from(q.correctAnswer as List);
          total += expected.length;
          final userSet = Set<String>.from((_userAnswers[q.id] as Set?) ?? {});
          for (final opt in userSet) {
            if (expected.contains(opt)) points += 1;
          }
          break;

        case IeltsQuestionType.fillInTheBlank:
        case IeltsQuestionType.shortAnswer:
          total += 1;
          final rawUser = ((_userAnswers[q.id] as String?) ?? _textControllers[q.id]?.text ?? '')
              .trim()
              .toLowerCase()
              .replaceAll(RegExp(r'\s+'), ' ');
          final acceptable = [
            (q.correctAnswer as String).trim().toLowerCase(),
            ...q.acceptableAnswers.map((a) => a.trim().toLowerCase()),
          ];
          if (acceptable.contains(rawUser)) {
            points += 1;
          }
          break;

        case IeltsQuestionType.matchingHeadings:
          final items = q.headingMatchItems ?? [];
          total += items.length;
          final userMap = Map<String, String>.from((_userAnswers[q.id] as Map?) ?? {});
          for (final item in items) {
            if (userMap[item.paragraphId] == item.correctHeadingId) {
              points += 1;
            }
          }
          break;

        case IeltsQuestionType.matchingFeatures:
          final items = q.featureMatchItems ?? [];
          total += items.length;
          final userMap = Map<String, String>.from((_userAnswers[q.id] as Map?) ?? {});
          for (final item in items) {
            if (userMap[item.statement] == item.correctOptionKey) {
              points += 1;
            }
          }
          break;
      }
    }

    _examTimer?.cancel();
    _isTimerRunning = false;

    final ratio = total > 0 ? (points / total) : 0.0;
    double band;
    if (ratio >= 0.92) {
      band = 9.0;
    } else if (ratio >= 0.84) {
      band = 8.5;
    } else if (ratio >= 0.76) {
      band = 8.0;
    } else if (ratio >= 0.68) {
      band = 7.5;
    } else if (ratio >= 0.60) {
      band = 7.0;
    } else if (ratio >= 0.52) {
      band = 6.5;
    } else if (ratio >= 0.44) {
      band = 6.0;
    } else if (ratio >= 0.36) {
      band = 5.5;
    } else {
      band = 5.0;
    }

    setState(() {
      _isSubmitted = true;
      _score = points;
      _totalPossiblePoints = total;
      _estimatedBandScore = band;
    });

    _showResultSummaryModal();
  }

  void _showTimeUpDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.timer_off_rounded, color: AppColors.danger),
            SizedBox(width: 8),
            Text('Time Expired!'),
          ],
        ),
        content: const Text(
          'The recommended examination time has finished. Your answers are now submitted automatically for scoring.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _submitTest();
            },
            child: const Text('View Results'),
          ),
        ],
      ),
    );
  }

  void _showSubmitConfirmationDialog() {
    int answeredCount = 0;
    for (final q in _currentTest.questions) {
      if (q.type == IeltsQuestionType.matchingHeadings) {
        final map = (_userAnswers[q.id] as Map?) ?? {};
        if (map.isNotEmpty) answeredCount++;
      } else if (q.type == IeltsQuestionType.matchingFeatures) {
        final map = (_userAnswers[q.id] as Map?) ?? {};
        if (map.isNotEmpty) answeredCount++;
      } else if (q.type == IeltsQuestionType.multipleChoiceMulti) {
        final set = (_userAnswers[q.id] as Set?) ?? {};
        if (set.isNotEmpty) answeredCount++;
      } else if (q.type == IeltsQuestionType.fillInTheBlank ||
          q.type == IeltsQuestionType.shortAnswer) {
        final text = _textControllers[q.id]?.text.trim() ?? '';
        if (text.isNotEmpty) answeredCount++;
      } else {
        if (_userAnswers[q.id] != null) answeredCount++;
      }
    }

    final total = _currentTest.questions.length;
    final unanswered = total - answeredCount;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Submit IELTS Reading Test?'),
        content: Text(
          unanswered > 0
              ? 'You have answered $answeredCount out of $total questions ($unanswered remaining).\n\nDo you want to proceed and finalize your score?'
              : 'All question sections have been answered. Would you like to submit your test now?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Continue Test'),
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
            child: const Text('Submit & Score'),
          ),
        ],
      ),
    );
  }

  void _showResultSummaryModal() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.accentGreen.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.accentGreen.withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.stars_rounded, color: AppColors.accentGreen, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'IELTS BAND ESTIMATE: $_estimatedBandScore',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppColors.accentGreen,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              '$_score / $_totalPossiblePoints Points',
              style: AppTypography.h1.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 32,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${((_score / (_totalPossiblePoints > 0 ? _totalPossiblePoints : 1)) * 100).toInt()}% Total Accuracy across all tested question types',
              style: TextStyle(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: DSButton(
                    text: 'Review Answers',
                    variant: DSButtonVariant.primary,
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      _tabController.animateTo(1); // switch to questions tab to review
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DSButton(
                    text: 'Retake Test',
                    variant: DSButtonVariant.outline,
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      setState(() => _initTestState());
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  // Floating quick-peek sheet for reading passage while answering questions
  void _openPassageQuickPeek() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final markdownTheme = isDark
        ? DSRichMarkdownThemeData.dark(baseFontSize: _fontSize)
        : DSRichMarkdownThemeData.light(baseFontSize: _fontSize);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) => Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    const Icon(Icons.article_rounded, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Passage Quick-Peek',
                        style: AppTypography.h3.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  child: DSRichMarkdown(
                    _currentTest.markdownContent,
                    themeData: markdownTheme,
                    enableInteractiveWordLookup: _enableWordLookup,
                    onTapLink: (text, href, title) {},
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // BUILD METHOD & SCAFFOLD
  // ==========================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    final timerString =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor:
            isDark ? AppColors.darkSurface : AppColors.lightSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.assignment_turned_in_rounded,
                color: AppColors.primary,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'IELTS Reading Test Lab',
                    style: AppTypography.h3.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _currentTest.title,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        leading: widget.onBack != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: widget.onBack,
              )
            : IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
        actions: [
          // Select Test Dropdown
          PopupMenuButton<IeltsArticleTestData>(
            icon: const Icon(Icons.library_books_rounded),
            tooltip: 'Select IELTS Passage',
            onSelected: _switchTest,
            itemBuilder: (ctx) => IeltsArticleTestPresets.allTests
                .map(
                  (test) => PopupMenuItem(
                    value: test,
                    child: Text(
                      test.title,
                      style: TextStyle(
                        fontWeight: test.id == _currentTest.id
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),

          // Adjust Text Size
          PopupMenuButton<double>(
            icon: const Icon(Icons.format_size_rounded),
            tooltip: 'Passage font size',
            onSelected: (size) => setState(() => _fontSize = size),
            itemBuilder: (ctx) => [
              const PopupMenuItem(value: 13.5, child: Text('Small (13.5px)')),
              const PopupMenuItem(value: 15.0, child: Text('Standard (15px)')),
              const PopupMenuItem(value: 17.0, child: Text('Large (17px)')),
              const PopupMenuItem(value: 19.0, child: Text('Extra Large (19px)')),
            ],
          ),

          // Timer Widget
          GestureDetector(
            onTap: _isSubmitted ? null : _toggleTimer,
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _remainingSeconds < 180
                    ? AppColors.danger.withValues(alpha: 0.15)
                    : AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _remainingSeconds < 180
                      ? AppColors.danger.withValues(alpha: 0.4)
                      : AppColors.primary.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isTimerRunning
                        ? Icons.timer_rounded
                        : Icons.pause_circle_filled_rounded,
                    size: 14,
                    color: _remainingSeconds < 180
                        ? AppColors.danger
                        : AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    timerString,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _remainingSeconds < 180
                          ? AppColors.danger
                          : AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: isDark
              ? AppColors.darkTextSecondary
              : AppColors.lightTextSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          tabs: [
            const Tab(
              icon: Icon(Icons.menu_book_rounded, size: 18),
              text: 'Reading Passage',
            ),
            Tab(
              icon: const Icon(Icons.quiz_rounded, size: 18),
              text: 'Questions (${_currentTest.questions.length})',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: ARTICLE PASSAGE
          _buildArticlePassageTab(isDark),

          // TAB 2: QUESTIONS
          _buildQuestionsTab(isDark),
        ],
      ),
      bottomNavigationBar: _buildBottomActionBar(isDark),
      floatingActionButton: _tabController.index == 1
          ? FloatingActionButton.extended(
              onPressed: _openPassageQuickPeek,
              backgroundColor: isDark ? AppColors.darkSurfaceVariant : Colors.white,
              foregroundColor: AppColors.primary,
              elevation: 4,
              icon: const Icon(Icons.remove_red_eye_rounded, size: 18),
              label: const Text(
                'Quick-Peek Passage',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            )
          : null,
    );
  }

  // ==========================================
  // TAB 1: ARTICLE PASSAGE VIEW
  // ==========================================

  Widget _buildArticlePassageTab(bool isDark) {
    final markdownTheme = isDark
        ? DSRichMarkdownThemeData.dark(baseFontSize: _fontSize)
        : DSRichMarkdownThemeData.light(baseFontSize: _fontSize);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Article Header Card (similar to GrammarArticleScreen)
          _buildArticleHeaderCard(isDark),
          const SizedBox(height: 16),

          // Quick Action Pill to jump to questions
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1B202D) : const Color(0xFFF0F5FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.touch_app_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tap any word in the passage to inspect dictionary definitions and phonetic audio.',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => _tabController.animateTo(1),
                  child: const Text('Go to Questions →', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Render Rich Markdown Passage
          DSRichMarkdown(
            _currentTest.markdownContent,
            themeData: markdownTheme,
            enableInteractiveWordLookup: _enableWordLookup,
            showLineNumbers: false,
            onWordTap: (word) {
              // Handled by DSRichMarkdown internal interactive popover
            },
            onWordSaved: (info, isSaved) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isSaved
                        ? 'Saved "${info.word}" to your Word Bank!'
                        : 'Removed "${info.word}" from Word Bank.',
                  ),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // Switch to Questions Button
          DSButton(
            text: 'Proceed to IELTS Questions (${_currentTest.questions.length}) →',
            fullWidth: true,
            size: DSButtonSize.lg,
            onPressed: () => _tabController.animateTo(1),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleHeaderCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1B2234), const Color(0xFF131722)]
              : [const Color(0xFFEBF3FF), const Color(0xFFF3F7FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              DSBadge(
                label: _currentTest.cefrLevel,
                variant: DSBadgeVariant.primary,
              ),
              const SizedBox(width: 8),
              DSBadge(
                label: _currentTest.category,
                variant: DSBadgeVariant.neutral,
              ),
              const Spacer(),
              Icon(
                Icons.schedule_rounded,
                size: 15,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                '${_currentTest.recommendedMinutes} min test',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _currentTest.title,
            style: AppTypography.h2.copyWith(
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 19,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _currentTest.subtitle,
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 2: QUESTIONS VIEW
  // ==========================================

  Widget _buildQuestionsTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question summary banner
          _buildQuestionsHeaderSummary(isDark),
          const SizedBox(height: 16),

          // Render each question by its specific IELTS format
          ...List.generate(_currentTest.questions.length, (index) {
            final q = _currentTest.questions[index];
            return _buildQuestionCard(q, index + 1, isDark);
          }),
        ],
      ),
    );
  }

  Widget _buildQuestionsHeaderSummary(bool isDark) {
    int answeredCount = 0;
    for (final q in _currentTest.questions) {
      if (q.type == IeltsQuestionType.matchingHeadings) {
        final map = (_userAnswers[q.id] as Map?) ?? {};
        if (map.isNotEmpty) answeredCount++;
      } else if (q.type == IeltsQuestionType.matchingFeatures) {
        final map = (_userAnswers[q.id] as Map?) ?? {};
        if (map.isNotEmpty) answeredCount++;
      } else if (q.type == IeltsQuestionType.multipleChoiceMulti) {
        final set = (_userAnswers[q.id] as Set?) ?? {};
        if (set.isNotEmpty) answeredCount++;
      } else if (q.type == IeltsQuestionType.fillInTheBlank ||
          q.type == IeltsQuestionType.shortAnswer) {
        final text = _textControllers[q.id]?.text.trim() ?? '';
        if (text.isNotEmpty) answeredCount++;
      } else {
        if (_userAnswers[q.id] != null) answeredCount++;
      }
    }

    final total = _currentTest.questions.length;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Questions Overview',
                  style: AppTypography.label.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$answeredCount of $total question sections completed',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          DSBadge(
            label: _isSubmitted
                ? 'BAND $_estimatedBandScore'
                : '$answeredCount / $total',
            variant: _isSubmitted
                ? DSBadgeVariant.success
                : (answeredCount == total
                    ? DSBadgeVariant.success
                    : DSBadgeVariant.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(IeltsTestQuestion q, int orderIndex, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141720) : const Color(0xFFF9FAFD),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: isDark
              ? AppColors.darkBorder.withValues(alpha: 0.8)
              : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question Header: Question Type Badge & Number
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Question ${q.questionNumber}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              DSBadge(
                label: q.type.displayName,
                variant: DSBadgeVariant.neutral,
              ),
              if (q.paragraphReference != null) ...[
                const Spacer(),
                Text(
                  q.paragraphReference!,
                  style: TextStyle(
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    color: isDark
                        ? AppColors.darkTextMuted
                        : AppColors.lightTextMuted,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),

          // Prompt Instruction
          Text(
            q.prompt,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.italic,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 10),

          // Question Prompt Text
          Text(
            q.questionText,
            style: AppTypography.bodyMd.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 14),

          // Question-Specific Interactive Formats
          if (q.type == IeltsQuestionType.multipleChoiceSingle)
            _buildMcqSingleWidget(q, isDark),
          if (q.type == IeltsQuestionType.multipleChoiceMulti)
            _buildMcqMultiWidget(q, isDark),
          if (q.type == IeltsQuestionType.trueFalseNotGiven ||
              q.type == IeltsQuestionType.yesNoNotGiven)
            _buildTfngWidget(q, isDark),
          if (q.type == IeltsQuestionType.fillInTheBlank ||
              q.type == IeltsQuestionType.shortAnswer)
            _buildFillBlankWidget(q, isDark),
          if (q.type == IeltsQuestionType.matchingHeadings)
            _buildMatchingHeadingsWidget(q, isDark),
          if (q.type == IeltsQuestionType.matchingFeatures)
            _buildMatchingFeaturesWidget(q, isDark),

          // Post-Submission Explanation Box
          if (_isSubmitted) ...[
            const SizedBox(height: 14),
            _buildExplanationBox(q, isDark),
          ],
        ],
      ),
    );
  }

  // ==========================================
  // QUESTION TYPE 1: MULTIPLE CHOICE SINGLE
  // ==========================================

  Widget _buildMcqSingleWidget(IeltsTestQuestion q, bool isDark) {
    final selectedOptionLetter = _userAnswers[q.id] as String?;

    return Column(
      children: q.options.map((optionString) {
        final optionLetter = optionString.split(':').first.trim();
        final isSelected = selectedOptionLetter == optionLetter;
        final isCorrect = q.correctAnswer == optionLetter;

        Color borderCol = isDark ? AppColors.darkBorder : AppColors.lightBorder;
        Color bgCol = isDark ? const Color(0xFF1B1E28) : Colors.white;

        if (_isSubmitted) {
          if (isCorrect) {
            borderCol = AppColors.success;
            bgCol = AppColors.success.withValues(alpha: 0.12);
          } else if (isSelected && !isCorrect) {
            borderCol = AppColors.danger;
            bgCol = AppColors.danger.withValues(alpha: 0.12);
          }
        } else if (isSelected) {
          borderCol = AppColors.primary;
          bgCol = AppColors.primary.withValues(alpha: 0.08);
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: _isSubmitted ? null : () => _recordSingleAnswer(q.id, optionLetter),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: bgCol,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: borderCol, width: isSelected ? 1.5 : 1),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? AppColors.primary
                          : (isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.05)),
                    ),
                    child: Text(
                      optionLetter,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Colors.white
                            : (isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      optionString,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.35,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                  ),
                  if (_isSubmitted) ...[
                    if (isCorrect)
                      const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20)
                    else if (isSelected)
                      const Icon(Icons.cancel_rounded, color: AppColors.danger, size: 20),
                  ],
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ==========================================
  // QUESTION TYPE 2: MULTIPLE CHOICE MULTI
  // ==========================================

  Widget _buildMcqMultiWidget(IeltsTestQuestion q, bool isDark) {
    final selectedSet = (_userAnswers[q.id] as Set<String>?) ?? {};
    final expectedSet = Set<String>.from(q.correctAnswer as List);
    final maxPicks = expectedSet.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            'Chosen ${selectedSet.length} of $maxPicks required options',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: selectedSet.length == maxPicks
                  ? AppColors.success
                  : AppColors.primary,
            ),
          ),
        ),
        ...q.options.map((optionString) {
          final optionLetter = optionString.split(':').first.trim();
          final isSelected = selectedSet.contains(optionLetter);
          final isCorrect = expectedSet.contains(optionLetter);

          Color borderCol = isDark ? AppColors.darkBorder : AppColors.lightBorder;
          Color bgCol = isDark ? const Color(0xFF1B1E28) : Colors.white;

          if (_isSubmitted) {
            if (isCorrect && isSelected) {
              borderCol = AppColors.success;
              bgCol = AppColors.success.withValues(alpha: 0.12);
            } else if (isCorrect && !isSelected) {
              borderCol = AppColors.warning;
              bgCol = AppColors.warning.withValues(alpha: 0.08);
            } else if (isSelected && !isCorrect) {
              borderCol = AppColors.danger;
              bgCol = AppColors.danger.withValues(alpha: 0.12);
            }
          } else if (isSelected) {
            borderCol = AppColors.primary;
            bgCol = AppColors.primary.withValues(alpha: 0.08);
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: _isSubmitted
                  ? null
                  : () => _toggleMultiAnswer(q.id, optionLetter, maxPicks),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: bgCol,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: borderCol, width: isSelected ? 1.5 : 1),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      isSelected
                          ? Icons.check_box_rounded
                          : Icons.check_box_outline_blank_rounded,
                      color: isSelected ? AppColors.primary : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        optionString,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.35,
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
      ],
    );
  }

  // ==========================================
  // QUESTION TYPE 3: TRUE / FALSE / NOT GIVEN
  // ==========================================

  Widget _buildTfngWidget(IeltsTestQuestion q, bool isDark) {
    final selectedOption = _userAnswers[q.id] as String?;
    final isYesNo = q.type == IeltsQuestionType.yesNoNotGiven;
    final options = isYesNo
        ? ['YES', 'NO', 'NOT GIVEN']
        : ['TRUE', 'FALSE', 'NOT GIVEN'];

    return Row(
      children: options.map((opt) {
        final isSelected = selectedOption == opt;
        final isCorrect = q.correctAnswer == opt;

        Color borderCol = isDark ? AppColors.darkBorder : AppColors.lightBorder;
        Color bgCol = isDark ? const Color(0xFF1A1D27) : Colors.white;
        Color textCol = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

        if (_isSubmitted) {
          if (isCorrect) {
            borderCol = AppColors.success;
            bgCol = AppColors.success.withValues(alpha: 0.15);
            textCol = AppColors.success;
          } else if (isSelected && !isCorrect) {
            borderCol = AppColors.danger;
            bgCol = AppColors.danger.withValues(alpha: 0.15);
            textCol = AppColors.danger;
          }
        } else if (isSelected) {
          borderCol = AppColors.primary;
          bgCol = AppColors.primary.withValues(alpha: 0.12);
          textCol = AppColors.primary;
        }

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: InkWell(
              onTap: _isSubmitted ? null : () => _recordSingleAnswer(q.id, opt),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: bgCol,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: borderCol, width: isSelected ? 1.5 : 1),
                ),
                child: Text(
                  opt,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: textCol,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ==========================================
  // QUESTION TYPE 4: FILL IN BLANK / SHORT ANSWER
  // ==========================================

  Widget _buildFillBlankWidget(IeltsTestQuestion q, bool isDark) {
    final controller = _textControllers[q.id];
    final userVal = (controller?.text ?? '').trim().toLowerCase();
    final acceptable = [
      (q.correctAnswer as String).trim().toLowerCase(),
      ...q.acceptableAnswers.map((a) => a.trim().toLowerCase()),
    ];
    final isCorrect = acceptable.contains(userVal);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (q.maxWords != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 6.0),
            child: Text(
              'Constraint: NO MORE THAN ${q.maxWords} WORDS',
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: AppColors.warning,
              ),
            ),
          ),
        TextField(
          controller: controller,
          enabled: !_isSubmitted,
          onChanged: (text) => _recordTextAnswer(q.id, text),
          decoration: InputDecoration(
            hintText: 'Type your answer here...',
            hintStyle: TextStyle(
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            ),
            filled: true,
            fillColor: isDark ? const Color(0xFF1B1E28) : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            suffixIcon: _isSubmitted
                ? Icon(
                    isCorrect
                        ? Icons.check_circle_rounded
                        : Icons.cancel_rounded,
                    color: isCorrect ? AppColors.success : AppColors.danger,
                  )
                : null,
          ),
        ),
        if (_isSubmitted && !isCorrect)
          Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: Text(
              'Accepted answers: ${acceptable.join(" / ")}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.success,
              ),
            ),
          ),
      ],
    );
  }

  // ==========================================
  // QUESTION TYPE 5: MATCHING HEADINGS
  // ==========================================

  Widget _buildMatchingHeadingsWidget(IeltsTestQuestion q, bool isDark) {
    final catalog = q.headingsCatalog ?? {};
    final items = q.headingMatchItems ?? [];
    final userMap = (_userAnswers[q.id] as Map<String, String>?) ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Catalog box
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1D27) : const Color(0xFFEEF2F6),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'List of Available Headings:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 8),
              ...catalog.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${entry.key}. ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Expanded(
                        child: Text(
                          entry.value,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Section by section heading picker
        ...items.map((item) {
          final selectedHeading = userMap[item.paragraphId];
          final isCorrect = selectedHeading == item.correctHeadingId;

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1D28) : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _isSubmitted
                    ? (isCorrect ? AppColors.success : AppColors.danger)
                    : (selectedHeading != null
                        ? AppColors.primary
                        : (isDark ? AppColors.darkBorder : AppColors.lightBorder)),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.paragraphLabel,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 6),
                DropdownButton<String>(
                  value: selectedHeading,
                  isExpanded: true,
                  hint: const Text('Select Heading', style: TextStyle(fontSize: 13)),
                  underline: const SizedBox(),
                  disabledHint: Text(
                    selectedHeading != null
                        ? 'Heading $selectedHeading: ${catalog[selectedHeading]}'
                        : 'None',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12.5,
                      color: isCorrect ? AppColors.success : AppColors.danger,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  onChanged: _isSubmitted
                      ? null
                      : (val) {
                          if (val != null) {
                            _recordHeadingMatch(q.id, item.paragraphId, val);
                          }
                        },
                  items: catalog.keys.map((k) {
                    return DropdownMenuItem<String>(
                      value: k,
                      child: Text(
                        '$k. ${catalog[k]}',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12.5),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ==========================================
  // QUESTION TYPE 6: MATCHING FEATURES
  // ==========================================

  Widget _buildMatchingFeaturesWidget(IeltsTestQuestion q, bool isDark) {
    final catalog = q.featuresCatalog ?? {};
    final items = q.featureMatchItems ?? [];
    final userMap = (_userAnswers[q.id] as Map<String, String>?) ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Features legend box
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1D27) : const Color(0xFFEEF2F6),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Researchers / Category Options:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 6),
              ...catalog.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 2.0),
                  child: Text(
                    '${entry.key}: ${entry.value}',
                    style: const TextStyle(fontSize: 12.5),
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 12),

        ...items.map((item) {
          final selectedOption = userMap[item.statement];
          final isCorrect = selectedOption == item.correctOptionKey;

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1D28) : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _isSubmitted
                    ? (isCorrect ? AppColors.success : AppColors.danger)
                    : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.statement,
                  style: const TextStyle(fontSize: 13.5, height: 1.3),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: catalog.keys.map((key) {
                    final isChoiceSelected = selectedOption == key;

                    return ChoiceChip(
                      label: Text('$key: ${catalog[key]}'),
                      selected: isChoiceSelected,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isChoiceSelected
                            ? Colors.white
                            : (isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary),
                        fontWeight: isChoiceSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                      onSelected: _isSubmitted
                          ? null
                          : (val) {
                              if (val) {
                                _recordFeatureMatch(q.id, item.statement, key);
                              }
                            },
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ==========================================
  // EXPLANATION / REVIEW BOX
  // ==========================================

  Widget _buildExplanationBox(IeltsTestQuestion q, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb_outline_rounded, color: AppColors.primary, size: 16),
              SizedBox(width: 6),
              Text(
                'Official Examiner Explanation & Citation',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            q.explanation,
            style: TextStyle(
              fontSize: 12.5,
              height: 1.4,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // BOTTOM ACTION BAR
  // ==========================================

  Widget _buildBottomActionBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
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
          // Switch between Passage and Questions
          Expanded(
            child: DSButton(
              text: _tabController.index == 0
                  ? 'Open Questions (${_currentTest.questions.length})'
                  : 'View Article Passage',
              variant: DSButtonVariant.outline,
              leftIcon: Icon(
                _tabController.index == 0
                    ? Icons.quiz_rounded
                    : Icons.menu_book_rounded,
                size: 16,
              ),
              onPressed: () {
                _tabController.animateTo(_tabController.index == 0 ? 1 : 0);
              },
            ),
          ),
          const SizedBox(width: 12),

          // Submit or Review Button
          Expanded(
            child: DSButton(
              text: _isSubmitted ? 'View Band Results' : 'Submit IELTS Test',
              variant: DSButtonVariant.primary,
              leftIcon: Icon(
                _isSubmitted ? Icons.stars_rounded : Icons.check_circle_outline_rounded,
                size: 16,
              ),
              onPressed: _isSubmitted
                  ? _showResultSummaryModal
                  : _showSubmitConfirmationDialog,
            ),
          ),
        ],
      ),
    );
  }
}
