import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../design_system/components/badge/ds_badge.dart';
import '../../../../design_system/components/button/ds_button.dart';
import '../../../word_bank/data/repositories/word_bank_repository_impl.dart';
import '../../../word_bank/domain/entities/flashcard_item.dart';
import '../../domain/entities/polysemy_vocab_item.dart';
import '../widgets/vocab_option_tile.dart';
import '../widgets/vocab_quiz_summary_view.dart';
import '../widgets/vocab_sense_explanation_sheet.dart';

/// Interactive Multiple-Choice Vocabulary Practice Screen.
/// Tests the student's ability to identify the correct meaning of a word in 1–2 sentence IELTS contexts.
class VocabContextQuizScreen extends StatefulWidget {
  final String title;
  final List<PolysemyVocabItem> items;

  const VocabContextQuizScreen({
    super.key,
    required this.title,
    required this.items,
  });

  @override
  State<VocabContextQuizScreen> createState() => _VocabContextQuizScreenState();
}

class _VocabContextQuizScreenState extends State<VocabContextQuizScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final WordBankRepositoryImpl _wordBankRepo = WordBankRepositoryImpl();

  int _currentIndex = 0;
  final Map<String, int> _userAnswers = {};
  final Set<String> _savedWordIds = {};

  bool _isSubmitted = false;
  bool _isFinished = false;
  int _score = 0;

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  PolysemyVocabItem get currentItem => widget.items[_currentIndex];
  VocabContextQuestion get currentQuestion => currentItem.questions.first;

  Future<void> _playTts(String word) async {
    try {
      final cleanText = word.replaceAll(RegExp(r'[^\w\s\-]'), '');
      final url =
          'https://dict.youdao.com/dictvoice?audio=${Uri.encodeComponent(cleanText)}&type=1';
      await _audioPlayer.stop();
      await _audioPlayer.play(UrlSource(url));
    } catch (e) {
      debugPrint('TTS Error: $e');
    }
  }

  void _selectOption(int optionIndex) {
    if (_isSubmitted) return;

    setState(() {
      _userAnswers[currentQuestion.id] = optionIndex;
      _isSubmitted = true;
      if (optionIndex == currentQuestion.correctOptionIndex) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentIndex < widget.items.length - 1) {
      setState(() {
        _currentIndex++;
        _isSubmitted = false;
      });
    } else {
      setState(() {
        _isFinished = true;
      });
    }
  }

  void _restartQuiz() {
    setState(() {
      _currentIndex = 0;
      _userAnswers.clear();
      _isSubmitted = false;
      _isFinished = false;
      _score = 0;
    });
  }

  Future<void> _addWordToBank(PolysemyVocabItem item) async {
    if (_savedWordIds.contains(item.id)) return;

    final targetSense = item.senses[currentQuestion.targetSenseIndex];
    final flashcard = FlashcardItem(
      id: 'poly_${item.id}_${DateTime.now().millisecondsSinceEpoch}',
      word: item.word,
      phonetic: item.phonetic,
      cefrLevel: item.cefrLevel,
      definition: targetSense.definition,
      example: targetSense.exampleSentence,
      synonyms: item.senses.map((s) => s.definition).take(2).toList(),
      masteryLevel: 1,
    );

    try {
      await _wordBankRepo.addWord(flashcard);
      if (mounted) {
        setState(() {
          _savedWordIds.add(item.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added "${item.word}" to Word Bank flashcards!'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save "${item.word}": $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// Builds the context sentence with the target word highlighted
  Widget _buildContextSentence(
      String fullSentence, String highlightedSubstring, bool isDark) {
    final lowerSentence = fullSentence.toLowerCase();
    final lowerTarget = highlightedSubstring.toLowerCase();
    final matchIndex = lowerSentence.indexOf(lowerTarget);

    if (matchIndex == -1) {
      return Text(
        fullSentence,
        style: TextStyle(
          fontSize: 15.5,
          height: 1.5,
          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
        ),
      );
    }

    final before = fullSentence.substring(0, matchIndex);
    final matchedText =
        fullSentence.substring(matchIndex, matchIndex + highlightedSubstring.length);
    final after = fullSentence.substring(matchIndex + highlightedSubstring.length);

    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: 15.5,
          height: 1.55,
          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
        ),
        children: [
          TextSpan(text: before),
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.primary.withValues(alpha: 0.3)
                    : const Color(0xFFE0E7FF),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isDark ? AppColors.primary : const Color(0xFF818CF8),
                  width: 1,
                ),
              ),
              child: Text(
                matchedText,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15.5,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          TextSpan(text: after),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final progress = widget.items.isNotEmpty
        ? (_currentIndex + 1) / widget.items.length
        : 0.0;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          widget.title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor:
                isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 3,
          ),
        ),
      ),
      body: SafeArea(
        child: _isFinished
            ? VocabQuizSummaryView(
                score: _score,
                totalQuestions: widget.items.length,
                items: widget.items,
                userAnswers: _userAnswers,
                onRetry: _restartQuiz,
                onExit: () => Navigator.of(context).pop(),
                onPlayAudio: _playTts,
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question Counter & Badge Row
                    Row(
                      children: [
                        DSBadge(
                          label:
                              'Question ${_currentIndex + 1} of ${widget.items.length}',
                          variant: DSBadgeVariant.neutral,
                        ),
                        const SizedBox(width: 8),
                        DSBadge(
                          label: currentQuestion.sourceContextType ??
                              'IELTS Academic',
                          variant: DSBadgeVariant.neutral,
                          isOutlined: true,
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.volume_up_rounded, size: 22),
                          tooltip: 'Listen word pronunciation',
                          onPressed: () => _playTts(currentItem.word),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Academic Context Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF141720)
                            : const Color(0xFFF8F9FC),
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
                          Row(
                            children: [
                              Text(
                                currentItem.word,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                currentItem.phonetic,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark
                                      ? AppColors.darkTextMuted
                                      : AppColors.lightTextMuted,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.white12 : Colors.black12,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  currentItem.generalPartOfSpeech,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Divider(height: 1),
                          const SizedBox(height: 12),
                          // 1 or 2 Context Sentences with highlighted word
                          _buildContextSentence(
                            currentQuestion.contextSentence,
                            currentQuestion.highlightedWord,
                            isDark,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Question Instruction Prompt
                    Text(
                      'What is the meaning of "${currentItem.word}" in this sentence?',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 15.5,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 4 Multiple Choice Option Tiles
                    ...List.generate(currentQuestion.options.length, (index) {
                      final option = currentQuestion.options[index];
                      final selectedIndex = _userAnswers[currentQuestion.id];
                      final isSelected = selectedIndex == index;
                      final isCorrect =
                          index == currentQuestion.correctOptionIndex;

                      return VocabOptionTile(
                        optionText: option,
                        index: index,
                        isSelected: isSelected,
                        isSubmitted: _isSubmitted,
                        isCorrect: isCorrect,
                        onTap: () => _selectOption(index),
                      );
                    }),

                    // Post-submission Explanation & All Senses Breakdown
                    if (_isSubmitted) ...[
                      VocabSenseExplanationCard(
                        item: currentItem,
                        question: currentQuestion,
                        isCorrect: _userAnswers[currentQuestion.id] ==
                            currentQuestion.correctOptionIndex,
                        onPlayAudio: () => _playTts(currentItem.word),
                        onAddToWordBank: () => _addWordToBank(currentItem),
                        isAddedToWordBank:
                            _savedWordIds.contains(currentItem.id),
                      ),
                      const SizedBox(height: 24),

                      // Next Question / Complete Button
                      SizedBox(
                        width: double.infinity,
                        child: DSButton(
                          text: _currentIndex < widget.items.length - 1
                              ? 'Next Word →'
                              : 'See Results',
                          variant: DSButtonVariant.primary,
                          onPressed: _nextQuestion,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
      ),
    );
  }
}
