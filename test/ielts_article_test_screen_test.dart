import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_english/features/text_lab/data/ielts_article_test_data.dart';
import 'package:easy_english/features/text_lab/domain/entities/ielts_test_models.dart';
import 'package:easy_english/features/text_lab/presentation/screens/ielts_article_test_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('IELTS Test Models & Presets Unit Tests', () {
    test('Presets contain all standard IELTS question types', () {
      final test = IeltsArticleTestPresets.urbanCanopyTest;
      expect(test.title, contains('The Urban Canopy'));
      expect(test.cefrLevel, equals('C1 Academic'));
      expect(test.questions, isNotEmpty);

      final questionTypes = test.questions.map((q) => q.type).toSet();
      expect(questionTypes.contains(IeltsQuestionType.matchingHeadings), isTrue);
      expect(questionTypes.contains(IeltsQuestionType.trueFalseNotGiven), isTrue);
      expect(questionTypes.contains(IeltsQuestionType.multipleChoiceSingle), isTrue);
      expect(questionTypes.contains(IeltsQuestionType.multipleChoiceMulti), isTrue);
      expect(questionTypes.contains(IeltsQuestionType.fillInTheBlank), isTrue);
      expect(questionTypes.contains(IeltsQuestionType.matchingFeatures), isTrue);
      expect(questionTypes.contains(IeltsQuestionType.shortAnswer), isTrue);
    });

    test('Total questions count calculates correctly across grouped questions', () {
      final test = IeltsArticleTestPresets.urbanCanopyTest;
      expect(test.totalQuestionsCount, greaterThanOrEqualTo(14));
    });
  });

  group('IeltsArticleTestScreen Widget & Interaction Tests', () {
    testWidgets('Renders Reading Passage with article header and markdown content', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: IeltsArticleTestScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('IELTS Reading Test Lab'), findsOneWidget);
      expect(find.text('The Urban Canopy: Vertical Forests and Biophilic Architecture'), findsWidgets);
      expect(find.text('C1 Academic'), findsWidgets);
      expect(find.text('Reading Passage'), findsOneWidget);
      expect(find.byIcon(Icons.quiz_rounded), findsWidgets);
    });

    testWidgets('Switches to Questions Tab and renders all question formats', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: IeltsArticleTestScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Switch to Questions tab via TabBar icon
      await tester.tap(find.byIcon(Icons.quiz_rounded).first);
      await tester.pumpAndSettle();

      expect(find.text('Questions Overview'), findsOneWidget);
      expect(find.text('Matching Headings'), findsWidgets);
      expect(find.text('True / False / Not Given'), findsWidgets);
      expect(find.text('Multiple Choice'), findsWidgets);
      expect(find.text('Sentence Completion'), findsWidgets);
      expect(find.text('Matching Features'), findsWidgets);
      expect(find.text('Short Answer'), findsWidgets);
    });

    testWidgets('Answering question and submitting opens score summary modal', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: IeltsArticleTestScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Switch to Questions tab
      await tester.tap(find.byIcon(Icons.quiz_rounded).first);
      // Tap Submit IELTS Test button in bottom action bar directly
      await tester.tap(find.text('Submit IELTS Test'));
      await tester.pumpAndSettle();

      expect(find.text('Submit IELTS Reading Test?'), findsOneWidget);

      // Confirm submit
      await tester.tap(find.text('Submit & Score'));
      await tester.pumpAndSettle();

      // Verify Band score modal appears
      expect(find.textContaining('IELTS BAND ESTIMATE:'), findsOneWidget);
      expect(find.text('Review Answers'), findsOneWidget);
    });
  });
}
