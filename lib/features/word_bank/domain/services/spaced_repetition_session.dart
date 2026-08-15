import '../entities/flashcard_item.dart';
import 'review_rating.dart';
import 'sm2_algorithm.dart';

/// Spaced Repetition Session model managing session queue, scoring, and progress.
class SpacedRepetitionSession {
  final String id;
  final List<FlashcardItem> originalItems;
  final List<FlashcardItem> _queue;

  int _currentIndex = 0;
  int _againCount = 0;
  int _hardCount = 0;
  int _goodCount = 0;
  int _easyCount = 0;
  final List<FlashcardItem> _updatedItems = [];

  SpacedRepetitionSession({
    required this.id,
    required List<FlashcardItem> items,
  })  : originalItems = List.unmodifiable(items),
        _queue = List.from(items);

  int get currentIndex => _currentIndex;
  int get totalCards => originalItems.length;
  int get cardsReviewed => _currentIndex;
  int get againCount => _againCount;
  int get hardCount => _hardCount;
  int get goodCount => _goodCount;
  int get easyCount => _easyCount;
  List<FlashcardItem> get updatedItems => List.unmodifiable(_updatedItems);

  bool get isCompleted => _currentIndex >= _queue.length;

  FlashcardItem? get currentCard => isCompleted ? null : _queue[_currentIndex];

  double get progressRatio =>
      _queue.isEmpty ? 1.0 : (_currentIndex / _queue.length).clamp(0.0, 1.0);

  SM2CalculationResult? submitRating(ReviewRating rating, {DateTime? now}) {
    if (isCompleted) return null;

    final card = _queue[_currentIndex];
    final calcResult = SM2Algorithm.calculate(
      currentEF: card.easinessFactor,
      currentRepetition: card.repetitionCount,
      currentInterval: card.intervalDays,
      rating: rating,
      referenceTime: now,
    );

    switch (rating) {
      case ReviewRating.again:
        _againCount++;
        break;
      case ReviewRating.hard:
        _hardCount++;
        break;
      case ReviewRating.good:
        _goodCount++;
        break;
      case ReviewRating.easy:
        _easyCount++;
        break;
    }

    final updatedCard = card.copyWith(
      repetitionCount: calcResult.repetitionCount,
      easinessFactor: calcResult.easinessFactor,
      intervalDays: calcResult.intervalDays,
      masteryLevel: calcResult.masteryLevel,
      lastReviewedAt: now ?? DateTime.now(),
      nextReviewAt: calcResult.nextReviewAt,
    );

    _updatedItems.add(updatedCard);
    _currentIndex++;

    return calcResult;
  }

  void reset() {
    _currentIndex = 0;
    _againCount = 0;
    _hardCount = 0;
    _goodCount = 0;
    _easyCount = 0;
    _updatedItems.clear();
  }
}
