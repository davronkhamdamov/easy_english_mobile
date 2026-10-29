import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:easy_english/core/theme/app_theme.dart';
import 'package:easy_english/design_system/components/interactive_text/ds_word_dropdown.dart';
import 'package:easy_english/design_system/components/interactive_text/word_lookup_info.dart';
import 'package:easy_english/features/word_bank/data/datasources/word_definition_service.dart';
import 'package:easy_english/features/word_bank/domain/entities/flashcard_item.dart';
import 'package:easy_english/features/word_bank/domain/entities/word_definition_entry.dart';
import 'package:easy_english/features/word_bank/presentation/screens/word_definition_screen.dart';
import 'package:easy_english/features/word_bank/presentation/widgets/word_bank_item_card.dart';

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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WordDefinitionService Unit Tests', () {
    test('Curated "work" entry contains UK/US phonetics and multiple meanings', () async {
      final service = WordDefinitionService();
      final entry = await service.getDefinition('work');

      expect(entry.word, 'work');
      expect(entry.partOfSpeech, 'noun');
      expect(entry.allPartsOfSpeech, containsAll(['noun', 'verb']));
      expect(entry.ukPhonetic, '/wɜːk/');
      expect(entry.usPhonetic, '/wɝːk/');
      expect(entry.ukAudioUrl, isNotNull);
      expect(entry.usAudioUrl, isNotNull);

      // Verify specific senses requested by user:
      // 1. work noun (ACTIVITY) A1 [ U ]
      final activitySense = entry.senses.firstWhere(
        (s) => s.guideWord == 'ACTIVITY',
      );
      expect(activitySense.partOfSpeech, 'noun');
      expect(activitySense.cefrLevel, 'A1');
      expect(activitySense.grammaticalCode, '[ U ]');
      expect(activitySense.definition, contains('physical or mental effort'));
      expect(activitySense.examples.any((e) => e.pattern == 'do work'), isTrue);
      expect(activitySense.examples.any((e) => e.pattern == 'hard work'), isTrue);

      // 2. work noun (PLACE) A1 [ U ]
      final placeSense = entry.senses.firstWhere(
        (s) => s.guideWord == 'PLACE',
      );
      expect(placeSense.partOfSpeech, 'noun');
      expect(placeSense.cefrLevel, 'A1');
      expect(placeSense.grammaticalCode, '[ U ]');
      expect(placeSense.definition, contains('place where a person goes'));
      expect(placeSense.examples.any((e) => e.pattern == 'to work'), isTrue);
      expect(placeSense.examples.any((e) => e.pattern == 'at work'), isTrue);

      // 3. work noun (CREATION) B2 [ C ]
      final creationSense = entry.senses.firstWhere(
        (s) => s.guideWord == 'CREATION',
      );
      expect(creationSense.partOfSpeech, 'noun');
      expect(creationSense.cefrLevel, 'B2');
      expect(creationSense.grammaticalCode, '[ C ]');
      expect(creationSense.definition, contains('something created as a result of effort'));
      expect(creationSense.examples.any((e) => e.pattern == 'work by'), isTrue);
      expect(creationSense.examples.any((e) => e.pattern == 'poetic works'), isTrue);

      // Verify collocations & idioms
      expect(entry.collocations, contains('hard work'));
      expect(entry.collocations, contains('at work'));
      expect(entry.idioms, contains('work like a charm'));
    });

    test('Parses API payload correctly into multi-sense entry with UK/US audio', () async {
      final mockClient = _MockHttpClient((req) async {
        const jsonStr = '''[
            {
              "word": "catalyst",
              "phonetics": [
                {"text": "/ˈkæt.əl.ɪst/", "audio": "https://api.example.com/catalyst-uk.mp3"},
                {"text": "/ˈkæt̬.əl.ɪst/", "audio": "https://api.example.com/catalyst-us.mp3"}
              ],
              "meanings": [
                {
                  "partOfSpeech": "noun",
                  "definitions": [
                    {
                      "definition": "A substance that speeds up a chemical reaction.",
                      "example": "Chlorine acts as a catalyst in ozone destruction."
                    },
                    {
                      "definition": "A person or thing that precipitates an event.",
                      "example": "The speech was the catalyst for massive economic reform."
                    }
                  ]
                }
              ]
            }
          ]''';
        return http.Response.bytes(utf8.encode(jsonStr), 200);
      });

      final service = WordDefinitionService(httpClient: mockClient);
      final entry = await service.getDefinition('catalyst');

      expect(entry.word, 'catalyst');
      expect(entry.partOfSpeech, 'noun');
      expect(entry.ukPhonetic, '/ˈkæt.əl.ɪst/');
      expect(entry.senses.length, 2);
      expect(entry.senses.first.definition, contains('chemical reaction'));
      expect(entry.senses.first.examples.first.sentence, contains('catalyst in ozone destruction'));
    });

    test('Fallback entry generated gracefully for unknown word', () async {
      final mockClient = _MockHttpClient((req) async => http.Response('[]', 404));
      final service = WordDefinitionService(httpClient: mockClient);

      final entry = await service.getDefinition('unknownxyz');
      expect(entry.word, 'unknownxyz');
      expect(entry.senses.isNotEmpty, isTrue);
    });

    test('formatPartOfSpeechShort converts parts of speech to concise learner dictionary abbreviations', () {
      expect(formatPartOfSpeechShort('verb'), 'v');
      expect(formatPartOfSpeechShort('noun'), 'n');
      expect(formatPartOfSpeechShort('adjective'), 'adj');
      expect(formatPartOfSpeechShort('adverb'), 'adv');
      expect(formatPartOfSpeechShort('preposition'), 'prep');
      expect(formatPartOfSpeechShort('conjunction'), 'conj');
      expect(formatPartOfSpeechShort('pronoun'), 'pron');
      expect(formatPartOfSpeechShort('interjection'), 'interj');
      expect(formatPartOfSpeechShort('phrasal verb'), 'phr v');
    });
  });

  group('WordDefinitionScreen Widget Tests', () {
    testWidgets('Renders full definition page for "work" with Cambridge style layout', (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const WordDefinitionScreen(word: 'work'),
        ),
      );
      await tester.pumpAndSettle();

      // Header components
      expect(find.text('work'), findsWidgets);
      expect(find.text('n • v'), findsOneWidget);
      expect(find.text('UK'), findsOneWidget);
      expect(find.text('/wɜːk/'), findsOneWidget);
      expect(find.text('US'), findsOneWidget);
      expect(find.text('/wɝːk/'), findsOneWidget);

      // Multiple meanings / sense titles with short POS
      expect(find.text('work n (ACTIVITY)'), findsOneWidget);
      expect(find.text('work n (PLACE)'), findsOneWidget);
      expect(find.text('work n (CREATION)'), findsOneWidget);

      // CEFR and grammar code badges
      expect(find.text('A1'), findsWidgets);
      expect(find.text('B2'), findsWidgets);
      expect(find.text('[ U ]'), findsWidgets);
      expect(find.text('[ C ]'), findsWidgets);

      // Examples with patterns
      expect(find.textContaining("I've got so much work to do."), findsOneWidget);
      expect(find.textContaining('Carrying heavy loads around all day is hard work.'), findsOneWidget);
      expect(find.textContaining('Do you have far to travel to work each day?'), findsOneWidget);
      expect(find.textContaining('The museum has many works by Picasso'), findsOneWidget);

      // Collocations card
      expect(find.text('IELTS Collocations & Phrases'), findsOneWidget);
      expect(find.text('hard work'), findsWidgets);

      // Actions in AppBar (practice and share buttons removed, bookmark kept)
      expect(find.byIcon(Icons.bookmark_add_outlined), findsOneWidget);
      expect(find.byIcon(Icons.style_outlined), findsNothing);
      expect(find.byIcon(Icons.share_outlined), findsNothing);
      expect(find.text('Save to Bank'), findsNothing);
      expect(find.text('Practice (SM-2)'), findsNothing);

      // Copy button next to the main word
      expect(find.byIcon(Icons.copy_rounded), findsOneWidget);
      await tester.tap(find.byIcon(Icons.copy_rounded));
      await tester.pump();
      expect(find.text('Definition copied to clipboard!'), findsOneWidget);
    });

    testWidgets('Part of speech filter chips switch between noun and verb senses', (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const WordDefinitionScreen(word: 'work'),
        ),
      );
      await tester.pumpAndSettle();

      // Tap 'v (2)' filter chip
      final verbChip = find.widgetWithText(ChoiceChip, 'v (2)');
      expect(verbChip, findsOneWidget);
      await tester.tap(verbChip);
      await tester.pumpAndSettle();

      // Noun senses should now be hidden
      expect(find.text('work n (ACTIVITY)'), findsNothing);
      // Verb senses should be visible
      expect(find.text('work v (EFFORT)'), findsOneWidget);
      expect(find.text('work v (OPERATE)'), findsOneWidget);
    });

    testWidgets('Tapping word in WordBankItemCard navigates to WordDefinitionScreen', (tester) async {
      const item = FlashcardItem(
        id: 'wb_1',
        word: 'work',
        phonetic: '/wɜːk/',
        cefrLevel: 'A1',
        definition: 'Activity involving effort.',
        example: 'Hard work pays off.',
        repetitionCount: 1,
        easinessFactor: 2.5,
        intervalDays: 1,
        masteryLevel: 1,
      );

      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WordBankItemCard(
              item: item,
              onTapWord: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('work'), findsOneWidget);
      await tester.tap(find.text('work'));
      expect(tapped, isTrue);
    });

    testWidgets('DSWordDropdownCard word title is clickable and invokes navigation callback', (tester) async {
      const info = WordLookupInfo(
        word: 'work',
        cleanWord: 'work',
        phonetic: '/wɜːk/',
        partOfSpeech: 'noun',
        cefrLevel: 'A1',
        definition: 'Activity involving mental or physical effort.',
      );

      bool closed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DSWordDropdownCard(
              info: info,
              onClose: () {
                closed = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('work'), findsOneWidget);
      await tester.tap(find.text('work'));
      expect(closed, isTrue);
    });

    testWidgets('WordDefinitionScreen renders without bottom bar buttons and no overflow on narrow 320px screen', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const WordDefinitionScreen(word: 'work'),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      // Bottom buttons removed
      expect(find.text('Save to Bank'), findsNothing);
      expect(find.text('Practice (SM-2)'), findsNothing);
      // App bar actions: bookmark kept, practice removed, share removed
      expect(find.byIcon(Icons.bookmark_add_outlined), findsOneWidget);
      expect(find.byIcon(Icons.style_outlined), findsNothing);
      expect(find.byIcon(Icons.share_outlined), findsNothing);
      // Copy button next to main word is rendered
      expect(find.byIcon(Icons.copy_rounded), findsOneWidget);
    });
  });
}
