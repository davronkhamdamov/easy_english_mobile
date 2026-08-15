/// Quality rating choices for SM-2 spaced repetition review.
enum ReviewRating {
  again, // Rating 1: Complete blackout, 1 day interval
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
