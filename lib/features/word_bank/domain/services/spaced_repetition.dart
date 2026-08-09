import '../entities/flashcard_item.dart';

/// Quality rating choices for SM-2 spaced repetition review.
enum ReviewRating {
  again, // Rating 1: Complete black out, 1 day interval
  hard, // Rating 3: Correct response with difficulty, 3 days interval
  good, // Rating 4: Correct response after hesitating, 6 days interval
  easy, // Rating 5: Perfect recall without hesitation, 12 days interval
}

extension ReviewRatingExtension on ReviewRating {
  /// Maps rating enum to SM-2 quality score (0 to 5).
  int get qualityScore {
    switch (this) {
      case ReviewRating.again:
        return 1;
      case ReviewRating.hard:
        return 3;
      case ReviewRating.good:
        return 4;
      case ReviewRating.easy:
        return 5;
    }
  }

  /// Human-readable rating button label.
  String get label {
    switch (this) {
      case ReviewRating.again:
        return 'Again';
      case ReviewRating.hard:
        return 'Hard';
      case ReviewRating.good:
        return 'Good';
      case ReviewRating.easy:
        return 'Easy';
    }
  }

  /// Target interval label for rating buttons ("1d", "3d", "6d", "12d").
  String get intervalLabel {
    switch (this) {
      case ReviewRating.again:
        return '1d';
      case ReviewRating.hard:
        return '3d';
      case ReviewRating.good:
        return '6d';
      case ReviewRating.easy:
        return '12d';
    }
  }

  /// Full button label combining text and interval e.g. "Again (1d)".
  String get fullButtonLabel => '$label ($intervalLabel)';

  /// Default baseline interval in days for first successful repetition.
  int get defaultIntervalDays {
    switch (this) {
      case ReviewRating.again:
        return 1;
      case ReviewRating.hard:
        return 3;
      case ReviewRating.good:
        return 6;
      case ReviewRating.easy:
        return 12;
    }
  }
}

/// Calculation output returned after applying SM-2 algorithm to a review rating.
class SM2CalculationResult {
  final int repetitionCount;
  final double easinessFactor;
  final int intervalDays;
  final int masteryLevel;
  final DateTime nextReviewAt;

  const SM2CalculationResult({
    required this.repetitionCount,
    required this.easinessFactor,
    required this.intervalDays,
    required this.masteryLevel,
    required this.nextReviewAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'repetition_count': repetitionCount,
      'easiness_factor': easinessFactor,
      'interval_days': intervalDays,
      'mastery_level': masteryLevel,
      'next_review_at': nextReviewAt.toIso8601String(),
    };
  }
}

/// Implementation of the SuperMemo SM-2 Spaced Repetition Algorithm.
///
/// SM-2 Formula:
/// EF' = EF + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02))
/// Enforces: EF' >= 1.3
/// Repetition Count n:
/// If quality score q < 3 (failure): n = 0, Interval I = 1 day.
/// If quality score q >= 3 (success): n = n + 1.
///   For n = 1: Interval I is based on initial rating choice (Again: 1d, Hard: 3d, Good: 6d, Easy: 12d)
///   For n = 2: Interval I = 6 days (or 12 days for Easy)
///   For n > 2: Interval I = round(previous_I * EF')
class SM2Algorithm {
  SM2Algorithm._();

  /// Minimum allowed Easiness Factor as defined by SM-2 standard.
  static const double minEasinessFactor = 1.3;

  /// Calculates new SM-2 parameters for a word after user review rating.
  static SM2CalculationResult calculate({
    required double currentEF,
    required int currentRepetition,
    required int currentInterval,
    required ReviewRating rating,
    DateTime? referenceTime,
  }) {
    final now = referenceTime ?? DateTime.now();
    final q = rating.qualityScore;

    // 1. Calculate updated Easiness Factor EF (constrained EF >= 1.3)
    double newEF = currentEF + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02));
    if (newEF < minEasinessFactor) {
      newEF = minEasinessFactor;
    }
    // Round EF to 2 decimal places for clean floating point storage
    newEF = (newEF * 100).roundToDouble() / 100.0;

    int newRepetition;
    int newInterval;

    if (q < 3) {
      // Failed recall -> Reset repetition count and schedule for 1 day
      newRepetition = 0;
      newInterval = 1;
    } else {
      // Successful recall -> Increment repetition count
      newRepetition = currentRepetition + 1;

      if (newRepetition == 1) {
        newInterval = rating.defaultIntervalDays;
      } else if (newRepetition == 2) {
        newInterval = rating == ReviewRating.easy ? 12 : 6;
      } else {
        newInterval = (currentInterval * newEF).round();
        if (newInterval < currentInterval + 1) {
          newInterval = currentInterval + 1;
        }
      }
    }

    // Determine mastery level (scale 0 to 5)
    int masteryLevel;
    if (q < 3) {
      masteryLevel = 1;
    } else if (newInterval >= 12 || newRepetition >= 4) {
      masteryLevel = 5;
    } else if (newInterval >= 6 || newRepetition >= 3) {
      masteryLevel = 4;
    } else if (newInterval >= 3 || newRepetition >= 2) {
      masteryLevel = 3;
    } else {
      masteryLevel = 2;
    }

    final nextReviewAt = now.add(Duration(days: newInterval));

    return SM2CalculationResult(
      repetitionCount: newRepetition,
      easinessFactor: newEF,
      intervalDays: newInterval,
      masteryLevel: masteryLevel,
      nextReviewAt: nextReviewAt,
    );
  }
}

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
  }) : originalItems = List.unmodifiable(items),
       _queue = List.from(items);

  int get currentIndex => _currentIndex;
  int get totalCards => originalItems.length;
  int get cardsReviewed => _currentIndex;
  int get againCount => _againCount;
  int get hardCount => _hardCount;
  int get goodCount => _goodCount;
  int get easyCount => _easyCount;
  List<FlashcardItem> get updatedItems => List.unmodifiable(_updatedItems);

  /// Check if all cards in session have been reviewed.
  bool get isCompleted => _currentIndex >= _queue.length;

  /// Returns current active flashcard item or null if completed.
  FlashcardItem? get currentCard => isCompleted ? null : _queue[_currentIndex];

  /// Progress ratio from 0.0 to 1.0.
  double get progressRatio =>
      _queue.isEmpty ? 1.0 : (_currentIndex / _queue.length).clamp(0.0, 1.0);

  /// Process rating for current flashcard, apply SM-2 algorithm, and advance session.
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

    // Track rating counts
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

  /// Resets the session state to start over.
  void reset() {
    _currentIndex = 0;
    _againCount = 0;
    _hardCount = 0;
    _goodCount = 0;
    _easyCount = 0;
    _updatedItems.clear();
  }
}
