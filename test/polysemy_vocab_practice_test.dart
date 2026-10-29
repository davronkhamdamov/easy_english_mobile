import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_english/features/practice/data/datasources/polysemy_vocab_data.dart';
import 'package:easy_english/features/practice/domain/entities/polysemy_vocab_item.dart';
import 'package:easy_english/features/practice/presentation/screens/polysemy_category_screen.dart';
import 'package:easy_english/features/practice/presentation/screens/vocab_context_quiz_screen.dart';
import 'package:easy_english/features/practice/presentation/widgets/polysemy_featured_banner_widget.dart';
import 'package:easy_english/features/practice/presentation/widgets/vocab_option_tile.dart';

void main() {
  group('IELTS Polysemy Vocabulary Data Tests', () {
    test('Top 100 and Top 200 categories exist and are configured', () {
      final categories = PolysemyVocabData.allCategories;
      expect(categories.length, greaterThanOrEqualTo(2));

      final cat100 = PolysemyVocabData.getCategoryById('ielts_100');
      expect(cat100, isNotNull);
      expect(cat100!.title, contains('Top 100'));
      expect(cat100.sets.isNotEmpty, isTrue);

      final cat200 = PolysemyVocabData.getCategoryById('ielts_200');
      expect(cat200, isNotNull);
      expect(cat200!.title, contains('Top 200'));
      expect(cat200.sets.isNotEmpty, isTrue);
    });

    test('All vocabulary items have valid multi-meaning senses and questions', () {
      final allItems = PolysemyVocabData.allCategories
          .expand((c) => c.sets)
          .expand((s) => s.items)
          .toSet();

      for (final item in allItems) {
        expect(item.word.isNotEmpty, isTrue);
        expect(item.phonetic.isNotEmpty, isTrue);
        // Every polysemous word must have at least 2 distinct senses
        expect(item.senses.length, greaterThanOrEqualTo(2),
            reason: '${item.word} must have multiple senses');

        for (final question in item.questions) {
          expect(question.contextSentence.isNotEmpty, isTrue);
          expect(question.highlightedWord.isNotEmpty, isTrue);
          expect(question.options.length, equals(4),
              reason: '${item.word} question must have 4 multiple choice options');
          expect(question.correctOptionIndex, inInclusiveRange(0, 3));
          expect(question.targetSenseIndex,
              inInclusiveRange(0, item.senses.length - 1));
          expect(question.explanation.isNotEmpty, isTrue);
        }
      }
    });
  });

  group('VocabContextQuizScreen Widget Tests', () {
    testWidgets('Renders question context and allows answer selection',
        (WidgetTester tester) async {
      final testItems = PolysemyVocabData.set1.items.take(2).toList();

      await tester.pumpWidget(
        MaterialApp(
          home: VocabContextQuizScreen(
            title: 'Test Set',
            items: testItems,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check target word and question prompt
      expect(find.text(testItems.first.word), findsWidgets);
      expect(find.byType(VocabOptionTile), findsNWidgets(4));

      // Select an option (tap option A / index 0)
      await tester.tap(find.byType(VocabOptionTile).first);
      await tester.pumpAndSettle();

      // Next button or feedback explanation should be visible
      final nextFinder = find.text('Next Word →');
      expect(nextFinder, findsOneWidget);
      await tester.ensureVisible(nextFinder);
      await tester.pumpAndSettle();

      // Tap Next Question
      await tester.tap(nextFinder);
      await tester.pumpAndSettle();

      // Now on second question
      expect(find.text(testItems[1].word), findsWidgets);
      expect(find.byType(VocabOptionTile), findsNWidgets(4));

      // Answer second question
      await tester.tap(find.byType(VocabOptionTile).at(1));
      await tester.pumpAndSettle();

      // Now button should say "See Results"
      final resultsFinder = find.text('See Results');
      expect(resultsFinder, findsOneWidget);
      await tester.ensureVisible(resultsFinder);
      await tester.pumpAndSettle();

      await tester.tap(resultsFinder);
      await tester.pumpAndSettle();

      // Results summary should be visible
      expect(find.text('Practice Complete!'), findsOneWidget);
      expect(find.text('Lexical Resource'), findsOneWidget);
    });

    testWidgets('PolysemyFeaturedBannerWidget displays categories and navigates',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PolysemyFeaturedBannerWidget(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Multi-Meaning Academic Words'), findsOneWidget);
      expect(find.text('Top 100 Words'), findsOneWidget);
      expect(find.text('Top 200 Academic'), findsOneWidget);

      // Tap Top 100 Words
      await tester.tap(find.text('Top 100 Words'));
      await tester.pumpAndSettle();

      // Should open PolysemyCategoryScreen
      expect(find.byType(PolysemyCategoryScreen), findsOneWidget);
      expect(find.text('Top 100 Multi-Meaning Words'), findsWidgets);
    });
  });
}
