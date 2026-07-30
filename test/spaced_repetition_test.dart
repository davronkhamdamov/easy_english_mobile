import 'package:flutter_test/flutter_test.dart';
import 'package:easy_english/features/word_bank/domain/spaced_repetition.dart';

void main() {
  group('SM2Algorithm Tests', () {
    test('Initial rating calculations produce correct baseline intervals', () {
      final now = DateTime(2026, 7, 28);

      final againRes = SM2Algorithm.calculate(
        currentEF: 2.5,
        currentRepetition: 0,
        currentInterval: 0,
        rating: ReviewRating.again,
        referenceTime: now,
      );
      expect(againRes.repetitionCount, 0);
      expect(againRes.intervalDays, 1);
      expect(againRes.nextReviewAt, now.add(const Duration(days: 1)));

      final hardRes = SM2Algorithm.calculate(
        currentEF: 2.5,
        currentRepetition: 0,
        currentInterval: 0,
        rating: ReviewRating.hard,
        referenceTime: now,
      );
      expect(hardRes.repetitionCount, 1);
      expect(hardRes.intervalDays, 3);
      expect(hardRes.nextReviewAt, now.add(const Duration(days: 3)));

      final goodRes = SM2Algorithm.calculate(
        currentEF: 2.5,
        currentRepetition: 0,
        currentInterval: 0,
        rating: ReviewRating.good,
        referenceTime: now,
      );
      expect(goodRes.repetitionCount, 1);
      expect(goodRes.intervalDays, 6);

      final easyRes = SM2Algorithm.calculate(
        currentEF: 2.5,
        currentRepetition: 0,
        currentInterval: 0,
        rating: ReviewRating.easy,
        referenceTime: now,
      );
      expect(easyRes.repetitionCount, 1);
      expect(easyRes.intervalDays, 12);
    });

    test('Easiness Factor stays >= 1.3 even after multiple Again ratings', () {
      double ef = 1.4;
      for (int i = 0; i < 5; i++) {
        final res = SM2Algorithm.calculate(
          currentEF: ef,
          currentRepetition: 0,
          currentInterval: 1,
          rating: ReviewRating.again,
        );
        ef = res.easinessFactor;
        expect(res.easinessFactor, greaterThanOrEqualTo(1.3));
      }
      expect(ef, equals(1.3));
    });

    test('Interval scales based on previous interval and EF for n > 2', () {
      final res = SM2Algorithm.calculate(
        currentEF: 2.5,
        currentRepetition: 2,
        currentInterval: 6,
        rating: ReviewRating.good,
      );
      expect(res.repetitionCount, 3);
      // EF' = 2.5 + (0.1 - (5-4)*(0.08 + (5-4)*0.02)) = 2.5 + (0.1 - 0.1) = 2.5
      expect(res.easinessFactor, equals(2.5));
      // Interval = 6 * 2.5 = 15
      expect(res.intervalDays, equals(15));
    });
  });

  group('SpacedRepetitionSession Tests', () {
    test('Session queues cards and completes correctly', () {
      final items = [
        const FlashcardItem(
          id: '1',
          word: 'Foster',
          phonetic: '/ˈfɒstər/',
          cefrLevel: 'C1',
          definition: 'To encourage growth.',
          example: 'Foster growth.',
        ),
        const FlashcardItem(
          id: '2',
          word: 'Paramount',
          phonetic: '/ˈpærəmaʊnt/',
          cefrLevel: 'C1',
          definition: 'Supreme.',
          example: 'Paramount importance.',
        ),
      ];

      final session = SpacedRepetitionSession(id: 'sess_1', items: items);
      expect(session.isCompleted, false);
      expect(session.currentCard?.word, 'Foster');
      expect(session.progressRatio, 0.0);

      session.submitRating(ReviewRating.good);
      expect(session.cardsReviewed, 1);
      expect(session.currentCard?.word, 'Paramount');
      expect(session.progressRatio, 0.5);

      session.submitRating(ReviewRating.easy);
      expect(session.isCompleted, true);
      expect(session.currentCard, null);
      expect(session.progressRatio, 1.0);
      expect(session.goodCount, 1);
      expect(session.easyCount, 1);
    });
  });
}
