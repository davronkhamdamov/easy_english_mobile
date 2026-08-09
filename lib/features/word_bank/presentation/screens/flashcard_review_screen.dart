import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../domain/entities/flashcard_item.dart';
import '../../domain/services/spaced_repetition.dart';

/// Interactive Spaced Repetition Flashcard Review Screen for Easy IELTS.
/// Features 3D card flip animation, SM-2 rating controls, live progress tracking,
/// and a comprehensive completion summary card.
class FlashcardReviewScreen extends StatefulWidget {
  final List<FlashcardItem>? initialItems;
  final String? sessionTitle;

  const FlashcardReviewScreen({
    super.key,
    this.initialItems,
    this.sessionTitle,
  });

  @override
  State<FlashcardReviewScreen> createState() => _FlashcardReviewScreenState();
}

class _FlashcardReviewScreenState extends State<FlashcardReviewScreen>
    with SingleTickerProviderStateMixin {
  late SpacedRepetitionSession _session;
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  bool _isFlipped = false;
  bool _isPlayingAudio = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Default fallback IELTS C1/C2 & B2 flashcards if none passed
  static const List<FlashcardItem> _defaultFlashcards = [
    FlashcardItem(
      id: 'wb_1',
      word: 'Foster',
      phonetic: '/ˈfɒstər/',
      cefrLevel: 'C1',
      definition:
          'To encourage the development or growth of ideas, relationships, or skills.',
      example:
          'The government policies aim to foster economic growth and innovative start-ups.',
      collocations: [
        'foster growth',
        'foster creativity',
        'foster cooperation',
        'foster innovation',
      ],
      idioms: ['nurture nature'],
      phrasalVerbs: ['foster in', 'foster out'],
      repetitionCount: 1,
      easinessFactor: 2.5,
      intervalDays: 3,
      masteryLevel: 3,
    ),
    FlashcardItem(
      id: 'wb_2',
      word: 'Paramount',
      phonetic: '/ˈpærəmaʊnt/',
      cefrLevel: 'C1',
      definition:
          'More important than anything else; supreme in power, rank, or importance.',
      example:
          'Maintaining strict data security is of paramount importance in modern cloud architectures.',
      collocations: [
        'paramount importance',
        'paramount duty',
        'paramount concern',
      ],
      idioms: ['of the essence'],
      phrasalVerbs: [],
      repetitionCount: 2,
      easinessFactor: 2.6,
      intervalDays: 6,
      masteryLevel: 4,
    ),
    FlashcardItem(
      id: 'wb_3',
      word: 'Mitigate',
      phonetic: '/ˈmɪtɪɡeɪt/',
      cefrLevel: 'B2',
      definition:
          'Make something bad less severe, serious, painful, or damaging.',
      example:
          'Proactive disaster response protocols help mitigate the financial impact of severe weather.',
      collocations: [
        'mitigate risk',
        'mitigate climate change',
        'mitigate damage',
        'mitigate factors',
      ],
      idioms: ['cushion the blow'],
      phrasalVerbs: ['soften up'],
      repetitionCount: 0,
      easinessFactor: 2.36,
      intervalDays: 1,
      masteryLevel: 2,
    ),
    FlashcardItem(
      id: 'wb_4',
      word: 'Ubiquitous',
      phonetic: '/juːˈbɪkwɪtəs/',
      cefrLevel: 'C2',
      definition: 'Present, appearing, or found everywhere at the same time.',
      example:
          'Smartphones have become ubiquitous across all demographics in modern urban centers.',
      collocations: [
        'ubiquitous presence',
        'ubiquitous technology',
        'become ubiquitous',
      ],
      idioms: ['every nook and cranny'],
      phrasalVerbs: ['crop up'],
      repetitionCount: 3,
      easinessFactor: 2.7,
      intervalDays: 12,
      masteryLevel: 5,
    ),
    FlashcardItem(
      id: 'wb_5',
      word: 'Exacerbate',
      phonetic: '/ɪɡˈzæsəbeɪt/',
      cefrLevel: 'C1',
      definition:
          'Make a problem, bad situation, or negative feeling worse or more intense.',
      example:
          'High traffic congestion exacerbates air pollution levels in densely populated cities.',
      collocations: [
        'exacerbate problem',
        'exacerbate symptoms',
        'exacerbate tension',
      ],
      idioms: ['add fuel to the fire'],
      phrasalVerbs: ['stir up'],
      repetitionCount: 1,
      easinessFactor: 2.4,
      intervalDays: 3,
      masteryLevel: 3,
    ),
  ];

  @override
  void initState() {
    super.initState();
    final items =
        (widget.initialItems != null && widget.initialItems!.isNotEmpty)
        ? widget.initialItems!
        : _defaultFlashcards;

    _session = SpacedRepetitionSession(
      id: 'session_${DateTime.now().millisecondsSinceEpoch}',
      items: items,
    );

    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _flipAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: _flipController, curve: Curves.easeInOutBack),
        )..addListener(() {
          setState(() {});
        });
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
      _flipController.reverse().then((_) {
        setState(() {
          _isFlipped = false;
        });
      });
    } else {
      _flipController.forward().then((_) {
        setState(() {
          _isFlipped = true;
        });
      });
    }
  }

  void _handleRatingSelected(ReviewRating rating) {
    if (_session.isCompleted) return;

    // Apply SM-2 algorithm update to session queue card
    _session.submitRating(rating);

    // If card was flipped, smoothly reset flip state before advancing
    if (_isFlipped) {
      _flipController.reverse().then((_) {
        setState(() {
          _isFlipped = false;
        });
      });
    } else {
      setState(() {});
    }
  }

  Future<void> _playAudioPronunciation(String text) async {
    if (_isPlayingAudio) return;

    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    setState(() {
      _isPlayingAudio = true;
    });

    try {
      final cleanText = trimmed.replaceAll(RegExp(r'[^\w\s\-]'), '');
      final isSingleWord = !cleanText.contains(' ');

      // Use Youdao dictvoice for single words, Google Translate TTS for full sentences
      final audioUrl = isSingleWord
          ? 'https://dict.youdao.com/dictvoice?audio=${Uri.encodeComponent(cleanText)}&type=1'
          : 'https://translate.google.com/translate_tts?ie=UTF-8&q=${Uri.encodeComponent(trimmed)}&tl=en&client=tw-ob';

      await _audioPlayer.stop();
      await _audioPlayer.play(UrlSource(audioUrl));
    } catch (e) {
      debugPrint('Primary TTS Audio playback error: $e');
      // Secondary fallback attempt with Google Translate TTS
      try {
        final fallbackUrl =
            'https://translate.google.com/translate_tts?ie=UTF-8&q=${Uri.encodeComponent(trimmed)}&tl=en&client=tw-ob';
        await _audioPlayer.stop();
        await _audioPlayer.play(UrlSource(fallbackUrl));
      } catch (fallbackError) {
        debugPrint('Fallback TTS error: $fallbackError');
      }
    } finally {
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          setState(() {
            _isPlayingAudio = false;
          });
        }
      });
    }
  }

  void _simulateAudioPronunciation(String word) {
    _playAudioPronunciation(word);
  }

  void _restartSession() {
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
      backgroundColor: isDark
          ? const Color(0xFF0F172A)
          : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          widget.sessionTitle ?? 'Flashcard Review',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Restart Session',
            onPressed: _restartSession,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: _session.isCompleted
              ? _buildCompletionSummaryCard(theme)
              : Column(
                  children: [
                    // Top Session Progress Bar & Stat Badges
                    _buildProgressBar(theme),

                    const SizedBox(height: 20),

                    // Card Flip Hint Tag
                    InkWell(
                      onTap: _toggleFlip,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: (isDark ? Colors.white : Colors.black)
                              .withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.3,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _isFlipped
                                  ? Icons.flip_to_front
                                  : Icons.flip_to_back,
                              size: 16,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _isFlipped
                                  ? 'Tap to view Front (Context)'
                                  : 'Tap card to reveal Back (Details)',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 3D Animated Flashcard
                    Expanded(
                      child: GestureDetector(
                        onTap: _toggleFlip,
                        child: _build3DCard(theme),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // SM-2 Rating Buttons Bar
                    _buildSM2RatingButtons(theme),
                  ],
                ),
        ),
      ),
    );
  }

  /// Linear session progress bar with card count stats.
  Widget _buildProgressBar(ThemeData theme) {
    final progress = _session.progressRatio;
    final total = _session.totalCards;
    final current = _session.cardsReviewed + 1;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Card $current of $total',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyMedium?.color,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${(progress * 100).toInt()}% Completed',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(
              theme.colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  /// 3D Card Transformation widget with Front and Back side rendering.
  Widget _build3DCard(ThemeData theme) {
    final card = _session.currentCard!;
    final angle = _flipAnimation.value * math.pi;

    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001) // perspective depth
        ..rotateY(angle),
      alignment: Alignment.center,
      child: angle < math.pi / 2
          ? _buildCardFront(card, theme)
          : Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()..rotateY(math.pi), // reverse mirror
              child: _buildCardBack(card, theme),
            ),
    );
  }

  /// Front Side: Word, Phonetic, Audio button, Context Sentence
  Widget _buildCardFront(FlashcardItem card, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(28.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // CEFR Level Badge & Spaced Repetition Mastery Level
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCefrBadge(card.cefrLevel),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.amber.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      'Mastery Stage ${card.masteryLevel}/5',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Spacer(),

          // Target Vocabulary Word
          Text(
            card.word,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),

          const SizedBox(height: 10),

          // Phonetic Spelling & Pronunciation Audio Button
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                card.phonetic,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: theme.textTheme.bodyMedium?.color?.withValues(
                    alpha: 0.7,
                  ),
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () => _simulateAudioPronunciation(card.word),
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _isPlayingAudio
                      ? Icon(
                          Icons.graphic_eq,
                          color: theme.colorScheme.primary,
                          key: const ValueKey(1),
                        )
                      : Icon(
                          Icons.volume_up_rounded,
                          color: theme.colorScheme.primary,
                          key: const ValueKey(2),
                        ),
                ),
                tooltip: 'Pronounce',
              ),
            ],
          ),

          const Spacer(),

          // Context Usage Quote Box
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.15),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.format_quote_rounded,
                  size: 24,
                  color: theme.colorScheme.primary.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'CONTEXT USAGE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.1,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _playAudioPronunciation(card.example),
                            child: Icon(
                              Icons.volume_up_rounded,
                              size: 16,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        card.example,
                        style: TextStyle(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          height: 1.4,
                          color: isDark
                              ? const Color(0xFFE2E8F0)
                              : const Color(0xFF334155),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Back Side: Definition, CEFR level badge, Collocations, Idioms, Phrasal Verbs
  Widget _buildCardBack(FlashcardItem card, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.4),
          width: 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(
              alpha: isDark ? 0.3 : 0.12,
            ),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Word & CEFR Badge Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      card.word,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(
                        Icons.volume_up_rounded,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                      onPressed: () => _playAudioPronunciation(card.word),
                      tooltip: 'Listen to word',
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(4),
                    ),
                  ],
                ),
                _buildCefrBadge(card.cefrLevel),
              ],
            ),
            const Divider(height: 24),

            // Definition
            const Text(
              'DEFINITION',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              card.definition,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                height: 1.4,
                color: isDark
                    ? const Color(0xFFF1F5F9)
                    : const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 16),

            // Collocations
            if (card.collocations.isNotEmpty) ...[
              const Text(
                'IELTS COLLOCATIONS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: card.collocations.map((col) {
                  return Chip(
                    label: Text(
                      col,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    backgroundColor: theme.colorScheme.primary.withValues(
                      alpha: 0.1,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    visualDensity: VisualDensity.compact,
                    side: BorderSide(
                      color: theme.colorScheme.primary.withValues(alpha: 0.2),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],

            // Idioms
            if (card.idioms.isNotEmpty) ...[
              const Text(
                'IDIOMS & PHRASES',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: card.idioms.map((idiom) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.lightbulb_outline,
                          size: 14,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          idiom,
                          style: TextStyle(
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                            color: isDark
                                ? const Color(0xFFCBD5E1)
                                : const Color(0xFF475569),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],

            // Phrasal Verbs
            if (card.phrasalVerbs.isNotEmpty) ...[
              const Text(
                'PHRASAL VERBS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: card.phrasalVerbs.map((pv) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.purple.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.purple.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      pv,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.purple,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// SM-2 Rating Buttons: Again (1d), Hard (3d), Good (6d), Easy (12d)
  Widget _buildSM2RatingButtons(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: _buildRatingButton(
            label: ReviewRating.again.fullButtonLabel,
            rating: ReviewRating.again,
            color: const Color(0xFFEF4444), // Danger Red
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildRatingButton(
            label: ReviewRating.hard.fullButtonLabel,
            rating: ReviewRating.hard,
            color: const Color(0xFFF59E0B), // Amber Orange
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildRatingButton(
            label: ReviewRating.good.fullButtonLabel,
            rating: ReviewRating.good,
            color: const Color(0xFF10B981), // Emerald Green
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildRatingButton(
            label: ReviewRating.easy.fullButtonLabel,
            rating: ReviewRating.easy,
            color: const Color(0xFF6366F1), // Indigo Primary
          ),
        ),
      ],
    );
  }

  Widget _buildRatingButton({
    required String label,
    required ReviewRating rating,
    required Color color,
  }) {
    return ElevatedButton(
      onPressed: () => _handleRatingSelected(rating),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  /// Completion Summary Card shown when all cards in session are reviewed.
  Widget _buildCompletionSummaryCard(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 6,
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.workspace_premium,
                  size: 48,
                  color: Color(0xFF10B981),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Session Complete!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              Text(
                'You have reviewed all ${_session.totalCards} cards in this spaced repetition set.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: theme.textTheme.bodyMedium?.color?.withValues(
                    alpha: 0.7,
                  ),
                ),
              ),
              const Divider(height: 32),

              // Rating Breakdown Grid
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatMetric(
                    'Again (1d)',
                    '${_session.againCount}',
                    const Color(0xFFEF4444),
                  ),
                  _buildStatMetric(
                    'Hard (3d)',
                    '${_session.hardCount}',
                    const Color(0xFFF59E0B),
                  ),
                  _buildStatMetric(
                    'Good (6d)',
                    '${_session.goodCount}',
                    const Color(0xFF10B981),
                  ),
                  _buildStatMetric(
                    'Easy (12d)',
                    '${_session.easyCount}',
                    const Color(0xFF6366F1),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        } else {
                          _restartSession();
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Word Bank',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _restartSession,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Review Again',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildCefrBadge(String cefr) {
    Color bg;
    switch (cefr.toUpperCase()) {
      case 'C2':
      case 'C1':
        bg = Colors.purple;
        break;
      case 'B2':
      case 'B1':
        bg = Colors.blue;
        break;
      default:
        bg = Colors.green;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        cefr,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 12,
        ),
      ),
    );
  }
}
