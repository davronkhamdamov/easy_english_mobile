import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../data/repositories/word_bank_repository_impl.dart';
import '../../domain/entities/flashcard_item.dart';
import '../../domain/repositories/word_bank_repository.dart';
import '../../domain/services/spaced_repetition.dart';
import '../widgets/flashcard_3d_card.dart';
import '../widgets/flashcard_completion_summary.dart';
import '../widgets/flashcard_progress_bar.dart';
import '../widgets/flashcard_rating_buttons.dart';

class FlashcardReviewScreen extends StatefulWidget {
  final List<FlashcardItem>? initialItems;
  final WordBankRepository? repository;
  final String? sessionTitle;

  const FlashcardReviewScreen({
    super.key,
    this.initialItems,
    this.repository,
    this.sessionTitle,
  });

  @override
  State<FlashcardReviewScreen> createState() => _FlashcardReviewScreenState();
}

class _FlashcardReviewScreenState extends State<FlashcardReviewScreen>
    with SingleTickerProviderStateMixin {
  late final WordBankRepository _repository;
  late SpacedRepetitionSession _session;
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isFlipped = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? WordBankRepositoryImpl();
    _initSession();

    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _flipAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOutBack),
    )..addListener(() => setState(() {}));
  }

  Future<void> _initSession() async {
    if (widget.initialItems != null && widget.initialItems!.isNotEmpty) {
      _session = SpacedRepetitionSession(
        id: 'session_${DateTime.now().millisecondsSinceEpoch}',
        items: widget.initialItems!,
      );
    } else {
      setState(() => _isLoading = true);
      try {
        final due = await _repository.getDueFlashcards();
        final items = due.isNotEmpty ? due : await _repository.getWordBankItems();
        _session = SpacedRepetitionSession(
          id: 'session_${DateTime.now().millisecondsSinceEpoch}',
          items: items,
        );
      } catch (e) {
        _session = SpacedRepetitionSession(id: 'empty', items: []);
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _flipController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _toggleFlip() {
    if (_session.isCompleted) return;
    if (_isFlipped) {
      _flipController.reverse().then((_) => setState(() => _isFlipped = false));
    } else {
      _flipController.forward().then((_) => setState(() => _isFlipped = true));
    }
  }

  Future<void> _handleRating(ReviewRating rating) async {
    final currentCard = _session.currentCard;
    if (currentCard == null) return;

    _session.submitRating(rating);
    _repository.submitReview(id: currentCard.id, rating: rating).catchError((e) {
      debugPrint('Failed to sync SRS rating to backend: $e');
      return currentCard;
    });

    if (_isFlipped) {
      _flipController.reverse().then((_) => setState(() => _isFlipped = false));
    } else {
      setState(() {});
    }
  }

  Future<void> _playTts(String text) async {
    try {
      final cleanText = text.trim().replaceAll(RegExp(r'[^\w\s\-]'), '');
      final url =
          'https://dict.youdao.com/dictvoice?audio=${Uri.encodeComponent(cleanText)}&type=1';
      await _audioPlayer.stop();
      await _audioPlayer.play(UrlSource(url));
    } catch (e) {
      debugPrint('TTS Error: $e');
    }
  }

  void _restart() {
    _flipController.reset();
    setState(() {
      _isFlipped = false;
      _session.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(widget.sessionTitle ?? 'Flashcard Review'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _restart,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _session.isCompleted
                  ? FlashcardCompletionSummary(
                      totalCards: _session.totalCards,
                      againCount: _session.againCount,
                      hardCount: _session.hardCount,
                      goodCount: _session.goodCount,
                      easyCount: _session.easyCount,
                      onRestart: _restart,
                      onDone: () => Navigator.of(context).pop(),
                    )
                  : Column(
                      children: [
                        FlashcardProgressBar(
                          current: _session.cardsReviewed + 1,
                          total: _session.totalCards,
                          progress: _session.progressRatio,
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: GestureDetector(
                            onTap: _toggleFlip,
                            child: Flashcard3DCard(
                              card: _session.currentCard!,
                              isFlipped: _isFlipped,
                              flipAnimation: _flipAnimation,
                              onPlayWordAudio: () =>
                                  _playTts(_session.currentCard!.word),
                              onPlaySentenceAudio: () =>
                                  _playTts(_session.currentCard!.example),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        FlashcardRatingButtons(onRatingSelected: _handleRating),
                      ],
                    ),
        ),
      ),
    );
  }
}
