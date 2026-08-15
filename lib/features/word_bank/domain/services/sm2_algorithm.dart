import 'review_rating.dart';

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
class SM2Algorithm {
  SM2Algorithm._();

  static const double minEasinessFactor = 1.3;

  static SM2CalculationResult calculate({
    required double currentEF,
    required int currentRepetition,
    required int currentInterval,
    required ReviewRating rating,
    DateTime? referenceTime,
  }) {
    final now = referenceTime ?? DateTime.now();
    final q = rating.qualityScore;

    double newEF = currentEF + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02));
    if (newEF < minEasinessFactor) {
      newEF = minEasinessFactor;
    }
    newEF = (newEF * 100).roundToDouble() / 100.0;

    int newRepetition;
    int newInterval;

    if (q < 3) {
      newRepetition = 0;
      newInterval = 1;
    } else {
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
