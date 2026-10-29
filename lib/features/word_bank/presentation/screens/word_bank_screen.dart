import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/repositories/word_bank_repository.dart';
import '../providers/word_bank_provider.dart';
import '../widgets/add_word_bottom_sheet.dart';
import '../widgets/word_bank_error_widget.dart';
import '../widgets/word_bank_filter_bar.dart';
import '../widgets/word_bank_header_stats.dart';
import '../widgets/word_bank_item_card.dart';
import 'flashcard_review_screen.dart';

class WordBankScreen extends StatefulWidget {
  final WordBankRepository? repository;

  const WordBankScreen({super.key, this.repository});

  @override
  State<WordBankScreen> createState() => _WordBankScreenState();
}

class _WordBankScreenState extends State<WordBankScreen> {
  late final WordBankProvider _provider;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _provider = WordBankProvider(repository: widget.repository);
    _provider.addListener(_onStateChange);
    _provider.loadWordBank();
  }

  @override
  void dispose() {
    _provider.removeListener(_onStateChange);
    _provider.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _onStateChange() {
    if (mounted) setState(() {});
  }

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

  void _openAddWordSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AddWordBottomSheet(onAddWord: _provider.addWord),
    );
  }

  void _startFlashcardReview() {
    final state = _provider.state;
    final reviewItems =
        state.dueFlashcards.isNotEmpty ? state.dueFlashcards : state.wordItems;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FlashcardReviewScreen(initialItems: reviewItems),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final palette = ThemeScope.maybeOf(context)?.palette ?? AppColors.currentPalette;
    final state = _provider.state;
    final hasItems = state.wordItems.isNotEmpty;

    final fabBgColor = hasItems
        ? (isDark ? palette.darkSurfaceVariant : palette.primary)
        : (isDark ? palette.darkSurface : palette.lightSurfaceVariant);
    final fabFgColor = hasItems
        ? (isDark ? palette.darkTextPrimary : Colors.white)
        : (isDark ? palette.darkTextMuted : palette.lightTextMuted);
    final fabBorderColor = hasItems
        ? (isDark ? palette.darkBorder : palette.lightBorder)
        : (isDark
            ? palette.darkBorder.withValues(alpha: 0.3)
            : palette.lightBorder.withValues(alpha: 0.5));

    return Scaffold(
      appBar: AppBar(
        title: const Text('IELTS Word Bank'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Add Vocabulary',
            onPressed: _openAddWordSheet,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _provider.loadWordBank,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'word_bank_review_flashcards_fab',
        onPressed: hasItems ? _startFlashcardReview : null,
        icon: Icon(
          Icons.style_outlined,
          color: fabFgColor,
          size: 20,
        ),
        label: Text(
          'Review Flashcards (${state.dueTodayCount} Due)',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            letterSpacing: -0.2,
            color: fabFgColor,
          ),
        ),
        backgroundColor: fabBgColor,
        foregroundColor: fabFgColor,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          side: BorderSide(
            color: fabBorderColor,
            width: 1.2,
          ),
        ),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.errorMessage != null && state.wordItems.isEmpty
              ? WordBankErrorWidget(
                  errorMessage: state.errorMessage!,
                  onRetry: _provider.loadWordBank,
                )
              : RefreshIndicator(
                  onRefresh: _provider.loadWordBank,
                  child: ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      WordBankHeaderStats(
                        totalWords: state.totalWordsCount,
                        dueToday: state.dueTodayCount,
                        mastered: state.masteredCount,
                      ),
                      const SizedBox(height: 16),
                      WordBankFilterBar(
                        searchQuery: state.searchQuery,
                        selectedCefr: state.selectedCefrFilter,
                        onSearchChanged: _provider.setSearchQuery,
                        onCefrChanged: _provider.setCefrFilter,
                      ),
                      const SizedBox(height: 16),
                      if (state.filteredWordItems.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: Text(
                              'No vocabulary items found.',
                              style: TextStyle(
                                color: isDark
                                    ? palette.darkTextMuted
                                    : palette.lightTextMuted,
                              ),
                            ),
                          ),
                        )
                      else
                        ...state.filteredWordItems.map(
                          (item) => WordBankItemCard(
                            item: item,
                            onPlayAudio: () => _playTts(item.word),
                            onDelete: () => _provider.deleteWord(item.id),
                          ),
                        ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
    );
  }
}
