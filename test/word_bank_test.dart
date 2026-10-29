import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:easy_english/core/network/api_client.dart';
import 'package:easy_english/core/theme/app_colors.dart';
import 'package:easy_english/core/theme/app_theme.dart';
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
import 'package:easy_english/features/word_bank/presentation/screens/word_bank_screen.dart';

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

  group('WordBankRemoteDataSourceImpl API Contract Tests', () {
    test('Handles direct array JSON responses', () async {
      final client = _MockWordBankApiClient(
        onGet: (path) async {
          if (path.contains('/wordbank/due/')) {
            return http.Response(
              '[{"id": "wb_due_1", "word": "Persist", "phonetic": "/persist/", "cefr_level": "B2", "definition": "Continue firmly", "example": "Persist with it"}]',
              200,
            );
          }
          if (path.contains('/wordbank/')) {
            return http.Response(
              '[{"id": "wb_1", "word": "Foster", "phonetic": "/foster/", "cefr_level": "C1", "definition": "Encourage", "example": "Foster growth"}]',
              200,
            );
          }
          return http.Response('[]', 200);
        },
      );

      final ds = WordBankRemoteDataSourceImpl(apiClient: client);
      final items = await ds.fetchWordBankItems();
      expect(items.length, 1);
      expect(items.first.word, 'Foster');

      final due = await ds.fetchDueFlashcards();
      expect(due.length, 1);
      expect(due.first.word, 'Persist');
    });

    test('Handles map-wrapped JSON responses (results, data, due_cards)', () async {
      final client = _MockWordBankApiClient(
        onGet: (path) async {
          if (path.contains('/wordbank/due/')) {
            return http.Response(
              '{"due_cards": [{"id": "wb_due_2", "word": "Resilient", "phonetic": "/resilient/", "cefr_level": "B2", "definition": "Able to recover", "example": "Resilient spirit"}]}',
              200,
            );
          }
          if (path.contains('/wordbank/')) {
            return http.Response(
              '{"results": [{"id": "wb_2", "word": "Eloquent", "phonetic": "/eloquent/", "cefr_level": "C1", "definition": "Fluent speech", "example": "Eloquent speaker"}]}',
              200,
            );
          }
          return http.Response('{}', 200);
        },
      );

      final ds = WordBankRemoteDataSourceImpl(apiClient: client);
      final items = await ds.fetchWordBankItems();
      expect(items.length, 1);
      expect(items.first.word, 'Eloquent');

      final due = await ds.fetchDueFlashcards();
      expect(due.length, 1);
      expect(due.first.word, 'Resilient');
    });
  });

  group('WordBankScreen FloatingActionButton Palette Theming Tests', () {
    testWidgets('FAB in dark mode uses Obsidian OLED darkSurfaceVariant and darkTextPrimary, not completely white', (tester) async {
      final fakeRepo = WordBankRepositoryImpl(remoteDataSource: FakeWordBankRemoteDataSource());

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: WordBankScreen(repository: fakeRepo),
        ),
      );
      await tester.pumpAndSettle();

      final fabFinder = find.byType(FloatingActionButton);
      expect(fabFinder, findsOneWidget);

      final fab = tester.widget<FloatingActionButton>(fabFinder);
      // Background must NOT be pure white (0xFFFFFFFF)
      expect(fab.backgroundColor, isNot(equals(Colors.white)));
      expect(fab.backgroundColor, AppColors.currentPalette.darkSurfaceVariant);
      expect(fab.foregroundColor, AppColors.currentPalette.darkTextPrimary);
      expect(fab.backgroundColor != fab.foregroundColor, isTrue);

      expect(find.text('Review Flashcards (1 Due)'), findsOneWidget);
      expect(find.byIcon(Icons.style_outlined), findsOneWidget);
    });

    testWidgets('FAB in light mode uses global palette primary and white foreground', (tester) async {
      final fakeRepo = WordBankRepositoryImpl(remoteDataSource: FakeWordBankRemoteDataSource());

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: WordBankScreen(repository: fakeRepo),
        ),
      );
      await tester.pumpAndSettle();

      final fabFinder = find.byType(FloatingActionButton);
      expect(fabFinder, findsOneWidget);

      final fab = tester.widget<FloatingActionButton>(fabFinder);
      expect(fab.backgroundColor, AppColors.currentPalette.primary);
      expect(fab.foregroundColor, Colors.white);
      expect(fab.backgroundColor != fab.foregroundColor, isTrue);
    });
  });
}

class _MockWordBankApiClient extends ApiClient {
  final Future<http.Response> Function(String path)? onGet;

  _MockWordBankApiClient({this.onGet});

  @override
  Future<http.Response> get(String path) async {
    if (onGet != null) return await onGet!(path);
    return http.Response('[]', 200);
  }

  @override
  Future<http.Response> post(String path, Map<String, dynamic> body) async {
    return http.Response('{}', 200);
  }
}
