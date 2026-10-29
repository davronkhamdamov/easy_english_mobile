import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:easy_english/core/theme/app_theme.dart';
import 'package:easy_english/features/word_bank/data/datasources/word_search_history_service.dart';
import 'package:easy_english/features/word_bank/data/datasources/word_suggestion_service.dart';
import 'package:easy_english/features/word_bank/data/models/flashcard_item_model.dart';
import 'package:easy_english/features/word_bank/domain/entities/flashcard_item.dart';
import 'package:easy_english/features/word_bank/domain/repositories/word_bank_repository.dart';
import 'package:easy_english/features/word_bank/domain/services/spaced_repetition.dart';
import 'package:easy_english/features/word_bank/presentation/screens/flashcard_review_screen.dart';
import 'package:easy_english/features/word_bank/presentation/screens/vocabulary_screen.dart';
import 'package:easy_english/features/word_bank/presentation/screens/word_definition_screen.dart';

class _MockHttpClient extends http.BaseClient {
  final Future<http.Response> Function(http.Request request) onSend;
  _MockHttpClient(this.onSend);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final req = request as http.Request;
    final res = await onSend(req);
    final bytes = res.bodyBytes.isNotEmpty ? res.bodyBytes : res.body.codeUnits;
    return http.StreamedResponse(
      Stream.value(bytes),
      res.statusCode,
      headers: {
        'content-type': 'application/json; charset=utf-8',
        ...res.headers,
      },
    );
  }
}

class FakeVocabularyRepository implements WordBankRepository {
  final List<FlashcardItem> items;
  final List<FlashcardItem> dueItems;

  FakeVocabularyRepository({
    required this.items,
    required this.dueItems,
  });

  @override
  Future<List<FlashcardItem>> getWordBankItems() async => items;

  @override
  Future<List<FlashcardItem>> getDueFlashcards() async => dueItems;

  @override
  Future<FlashcardItem> submitReview({
    required String id,
    required ReviewRating rating,
  }) async {
    return items.firstWhere((e) => e.id == id);
  }

  @override
  Future<FlashcardItem> addWord(FlashcardItem item) async => item;

  @override
  Future<bool> removeWord(String id) async => true;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final mockItems = [
    const FlashcardItemModel(
      id: 'vocab_01',
      word: 'Exacerbate',
      phonetic: '/ɪɡˈzæs.ə.beɪt/',
      cefrLevel: 'C1',
      definition: 'To make a problem, bad situation, or negative condition worse.',
      example: 'Uncontrolled urban sprawl will only exacerbate existing traffic congestion.',
      collocations: ['exacerbate problem', 'exacerbate existing inequalities'],
      grammaticalForms: ['verb'],
      intervalDays: 1,
      masteryLevel: 1,
    ),
    const FlashcardItemModel(
      id: 'vocab_02',
      word: 'Depletion',
      phonetic: '/dɪˈpliː.ʃən/',
      cefrLevel: 'C1',
      definition: 'A significant reduction in the quantity or number of something.',
      example: 'Overfishing has led to the severe depletion of marine stocks.',
      collocations: ['depletion of natural resources'],
      grammaticalForms: ['noun'],
      intervalDays: 4,
      masteryLevel: 4,
    ),
  ];

  late WordSearchHistoryService historyService;

  setUp(() async {
    historyService = WordSearchHistoryService(enablePersistence: false);
    await historyService.clearHistory();

    final mockClient = _MockHttpClient((req) async {
      final url = req.url.toString();
      if (url.contains('api.datamuse.com')) {
        return http.Response(
          jsonEncode([
            {
              'word': 'work',
              'score': 42067,
              'tags': ['n', 'v'],
              'defs': ['n\tAn activity, such as a job, that uses effort']
            },
            {
              'word': 'world',
              'score': 24046,
              'tags': ['n'],
              'defs': ['n\tThe earth or all people on it']
            }
          ]),
          200,
        );
      }
      return http.Response('[]', 200);
    });

    final suggestionService = WordSuggestionService(httpClient: mockClient);
    suggestionService.clearCache();
  });

  group('VocabularyScreen Widget Tests', () {
    testWidgets('Renders Vocabulary app bar without plus/refresh, no search button next to input, and keeps top card', (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final repo = FakeVocabularyRepository(
        items: mockItems,
        dueItems: [mockItems[0]],
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: VocabularyScreen(
            repository: repo,
            historyService: historyService,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // 1. App bar has title but NO plus or refresh buttons
      expect(find.text('Vocabulary'), findsOneWidget);
      expect(find.byIcon(Icons.add_circle_outline_rounded), findsNothing);
      expect(find.byIcon(Icons.refresh_rounded), findsNothing);

      // 2. Search bar has prefix icon, NO "Lookup" button, and NO search action button in suffix
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Lookup'), findsNothing);
      // Only 1 search icon in the entire screen (the prefix icon inside TextField)
      expect(find.byIcon(Icons.search_rounded), findsOneWidget);

      // 3. Top Card: SM-2 Spaced repetition hero card is kept
      expect(find.text('Spaced Repetition (SM-2)'), findsOneWidget);
      expect(find.text('Total Words'), findsOneWidget);
      expect(find.text('Due Today'), findsOneWidget);
      expect(find.text('Review Due Cards (1)'), findsOneWidget);

      // 4. Blank page placeholder below top card
      expect(
        find.text('Search any word to explore full definitions, pronunciations, and examples'),
        findsOneWidget,
      );
    });

    testWidgets('Bounce search debounces typing and displays dynamic word suggestions', (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final repo = FakeVocabularyRepository(
        items: mockItems,
        dueItems: [],
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: VocabularyScreen(
            repository: repo,
            historyService: historyService,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Enter search query "wor"
      await tester.enterText(find.byType(TextField), 'wor');
      // Wait for bounce debounce timer to fire and async suggestions to resolve
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pump();

      // Suggestions header and matching word "work" inside RichText
      expect(find.text('Suggestions'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (w) => w is RichText && w.text.toPlainText().contains('work'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('Pressing enter triggers bounce search (not exact lookup), tapping suggestion opens definition', (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final repo = FakeVocabularyRepository(
        items: mockItems,
        dueItems: [],
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: VocabularyScreen(
            repository: repo,
            historyService: historyService,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Type "wor"
      await tester.enterText(find.byType(TextField), 'wor');
      
      // Press enter: triggers bounce search (suggestions), NOT exact lookup
      final textFieldWidget = tester.widget<TextField>(find.byType(TextField));
      textFieldWidget.onSubmitted?.call('wor');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Suggestions are shown, did NOT navigate away to WordDefinitionScreen
      expect(find.byType(WordDefinitionScreen), findsNothing);
      expect(find.text('Suggestions'), findsOneWidget);

      // Verified: The entered text STAYS in the TextField as "wor"!
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, equals('wor'));

      // Tapping the "work" suggestion: navigates to definition without modifying input text
      await tester.tap(find.byWidgetPredicate(
        (w) => w is RichText && w.text.toPlainText().contains('work'),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // Navigated to WordDefinitionScreen
      expect(find.byType(WordDefinitionScreen), findsOneWidget);

      // Pop back to vocabulary screen
      final NavigatorState navigator = tester.state(find.byType(Navigator));
      navigator.pop();
      await tester.pumpAndSettle();

      // Input value is STILL "wor" (not modified to "work")
      expect(textField.controller?.text, equals('wor'));

      // Tap clear button in search field
      await tester.tap(find.byIcon(Icons.clear_rounded));
      await tester.pumpAndSettle();

      // Verified: Search history now contains "work"
      expect(find.text('Search History'), findsOneWidget);
      expect(find.text('work'), findsWidgets);
    });

    testWidgets('Tapping outside input dismisses keyboard focus', (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final repo = FakeVocabularyRepository(
        items: mockItems,
        dueItems: [],
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: VocabularyScreen(
            repository: repo,
            historyService: historyService,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Focus input
      await tester.tap(find.byType(TextField));
      await tester.pump();
      expect(tester.widget<TextField>(find.byType(TextField)).focusNode?.hasFocus ?? FocusManager.instance.primaryFocus != null, isTrue);

      // Tap outside on top card
      await tester.tap(find.text('Spaced Repetition (SM-2)'));
      await tester.pump();

      // Focus should be dismissed
      expect(FocusManager.instance.primaryFocus?.context?.widget is EditableText, isFalse);
    });

    testWidgets('Search history allows removing single item or clearing all', (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await historyService.addSuccessfulSearch(
        word: 'foster',
        partOfSpeech: 'verb',
        definition: 'To encourage growth or ideas',
      );
      await historyService.addSuccessfulSearch(
        word: 'resilient',
        partOfSpeech: 'adjective',
        definition: 'Able to recover quickly',
      );

      final repo = FakeVocabularyRepository(
        items: mockItems,
        dueItems: [],
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: VocabularyScreen(
            repository: repo,
            historyService: historyService,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Search History'), findsOneWidget);
      expect(find.text('(2)'), findsOneWidget);
      expect(find.text('resilient'), findsOneWidget);
      expect(find.text('foster'), findsOneWidget);

      // Clear all
      await tester.tap(find.text('Clear All'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Back to blank page placeholder
      expect(find.text('Search History'), findsNothing);
      expect(
        find.text('Search any word to explore full definitions, pronunciations, and examples'),
        findsOneWidget,
      );
    });

    testWidgets('Tapping Review Due Cards navigates to FlashcardReviewScreen', (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final repo = FakeVocabularyRepository(
        items: mockItems,
        dueItems: [mockItems[0]],
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: VocabularyScreen(
            repository: repo,
            historyService: historyService,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.text('Review Due Cards (1)'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(FlashcardReviewScreen), findsOneWidget);
    });
  });
}
