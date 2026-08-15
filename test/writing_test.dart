import 'package:easy_english/features/writing/data/models/writing_evaluation_model.dart';
import 'package:easy_english/features/writing/data/models/writing_prompt_model.dart';
import 'package:easy_english/features/writing/data/models/writing_submission_model.dart';
import 'package:easy_english/features/writing/domain/entities/writing_evaluation.dart';
import 'package:easy_english/features/writing/domain/entities/writing_prompt.dart';
import 'package:easy_english/features/writing/domain/entities/writing_submission.dart';
import 'package:easy_english/features/writing/domain/usecases/evaluate_writing.dart';
import 'package:easy_english/features/writing/domain/usecases/fetch_writing_prompts.dart';
import 'package:easy_english/features/writing/domain/usecases/get_writing_prompts_usecase.dart';
import 'package:easy_english/features/writing/presentation/providers/writing_provider.dart';
import 'package:easy_english/features/writing/presentation/screens/writing_screen.dart';
import 'package:easy_english/features/writing/presentation/widgets/writing_editor.dart';
import 'package:easy_english/features/writing/presentation/widgets/writing_evaluation_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeGetWritingPromptsUseCase extends GetWritingPromptsUseCase {
  @override
  Future<List<WritingPrompt>> call({String? taskType}) async {
    final list = [
      const WritingPrompt(
        id: 'p_task1',
        taskType: 'task1',
        topic: 'Charts',
        title: 'Task 1 Graph',
        promptText: 'Summarise the info in graph.',
        minWordCount: 150,
        difficulty: 'Intermediate',
      ),
      const WritingPrompt(
        id: 'p_task2',
        taskType: 'task2',
        topic: 'Education',
        title: 'Task 2 Essay',
        promptText: 'Discuss both views.',
        minWordCount: 250,
        difficulty: 'Intermediate',
      ),
    ];
    if (taskType != null && taskType.isNotEmpty) {
      return list.where((p) => p.taskType == taskType).toList();
    }
    return list;
  }
}

void main() {
  group('Writing Feature Domain & Data Unit Tests', () {
    test('WritingPrompt entity getters and copyWith', () {
      const prompt = WritingPrompt(
        id: 'p_1',
        taskType: 'task2',
        topic: 'Education',
        title: 'Free University',
        promptText: 'Some people believe university should be free.',
        minWordCount: 250,
        difficulty: 'Intermediate',
      );

      expect(prompt.taskType, equals('task2'));
      expect(prompt.taskTypeInt, equals(2));
      expect(prompt.suggestedWordCount, equals(250));

      final updated = prompt.copyWith(title: 'Updated Title');
      expect(updated.title, equals('Updated Title'));
      expect(updated.id, equals('p_1'));
    });

    test('WritingEvaluation entity getters and copyWith', () {
      const eval = WritingEvaluation(
        id: 'eval_1',
        overallBandScore: 7.0,
        taskAchievement: WritingCriterionScore(
          score: 7.5,
          feedback: 'Good response to prompt.',
        ),
        coherenceCohesion: WritingCriterionScore(
          score: 7.0,
          feedback: 'Logical progression.',
        ),
        lexicalResource: WritingCriterionScore(
          score: 6.5,
          feedback: 'Adequate range.',
        ),
        grammaticalRange: WritingCriterionScore(
          score: 7.0,
          feedback: 'Good structures.',
        ),
        wordCount: 274,
        grammarCorrections: [
          GrammarCorrection(
            original: 'students needs to pay',
            corrected: 'students need to pay',
            explanation: 'Subject-verb agreement error.',
          ),
        ],
        vocabularySuggestions: [
          VocabularySuggestion(
            usedWord: 'good idea',
            suggestedAlternatives: ['beneficial strategy'],
          ),
        ],
        sampleAnswer: 'Higher education plays a pivotal role...',
      );

      expect(eval.overallBandScore, equals(7.0));
      expect(eval.taskAchievementScore, equals(7.5));
      expect(eval.improvedSample, equals('Higher education plays a pivotal role...'));

      final copy = eval.copyWith(overallBandScore: 7.5);
      expect(copy.overallBandScore, equals(7.5));
      expect(copy.grammarCorrections.first.original, equals('students needs to pay'));
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
        'id': 'eval_8832',
        'overall_band_score': 7.0,
        'criteria': {
          'task_achievement': {
            'score': 7.5,
            'feedback': 'Good response to all parts.',
          },
          'coherence_cohesion': {
            'score': 7.0,
            'feedback': 'Logical progression.',
          },
          'lexical_resource': {
            'score': 6.5,
            'feedback': 'Adequate vocabulary range.',
          },
          'grammatical_range': {
            'score': 7.0,
            'feedback': 'Good complex structures.',
          },
        },
        'word_count': 274,
        'grammar_corrections': [
          {
            'original': 'students needs to pay',
            'corrected': 'students need to pay',
            'explanation': "Subject-verb agreement error: 'students' is plural.",
          },
        ],
        'improved_vocabulary': [
          {
            'used_word': 'good idea',
            'suggested_alternatives': ['beneficial strategy', 'advantageous policy'],
          },
        ],
        'sample_band_9_answer': 'Higher education plays a pivotal role...',
      };

      final model = WritingEvaluationModel.fromJson(json);
      expect(model.overallBandScore, equals(7.0));
      expect(model.taskAchievementScore, equals(7.5));
      expect(model.wordCount, equals(274));
      expect(model.grammarCorrections.first.corrected, equals('students need to pay'));

      final entity = model.toEntity();
      expect(entity.overallBandScore, equals(7.0));
      expect(entity.taskAchievement.score, equals(7.5));
      expect(entity.sampleAnswer, equals('Higher education plays a pivotal role...'));

      final jsonOut = model.toJson();
      expect(jsonOut['overall_band_score'], equals(7.0));
    });

    test('WritingPromptModel JSON roundtrip and toEntity', () {
      final json = {
        'id': 'prompt_101',
        'task_type': 'task2',
        'topic': 'Education',
        'title': 'Free University Education',
        'prompt_text': 'Some people believe university should be free...',
        'min_word_count': 250,
        'difficulty': 'Intermediate',
      };

      final model = WritingPromptModel.fromJson(json);
      expect(model.id, equals('prompt_101'));
      expect(model.taskType, equals('task2'));
      expect(model.minWordCount, equals(250));

      final entity = model.toEntity();
      expect(entity.id, equals('prompt_101'));
      expect(entity.topic, equals('Education'));
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
        final provider = WritingProvider(
          getWritingPrompts: FakeGetWritingPromptsUseCase(),
        );

        expect(provider.selectedTask, equals(2));
        expect(provider.isEvaluating, isFalse);
        expect(provider.evaluationResult, isNull);

        provider.selectTask(1);
        expect(provider.selectedTask, equals(1));
        expect(provider.selectedTaskType, equals('task1'));
      },
    );
  });

  group('Writing Feature Presentation UI Widget Tests', () {
    testWidgets(
      'WritingScreen renders header, task switcher, prompt card area, editor, and evaluate button',
      (WidgetTester tester) async {
        final provider = WritingProvider(
          getWritingPrompts: FakeGetWritingPromptsUseCase(),
        );
        await tester.pumpWidget(MaterialApp(home: WritingScreen(provider: provider)));
        await tester.pumpAndSettle();

        expect(find.text('IELTS Writing Practice'), findsOneWidget);
        expect(find.text('Task 1 (Graph/Diagram)'), findsOneWidget);
        expect(find.text('Task 2 (Essay)'), findsOneWidget);
        expect(find.byType(WritingEditor), findsOneWidget);
        expect(find.text('Evaluate Essay with AI'), findsOneWidget);
      },
    );

    testWidgets('WritingEvaluationWidget renders band score feedback', (
      WidgetTester tester,
    ) async {
      const sampleEval = WritingEvaluation(
        id: 'eval_101',
        overallBandScore: 7.5,
        taskAchievement: WritingCriterionScore(
          score: 7.5,
          feedback: 'Clear structure and progression',
        ),
        coherenceCohesion: WritingCriterionScore(
          score: 7.5,
          feedback: 'Good paragraphing',
        ),
        lexicalResource: WritingCriterionScore(
          score: 7.0,
          feedback: 'Use more varied collocations',
        ),
        grammaticalRange: WritingCriterionScore(
          score: 7.5,
          feedback: 'Accurate complex sentences',
        ),
        wordCount: 260,
        grammarCorrections: [
          GrammarCorrection(
            original: 'students needs to pay',
            corrected: 'students need to pay',
            explanation: 'Subject-verb agreement error',
          ),
        ],
        vocabularySuggestions: [
          VocabularySuggestion(
            usedWord: 'good idea',
            suggestedAlternatives: ['beneficial policy'],
          ),
        ],
        sampleAnswer: 'Here is a band 9 model essay answer.',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: WritingEvaluationWidget(evaluation: sampleEval),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Overall IELTS Band Score'), findsOneWidget);
      expect(find.text('7.5'), findsOneWidget);
      expect(find.text('IELTS Criteria Breakdown'), findsOneWidget);
      expect(find.text('Task Achievement'), findsOneWidget);
      expect(find.text('Coherence & Cohesion'), findsOneWidget);
      expect(find.text('Lexical Resource'), findsOneWidget);
      expect(find.text('Grammatical Range'), findsOneWidget);

      // Open expansion tiles to verify content
      final grammarTile = find.textContaining('Grammar & Spelling Corrections');
      await tester.ensureVisible(grammarTile);
      await tester.tap(grammarTile);
      await tester.pumpAndSettle();
      expect(find.text('students needs to pay'), findsOneWidget);
      expect(find.text('students need to pay'), findsOneWidget);

      final sampleTile = find.textContaining('Band 9 Sample Model Answer');
      await tester.ensureVisible(sampleTile);
      await tester.tap(sampleTile);
      await tester.pumpAndSettle();
      expect(find.text('Here is a band 9 model essay answer.'), findsOneWidget);
    });
  });
}
