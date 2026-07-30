import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_english/core/theme/app_theme.dart';
import 'package:easy_english/features/grammar/domain/grammar_model.dart';
import 'package:easy_english/features/grammar/presentation/grammar_roadmap_screen.dart';
import 'package:easy_english/features/grammar/presentation/grammar_exercise_screen.dart';
import 'package:easy_english/features/grammar/presentation/grammar_mistakes_screen.dart';

void main() {
  group('Module 4: Grammar Domain Models Tests', () {
    test('GrammarTopic serialization & deserialization', () {
      final sampleTopics = GrammarSeedData.sampleTopics;
      expect(sampleTopics.isNotEmpty, isTrue);

      final topic = sampleTopics.first;
      final jsonMap = topic.toJson();

      expect(jsonMap['id'], equals('topic_articles'));
      expect(jsonMap['cefr_level'], equals('B1'));
      expect(jsonMap['mastery_percentage'], equals(100.0));

      final restored = GrammarTopic.fromJson(jsonMap);
      expect(restored.id, equals(topic.id));
      expect(restored.title, equals(topic.title));
      expect(restored.rules.length, equals(topic.rules.length));
      expect(restored.exercises.length, equals(topic.exercises.length));
    });

    test('GrammarMistakeRecord copyWith and status check', () {
      final mistakes = GrammarSeedData.sampleMistakes;
      expect(mistakes.isNotEmpty, isTrue);

      final m = mistakes.first;
      expect(m.isResolved, isFalse);

      final resolved = m.copyWith(isResolved: true, occurrenceCount: m.occurrenceCount + 1);
      expect(resolved.isResolved, isTrue);
      expect(resolved.occurrenceCount, equals(5));
    });
  });

  group('Module 4: Grammar UI Screens Widget Tests', () {
    testWidgets('GrammarRoadmapScreen renders header, topic nodes, and cards cleanly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const GrammarRoadmapScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Grammar Roadmap'), findsOneWidget);
      expect(find.text('Overall Grammar Mastery'), findsOneWidget);
      expect(find.text('Visual Topic Progression'), findsOneWidget);
      expect(find.textContaining('Articles'), findsWidgets);
    });

    testWidgets('GrammarExerciseScreen renders question, prompt, and options', (WidgetTester tester) async {
      final sampleTopic = GrammarSeedData.sampleTopics.first;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: GrammarExerciseScreen(topic: sampleTopic),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Question 1 of'), findsOneWidget);
      expect(find.text(sampleTopic.exercises.first.prompt), findsOneWidget);
      expect(find.text('The'), findsOneWidget);
    });

    testWidgets('GrammarMistakesScreen renders mistake log cards and filter chips', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const GrammarMistakesScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Grammar Mistake Tracker'), findsOneWidget);
      expect(find.text('Unresolved'), findsOneWidget);
      expect(find.textContaining('Occurred'), findsWidgets);
    });
  });
}
