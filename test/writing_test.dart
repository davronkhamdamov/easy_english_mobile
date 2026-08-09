import 'package:easy_english/features/writing/data/models/writing_evaluation_model.dart';
import 'package:easy_english/features/writing/data/models/writing_prompt_model.dart';
import 'package:easy_english/features/writing/data/models/writing_submission_model.dart';
import 'package:easy_english/features/writing/domain/entities/writing_evaluation.dart';
import 'package:easy_english/features/writing/domain/entities/writing_prompt.dart';
import 'package:easy_english/features/writing/domain/entities/writing_submission.dart';
import 'package:easy_english/features/writing/domain/usecases/evaluate_writing.dart';
import 'package:easy_english/features/writing/domain/usecases/fetch_writing_prompts.dart';
import 'package:easy_english/features/writing/presentation/providers/writing_provider.dart';
import 'package:easy_english/features/writing/presentation/screens/writing_screen.dart';
import 'package:easy_english/features/writing/presentation/widgets/writing_editor.dart';
import 'package:easy_english/features/writing/presentation/widgets/writing_evaluation_widget.dart';
import 'package:easy_english/features/writing/presentation/widgets/writing_prompt_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Writing Feature Domain & Data Unit Tests', () {
    test('WritingPrompt entity defaultPrompts and copyWith', () {
      const task1 = WritingPrompt.defaultTask1Prompt;
      const task2 = WritingPrompt.defaultTask2Prompt;

      expect(task1.taskType, equals(1));
      expect(task2.taskType, equals(2));
      expect(task1.suggestedWordCount, equals(150));
      expect(task2.suggestedWordCount, equals(250));

      final updatedTask = task2.copyWith(title: 'Updated Task 2 Title');
      expect(updatedTask.title, equals('Updated Task 2 Title'));
      expect(updatedTask.id, equals(task2.id));
    });

    test('WritingEvaluation entity copyWith', () {
      const eval = WritingEvaluation(
        overallBandScore: 7.0,
        taskAchievementScore: 7.0,
        coherenceCohesionScore: 7.0,
        lexicalResourceScore: 7.0,
        grammaticalRangeScore: 7.0,
        strengths: ['Good paragraphing'],
        weaknesses: ['Minor spelling errors'],
        grammarCorrections: ['Use comma before conjunction'],
        improvedSample: 'Sample improved essay...',
      );

      final copy = eval.copyWith(overallBandScore: 7.5);
      expect(copy.overallBandScore, equals(7.5));
      expect(copy.strengths.first, equals('Good paragraphing'));
    });

    test('WritingSubmission entity instantiation', () {
      const sub = WritingSubmission(
        essayText: 'This is my essay.',
        prompt: 'Discuss both views.',
        taskType: 'task2',
      );
      expect(sub.essayText, equals('This is my essay.'));
      expect(sub.taskType, equals('task2'));
    });

    test('WritingEvaluationModel JSON roundtrip and toEntity', () {
      final json = {
        'overall_band': 7.5,
        'task_achievement_band': 8.0,
        'coherence_cohesion_band': 7.5,
        'lexical_resource_band': 7.0,
        'grammar_accuracy_band': 7.5,
        'strengths': ['Strong argument structure'],
        'weaknesses': ['Limited advanced vocabulary'],
        'grammar_corrections': ['Corrected error in paragraph 2'],
        'improved_sample': 'An improved model response here.',
      };

      final model = WritingEvaluationModel.fromJson(json);
      expect(model.overallBandScore, equals(7.5));
      expect(model.taskAchievementScore, equals(8.0));

      final entity = model.toEntity();
      expect(entity.overallBandScore, equals(7.5));
      expect(entity.taskAchievementScore, equals(8.0));
      expect(entity.strengths.first, equals('Strong argument structure'));
      expect(entity.improvedSample, equals('An improved model response here.'));

      final jsonOut = model.toJson();
      expect(jsonOut['overall_band'], equals(7.5));
    });

    test('WritingPromptModel JSON roundtrip and toEntity', () {
      final json = {
        'id': 'wp_001',
        'task_type': 2,
        'title': 'Task 2 Essay',
        'prompt_text': 'Discuss advantages and disadvantages.',
        'suggested_word_count': 250,
      };

      final model = WritingPromptModel.fromJson(json);
      expect(model.id, equals('wp_001'));
      expect(model.taskType, equals(2));

      final entity = model.toEntity();
      expect(entity.id, equals('wp_001'));
      expect(
        entity.promptText,
        equals('Discuss advantages and disadvantages.'),
      );
    });

    test('WritingSubmissionModel JSON roundtrip and toEntity', () {
      final json = {
        'essay_text': 'In modern society...',
        'prompt': 'Education debate',
        'task_type': 'task2',
      };

      final model = WritingSubmissionModel.fromJson(json);
      expect(model.essayText, equals('In modern society...'));

      final entity = model.toEntity();
      expect(entity.prompt, equals('Education debate'));
    });
  });

  group('Writing Feature Use Cases Unit Tests', () {
    test('EvaluateWriting and FetchWritingPrompts instantiate cleanly', () {
      final evaluateWriting = EvaluateWriting();
      final fetchPrompts = FetchWritingPrompts();

      expect(evaluateWriting, isNotNull);
      expect(fetchPrompts, isNotNull);
    });
  });

  group('Writing Feature Provider Unit Tests', () {
    test(
      'WritingProvider initializes with defaults and handles task switching',
      () {
        final provider = WritingProvider();

        expect(provider.selectedTask, equals(2));
        expect(provider.isEvaluating, isFalse);
        expect(provider.evaluationResult, isNull);
        expect(provider.prompts.length, equals(2));

        provider.selectTask(1);
        expect(provider.selectedTask, equals(1));
      },
    );
  });

  group('Writing Feature Presentation UI Widget Tests', () {
    testWidgets(
      'WritingScreen renders header, task switcher, prompt card, editor, and evaluate button',
      (WidgetTester tester) async {
        await tester.pumpWidget(const MaterialApp(home: WritingScreen()));
        await tester.pump();

        expect(find.text('IELTS Writing Practice'), findsOneWidget);
        expect(find.text('Task 1 (Graph/Diagram)'), findsOneWidget);
        expect(find.text('Task 2 (Essay)'), findsOneWidget);
        expect(find.byType(WritingPromptCard), findsOneWidget);
        expect(find.byType(WritingEditor), findsOneWidget);
        expect(find.text('Evaluate Essay with AI'), findsOneWidget);
      },
    );

    testWidgets('WritingEvaluationWidget renders band score feedback', (
      WidgetTester tester,
    ) async {
      const sampleEval = WritingEvaluation(
        overallBandScore: 7.5,
        taskAchievementScore: 7.5,
        coherenceCohesionScore: 7.5,
        lexicalResourceScore: 7.5,
        grammaticalRangeScore: 7.5,
        strengths: ['Clear structure and progression'],
        weaknesses: ['Use more varied collocations'],
        grammarCorrections: ['Fix subject-verb agreement in sentence 3'],
        improvedSample: 'Here is a band 9 model essay answer.',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: WritingEvaluationWidget(evaluation: sampleEval)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('AI Evaluation Feedback'), findsOneWidget);
      expect(find.text('Strengths:'), findsOneWidget);
      expect(find.text('Clear structure and progression'), findsOneWidget);
      expect(find.text('Areas for Improvement:'), findsOneWidget);
      expect(find.text('Use more varied collocations'), findsOneWidget);
      expect(find.text('Grammar Corrections:'), findsOneWidget);
      expect(
        find.text('Fix subject-verb agreement in sentence 3'),
        findsOneWidget,
      );
      expect(find.text('Improved Model Sample:'), findsOneWidget);
      expect(find.text('Here is a band 9 model essay answer.'), findsOneWidget);
    });
  });
}
