import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_english/features/grammar/domain/entities/grammar_evaluation.dart';
import 'package:easy_english/features/grammar/domain/entities/grammar_mistake_record.dart';
import 'package:easy_english/features/grammar/domain/entities/grammar_topic.dart';
import 'package:easy_english/features/grammar/domain/repositories/grammar_repository.dart';
import 'package:easy_english/features/grammar/domain/usecases/evaluate_grammar.dart';
import 'package:easy_english/features/sentence_builder/presentation/providers/sentence_builder_provider.dart';
import 'package:easy_english/features/sentence_builder/presentation/screens/sentence_builder_screen.dart';
import 'package:easy_english/features/sentence_builder/presentation/widgets/evaluation_result_card.dart';
import 'package:easy_english/features/sentence_builder/presentation/widgets/sentence_input_field.dart';
import 'package:easy_english/features/sentence_builder/presentation/widgets/target_word_card.dart';

class FakeGrammarRepository implements GrammarRepository {
  final bool shouldFail;
  final GrammarEvaluation? evaluationToReturn;

  FakeGrammarRepository({this.shouldFail = false, this.evaluationToReturn});

  @override
  Future<GrammarEvaluation> evaluateGrammar({
    required String sentence,
    String? targetWord,
  }) async {
    if (shouldFail) {
      throw Exception('Network timeout during evaluation');
    }
    return evaluationToReturn ??
        const GrammarEvaluation(
          isCorrect: true,
          explanation: 'Excellent use of the target word in academic context.',
          correctedSentence: 'Foster academic innovation.',
        );
  }

  @override
  Future<List<GrammarTopic>> getGrammarRoadmap() async => [];

  @override
  Future<List<GrammarMistakeRecord>> getGrammarMistakes() async => [];
}

void main() {
  group('SentenceBuilderProvider Tests', () {
    test('Initial state with defaults', () {
      final provider = SentenceBuilderProvider();
      expect(provider.targetWord, 'Foster');
      expect(provider.promptInstructions, contains('Foster'));
      expect(provider.isEvaluating, false);
      expect(provider.evaluation, null);
      expect(provider.errorMessage, null);
    });

    test('Initial state with custom parameters', () {
      final provider = SentenceBuilderProvider(
        initialWord: 'Paramount',
        initialPrompt: 'Write a sentence with Paramount.',
      );
      expect(provider.targetWord, 'Paramount');
      expect(provider.promptInstructions, 'Write a sentence with Paramount.');
    });

    test('Empty sentence submission returns null', () async {
      final provider = SentenceBuilderProvider();
      final result = await provider.submitSentence('   ');
      expect(result, null);
      expect(provider.isEvaluating, false);
      expect(provider.evaluation, null);
    });

    test(
      'Successful sentence evaluation via EvaluateGrammar usecase',
      () async {
        final repository = FakeGrammarRepository(
          evaluationToReturn: const GrammarEvaluation(
            isCorrect: true,
            explanation: 'Great sentence structure.',
            correctedSentence: 'It is paramount to foster education.',
          ),
        );
        final evaluateGrammar = EvaluateGrammar(repository: repository);
        final provider = SentenceBuilderProvider(
          evaluateGrammar: evaluateGrammar,
        );

        final result = await provider.submitSentence(
          'It is necessary to foster growth in local communities.',
        );

        expect(result, isNotNull);
        expect(result!.isCorrect, true);
        expect(result.feedback, 'Great sentence structure.');
        expect(provider.evaluation, isNotNull);
        expect(provider.evaluation!.isCorrect, true);
        expect(provider.isEvaluating, false);
        expect(provider.errorMessage, null);
      },
    );

    test('Failed sentence evaluation sets error message', () async {
      final repository = FakeGrammarRepository(shouldFail: true);
      final evaluateGrammar = EvaluateGrammar(repository: repository);
      final provider = SentenceBuilderProvider(
        evaluateGrammar: evaluateGrammar,
      );

      final result = await provider.submitSentence('Some invalid sentence');

      expect(result, null);
      expect(provider.evaluation, null);
      expect(provider.isEvaluating, false);
      expect(provider.errorMessage, 'Network timeout during evaluation');

      provider.clearError();
      expect(provider.errorMessage, null);
    });
  });

  group('SentenceBuilder Widget Tests', () {
    testWidgets('TargetWordCard displays word and instructions', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TargetWordCard(
              targetWord: 'Elucidate',
              promptInstructions: 'Elucidate your argument clearly.',
            ),
          ),
        ),
      );

      expect(find.text('Elucidate'), findsOneWidget);
      expect(find.text('Target Word'), findsOneWidget);
      expect(find.text('Elucidate your argument clearly.'), findsOneWidget);
    });

    testWidgets('SentenceInputField renders text field and button', (
      WidgetTester tester,
    ) async {
      final controller = TextEditingController();
      bool submitted = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SentenceInputField(
              controller: controller,
              targetWord: 'Foster',
              isEvaluating: false,
              onSubmit: () => submitted = true,
            ),
          ),
        ),
      );

      expect(find.text('Your Sentence:'), findsOneWidget);
      expect(find.text('Submit & Evaluate'), findsOneWidget);

      await tester.enterText(
        find.byType(TextField),
        'We should foster creativity.',
      );
      await tester.tap(find.text('Submit & Evaluate'));
      await tester.pump();

      expect(submitted, true);
      expect(controller.text, 'We should foster creativity.');
    });

    testWidgets('EvaluationResultCard renders evaluation details', (
      WidgetTester tester,
    ) async {
      const evaluation = GrammarEvaluation(
        isCorrect: false,
        explanation: 'Minor grammar issues detected.',
        correctedSentence: 'Use passive voice here.',
        suggestedExercises: ['Growth was fostered by policies.'],
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: EvaluationResultCard(evaluation: evaluation)),
        ),
      );

      expect(find.text('Needs Improvement'), findsOneWidget);
      expect(find.text('Minor grammar issues detected.'), findsOneWidget);
      expect(find.text('Corrections:'), findsOneWidget);
      expect(find.text('Use passive voice here.'), findsOneWidget);
      expect(find.text('Model Expressions:'), findsOneWidget);
      expect(find.text('Growth was fostered by policies.'), findsOneWidget);
    });

    testWidgets(
      'SentenceBuilderScreen renders full layout and handles interaction',
      (WidgetTester tester) async {
        final repository = FakeGrammarRepository();
        final evaluateGrammar = EvaluateGrammar(repository: repository);

        await tester.pumpWidget(
          MaterialApp(
            home: SentenceBuilderScreen(
              initialWord: 'Foster',
              evaluateGrammar: evaluateGrammar,
            ),
          ),
        );

        expect(find.text('Sentence Builder'), findsOneWidget);
        expect(find.text('Foster'), findsOneWidget);
        expect(find.text('Submit & Evaluate'), findsOneWidget);

        await tester.enterText(
          find.byType(TextField),
          'Governments must foster economic stability.',
        );
        await tester.tap(find.text('Submit & Evaluate'));
        await tester.pumpAndSettle();

        expect(find.text('Excellent Sentence'), findsOneWidget);
        expect(
          find.text('Excellent use of the target word in academic context.'),
          findsOneWidget,
        );
      },
    );
  });
}
