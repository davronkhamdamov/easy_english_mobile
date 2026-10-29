import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:easy_english/design_system/design_system.dart';
import 'package:easy_english/features/dashboard/presentation/screens/dashboard_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WordLookupDictionaryService Unit Tests', () {
    late WordLookupDictionaryService service;

    setUp(() {
      service = WordLookupDictionaryService();
    });

    test('Clean token strips punctuation and lowercases', () {
      expect(WordLookupDictionaryService.cleanToken('Dancing,'), equals('dancing'));
      expect(WordLookupDictionaryService.cleanToken('"Boundaries!"'), equals('boundaries'));
      expect(WordLookupDictionaryService.cleanToken('State-of-the-art'), equals('state-of-the-art'));
    });

    test('Open-Source API payload parsing integration', () async {
      final mockClient = http.Client();
      final apiService = WordLookupDictionaryService(httpClient: mockClient);
      final info = await apiService.lookupWord('serendipity');
      expect(info.word, equals('serendipity'));
      expect(info.definition, isNotEmpty);
      expect(info.audioUrl, isNotEmpty);
    });

    test('Handles non-dictionary terms gracefully with not-found state', () async {
      final mockClient = http.Client();
      final apiService = WordLookupDictionaryService(httpClient: mockClient);
      final info = await apiService.lookupWord('xyznonexistent123');
      expect(info.definition, contains('No dictionary definition found'));
    });

    test('Bookmark saving and toggling works', () {
      expect(service.isWordSaved('meticulous'), isFalse);
      service.toggleSaved('meticulous');
      expect(service.isWordSaved('meticulous'), isTrue);
      service.toggleSaved('meticulous');
      expect(service.isWordSaved('meticulous'), isFalse);
    });
  });

  group('DSInteractiveText Widget Tests', () {
    testWidgets('Renders all word tokens interactively', (WidgetTester tester) async {
      String? clickedWord;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DSInteractiveText(
              'Space exploration pushes boundaries.',
              onWordTap: (word) => clickedWord = word,
            ),
          ),
        ),
      );

      expect(find.text('Space'), findsOneWidget);
      expect(find.text('exploration'), findsOneWidget);
      expect(find.text('pushes'), findsOneWidget);
      expect(find.text('boundaries'), findsOneWidget);

      await tester.tap(find.text('exploration'));
      await tester.pumpAndSettle();

      expect(clickedWord, equals('exploration'));
      expect(find.byType(DSWordDropdownCard), findsOneWidget);

      // Dismiss popup
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();
    });

    testWidgets('Tapping close button dismisses dropdown popover', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DSInteractiveText('Meticulous research creates impact.'),
          ),
        ),
      );

      await tester.tap(find.text('Meticulous'));
      await tester.pumpAndSettle();

      expect(find.byType(DSWordDropdownCard), findsOneWidget);

      // Tap close icon
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(DSWordDropdownCard), findsNothing);
    });

    testWidgets('Highlights searched word via highlightQuery and mark tags while retaining clickability', (WidgetTester tester) async {
      String? tappedWord;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DSInteractiveText(
              'Dancing lights up the <mark>brain</mark> and transforms cognition.',
              highlightQuery: 'brain',
              onWordTap: (w) => tappedWord = w,
            ),
          ),
        ),
      );

      // <mark> tags should be stripped from rendered text
      expect(find.text('<mark>'), findsNothing);
      expect(find.text('brain'), findsOneWidget);

      // Tap the highlighted word
      await tester.tap(find.text('brain'));
      await tester.pumpAndSettle();

      expect(tappedWord, equals('brain'));
      expect(find.byType(DSWordDropdownCard), findsOneWidget);

      // Dismiss popup
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();
    });

    testWidgets('DSWordDropdownCard renders simple loading spinner and message when isLoading is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DSWordDropdownCard(
              isLoading: true,
              loadingWord: 'serendipity',
              onClose: () {},
            ),
          ),
        ),
      );

      expect(find.text('serendipity'), findsOneWidget);
      expect(find.text('Searching vocabulary & definitions...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });
  });

  group('InteractiveTextPlaygroundScreen & Navigation Tests', () {
    testWidgets('Playground screen switches presets and renders live sandbox', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: InteractiveTextPlaygroundScreen(),
          ),
        ),
      );

      expect(find.text('Interactive Text Lab'), findsOneWidget);
      expect(find.text('Curated Passages'), findsOneWidget);
      expect(find.text('Custom Sandbox'), findsOneWidget);

      // Switch to Custom Sandbox
      await tester.tap(find.text('Custom Sandbox'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('DashboardScreen includes Text Lab navigation tab', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DashboardScreen(initialIndex: 3),
        ),
      );

      expect(find.text('Text Lab'), findsWidgets);
      expect(find.byType(InteractiveTextPlaygroundScreen), findsOneWidget);
    });

    testWidgets('YouListen Subtitle segment renders interactive word tokens', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DSInteractiveText(
              'Dancing lights up the whole brain and transforms cognition.',
              highlightStyle: DSWordHighlightStyle.dottedUnderline,
            ),
          ),
        ),
      );

      expect(find.text('Dancing'), findsOneWidget);
      expect(find.text('brain'), findsOneWidget);
      expect(find.text('transforms'), findsOneWidget);

      await tester.tap(find.text('brain'));
      await tester.pumpAndSettle();

      expect(find.byType(DSWordDropdownCard), findsOneWidget);
      expect(find.text('brain'), findsWidgets);

      // Dismiss popup
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();
    });
  });
}
