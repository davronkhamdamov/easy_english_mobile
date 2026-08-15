import 'package:flutter_test/flutter_test.dart';
import 'package:easy_english/features/word_bank/data/datasources/word_bank_remote_datasource.dart';
import 'package:easy_english/features/word_bank/data/models/flashcard_item_model.dart';
import 'package:easy_english/features/word_bank/data/repositories/word_bank_repository_impl.dart';
import 'package:easy_english/features/word_bank/domain/entities/flashcard_item.dart';
import 'package:easy_english/features/word_bank/domain/services/spaced_repetition.dart';
import 'package:easy_english/features/word_bank/domain/usecases/add_word.dart';
import 'package:easy_english/features/word_bank/domain/usecases/delete_word.dart';
import 'package:easy_english/features/word_bank/domain/usecases/get_due_cards.dart';
import 'package:easy_english/features/word_bank/domain/usecases/get_word_bank.dart';
import 'package:easy_english/features/word_bank/domain/usecases/review_flashcard.dart';
import 'package:easy_english/features/word_bank/presentation/providers/word_bank_provider.dart';

class FakeWordBankRemoteDataSource implements WordBankRemoteDataSource {
  final List<FlashcardItemModel> items = [
    const FlashcardItemModel(
      id: 'wb_101',
      word: 'Foster',
      phonetic: '/ˈfɒstər/',
      cefrLevel: 'C1',
      definition: 'To encourage the development or growth of ideas.',
      example: 'The policies aim to foster economic growth.',
      collocations: ['foster growth', 'foster innovation'],
      repetitionCount: 2,
      easinessFactor: 2.5,
      intervalDays: 3,
      masteryLevel: 3,
    ),
  ];

  @override
  Future<List<FlashcardItemModel>> fetchWordBankItems() async => items;

  @override
  Future<List<FlashcardItemModel>> fetchDueFlashcards() async => items;

  @override
  Future<FlashcardItemModel> submitReviewRating(
    String id,
    Map<String, dynamic> reviewData,
  ) async {
    final found = items.firstWhere((e) => e.id == id);
    return FlashcardItemModel(
      id: found.id,
      word: found.word,
      phonetic: found.phonetic,
      cefrLevel: found.cefrLevel,
      definition: found.definition,
      example: found.example,
      repetitionCount: found.repetitionCount + 1,
      easinessFactor: 2.6,
      intervalDays: 6,
      masteryLevel: 4,
    );
  }

  @override
  Future<FlashcardItemModel> addWord(FlashcardItemModel model) async {
    items.add(model);
    return model;
  }

  @override
  Future<bool> deleteWord(String id) async {
    items.removeWhere((e) => e.id == id);
    return true;
  }
}

void main() {
  group('FlashcardItemModel JSON Serialization Tests', () {
    test('FlashcardItemModel fromJson and toJson roundtrip', () {
      final json = {
        'id': 'wb_101',
        'word': 'Foster',
        'phonetic': '/ˈfɒstər/',
        'cefr_level': 'C1',
        'definition': 'To encourage growth.',
        'example': 'Foster growth.',
        'collocations': ['foster growth'],
        'repetition_count': 2,
        'easiness_factor': 2.5,
        'interval_days': 3,
        'mastery_level': 3,
      };

      final model = FlashcardItemModel.fromJson(json);
      expect(model.id, 'wb_101');
      expect(model.word, 'Foster');
      expect(model.cefrLevel, 'C1');
      expect(model.collocations, ['foster growth']);
      expect(model.easinessFactor, 2.5);

      final convertedJson = model.toJson();
      expect(convertedJson['id'], 'wb_101');
      expect(convertedJson['word'], 'Foster');
      expect(convertedJson['cefr_level'], 'C1');
    });

    test('FlashcardItemModel fromEntity mapping', () {
      const entity = FlashcardItem(
        id: 'wb_102',
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

  group('SM-2 Algorithm & Session Tests', () {
    test('SM2Algorithm calculate updates parameters correctly for Good rating', () {
      final result = SM2Algorithm.calculate(
        currentEF: 2.5,
        currentRepetition: 1,
        currentInterval: 3,
        rating: ReviewRating.good,
      );

      expect(result.repetitionCount, 2);
      expect(result.intervalDays, 6);
      expect(result.easinessFactor, greaterThanOrEqualTo(1.3));
    });

    test('SpacedRepetitionSession advances session and updates metrics', () {
      const card = FlashcardItem(
        id: 'wb_101',
        word: 'Foster',
        phonetic: '/ˈfɒstər/',
        cefrLevel: 'C1',
        definition: 'Definition',
        example: 'Example',
      );
      final session = SpacedRepetitionSession(id: 's1', items: [card]);

      expect(session.totalCards, 1);
      expect(session.isCompleted, false);

      final result = session.submitRating(ReviewRating.good);
      expect(result, isNotNull);
      expect(session.goodCount, 1);
      expect(session.isCompleted, true);
    });
  });

  group('WordBank Repository & Use Cases Tests', () {
    late WordBankRepositoryImpl repository;
    late FakeWordBankRemoteDataSource fakeDataSource;

    setUp(() {
      fakeDataSource = FakeWordBankRemoteDataSource();
      repository = WordBankRepositoryImpl(remoteDataSource: fakeDataSource);
    });

    test('GetWordBank usecase retrieves items from remote data source', () async {
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

    test('ReviewFlashcard usecase updates card SRS parameters', () async {
      final usecase = ReviewFlashcard(repository);
      final updated = await usecase(id: 'wb_101', rating: ReviewRating.good);
      expect(updated.id, 'wb_101');
      expect(updated.repetitionCount, 3);
      expect(updated.masteryLevel, 4);
    });

    test('AddWord and DeleteWord usecases modify inventory', () async {
      final addUseCase = AddWord(repository);
      final deleteUseCase = DeleteWord(repository);

      const newWord = FlashcardItem(
        id: 'wb_103',
        word: 'Mitigate',
        phonetic: '/ˈmɪtɪɡeɪt/',
        cefrLevel: 'B2',
        definition: 'Make less severe.',
        example: 'Mitigate risk.',
      );

      final added = await addUseCase(newWord);
      expect(added.id, 'wb_103');

      final itemsAfterAdd = await repository.getWordBankItems();
      expect(itemsAfterAdd.length, 2);

      final deleted = await deleteUseCase('wb_103');
      expect(deleted, true);

      final itemsAfterDelete = await repository.getWordBankItems();
      expect(itemsAfterDelete.length, 1);
    });
  });

  group('WordBankProvider State Management Tests', () {
    test('Provider loads word bank and handles filters', () async {
      final fakeDataSource = FakeWordBankRemoteDataSource();
      final repository = WordBankRepositoryImpl(remoteDataSource: fakeDataSource);
      final provider = WordBankProvider(repository: repository);

      await provider.loadWordBank();
      expect(provider.state.wordItems.length, 1);
      expect(provider.state.isLoading, false);

      provider.setSearchQuery('Foster');
      expect(provider.state.filteredWordItems.length, 1);

      provider.setSearchQuery('NonExistentWord');
      expect(provider.state.filteredWordItems.length, 0);

      provider.setSearchQuery('');
      provider.setCefrFilter('C1');
      expect(provider.state.filteredWordItems.length, 1);

      provider.setCefrFilter('B1');
      expect(provider.state.filteredWordItems.length, 0);
    });
  });
}
