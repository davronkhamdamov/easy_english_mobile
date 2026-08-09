import 'package:flutter_test/flutter_test.dart';
import 'package:easy_english/features/word_bank/domain/entities/flashcard_item.dart';
import 'package:easy_english/features/word_bank/domain/services/spaced_repetition.dart';
import 'package:easy_english/features/word_bank/domain/usecases/get_word_bank.dart';
import 'package:easy_english/features/word_bank/domain/usecases/get_due_cards.dart';
import 'package:easy_english/features/word_bank/domain/usecases/review_flashcard.dart';
import 'package:easy_english/features/word_bank/data/models/flashcard_item_model.dart';
import 'package:easy_english/features/word_bank/data/repositories/word_bank_repository_impl.dart';

void main() {
  group('FlashcardItemModel JSON Serialization Tests', () {
    test('FlashcardItemModel fromJson and toJson roundtrip', () {
      final json = {
        'id': 'wb_1',
        'word': 'Foster',
        'phonetic': '/ˈfɒstər/',
        'cefr_level': 'C1',
        'definition': 'To encourage growth.',
        'example': 'Foster growth.',
        'collocations': ['foster growth'],
        'repetition_count': 1,
        'easiness_factor': 2.5,
        'interval_days': 3,
        'mastery_level': 3,
      };

      final model = FlashcardItemModel.fromJson(json);
      expect(model.id, 'wb_1');
      expect(model.word, 'Foster');
      expect(model.cefrLevel, 'C1');
      expect(model.collocations, ['foster growth']);
      expect(model.easinessFactor, 2.5);

      final convertedJson = model.toJson();
      expect(convertedJson['id'], 'wb_1');
      expect(convertedJson['word'], 'Foster');
      expect(convertedJson['cefr_level'], 'C1');
    });

    test('FlashcardItemModel fromEntity mapping', () {
      const entity = FlashcardItem(
        id: 'wb_2',
        word: 'Paramount',
        phonetic: '/ˈpærəmaʊnt/',
        cefrLevel: 'C1',
        definition: 'Supreme.',
        example: 'Paramount importance.',
      );

      final model = FlashcardItemModel.fromEntity(entity);
      expect(model.id, entity.id);
      expect(model.word, entity.word);
      expect(model.toEntity(), isA<FlashcardItem>());
    });
  });

  group('WordBank Repository & Use Cases Tests', () {
    late WordBankRepositoryImpl repository;

    setUp(() {
      repository = WordBankRepositoryImpl();
    });

    test('GetWordBank usecase retrieves items cleanly', () async {
      final usecase = GetWordBank(repository);
      final items = await usecase();
      expect(items.isNotEmpty, true);
      expect(items.first.word, 'Foster');
    });

    test('GetDueCards usecase retrieves due cards', () async {
      final usecase = GetDueCards(repository);
      final dueCards = await usecase();
      expect(dueCards.isNotEmpty, true);
    });

    test(
      'ReviewFlashcard usecase updates card spaced repetition parameters',
      () async {
        final usecase = ReviewFlashcard(repository);
        final updated = await usecase(id: 'wb_1', rating: ReviewRating.good);
        expect(updated.id, 'wb_1');
        expect(updated.repetitionCount, greaterThanOrEqualTo(0));
      },
    );
  });
}
