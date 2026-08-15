import 'package:flutter_test/flutter_test.dart';
import 'package:easy_english/features/grammar/data/datasources/grammar_remote_datasource.dart';
import 'package:easy_english/features/grammar/data/models/grammar_evaluation_model.dart';
import 'package:easy_english/features/grammar/data/models/grammar_exercise_model.dart';
import 'package:easy_english/features/grammar/data/models/grammar_mistake_model.dart';
import 'package:easy_english/features/grammar/data/models/grammar_rule_model.dart';
import 'package:easy_english/features/grammar/data/models/grammar_topic_model.dart';
import 'package:easy_english/features/grammar/data/repositories/grammar_repository_impl.dart';
import 'package:easy_english/features/grammar/domain/entities/grammar_evaluation.dart';
import 'package:easy_english/features/grammar/domain/entities/grammar_exercise.dart';
import 'package:easy_english/features/grammar/domain/entities/grammar_mistake_record.dart';
import 'package:easy_english/features/grammar/domain/entities/grammar_rule.dart';
import 'package:easy_english/features/grammar/domain/entities/grammar_topic.dart';
import 'package:easy_english/features/grammar/domain/usecases/evaluate_grammar.dart';
import 'package:easy_english/features/grammar/domain/usecases/get_grammar_mistakes.dart';
import 'package:easy_english/features/grammar/domain/usecases/get_grammar_roadmap.dart';
import 'package:easy_english/features/grammar/presentation/providers/grammar_provider.dart';

class MockGrammarRemoteDataSource implements GrammarRemoteDataSource {
  @override
  Future<GrammarEvaluationModel> evaluateSentence({
    required String sentence,
    String? targetWord,
  }) async {
    return const GrammarEvaluationModel(
      isCorrect: true,
      explanation: 'Excellent grammar and sentence structure.',
      correctedSentence: 'No corrections needed.',
      suggestedExercises: ['Band 8+ phrasing used.'],
    );
  }

  @override
  Future<List<GrammarTopicModel>> fetchRoadmapTopics() async {
    return [
      GrammarTopicModel(
        id: 'mock_topic',
        title: 'Mock Topic',
        description: 'Mock Description',
        cefrLevel: 'B2',
        status: GrammarTopicStatus.current,
        masteryPercentage: 80.0,
        orderIndex: 1,
        prerequisiteIds: const [],
        iconName: 'mock_icon',
        rules: const [
          GrammarRuleModel(
            id: 'mock_rule',
            topicId: 'mock_topic',
            title: 'Mock Rule',
            summary: 'Summary',
            detailedExplanation: 'Explanation',
            examples: ['Ex 1'],
            commonPitfalls: ['Pitfall 1'],
          ),
        ],
        exercises: const [
          GrammarExerciseModel(
            id: 'mock_ex',
            topicId: 'mock_topic',
            ruleId: 'mock_rule',
            type: ExerciseType.multipleChoice,
            prompt: 'Prompt',
            options: ['A', 'B'],
            correctAnswer: 'A',
            explanation: 'Explanation',
          ),
        ],
      ),
    ];
  }

  @override
  Future<List<GrammarMistakeRecordModel>> fetchMistakeRecords() async {
    return [
      GrammarMistakeRecordModel(
        id: 'mock_mistake',
        ruleCategory: 'Articles',
        originalText: 'A test',
        correctedText: 'The test',
        explanation: 'Explanation',
        occurrenceCount: 2,
        lastFailedAt: DateTime(2026, 1, 2),
        isResolved: false,
      ),
    ];
  }
}

void main() {
  group('Grammar Feature Clean Architecture Tests', () {
    late MockGrammarRemoteDataSource mockRemoteDataSource;
    late GrammarRepositoryImpl repository;

    setUp(() {
      mockRemoteDataSource = MockGrammarRemoteDataSource();
      repository = GrammarRepositoryImpl(
        remoteDataSource: mockRemoteDataSource,
      );
    });

    test(
      'Repository evaluateGrammar returns valid domain GrammarEvaluation entity',
      () async {
        final result = await repository.evaluateGrammar(
          sentence: 'The sun rises in the east.',
        );
        expect(result, isA<GrammarEvaluation>());
        expect(result.isCorrect, isTrue);
        expect(result.feedback, contains('Excellent grammar'));
      },
    );

    test(
      'Repository getGrammarRoadmap returns list of GrammarTopic entities',
      () async {
        final topics = await repository.getGrammarRoadmap();
        expect(topics.length, equals(1));
        expect(topics.first, isA<GrammarTopic>());
        expect(topics.first.title, equals('Mock Topic'));
        expect(topics.first.rules.first, isA<GrammarRule>());
        expect(topics.first.exercises.first, isA<GrammarExercise>());
      },
    );

    test(
      'Repository getGrammarMistakes returns list of GrammarMistakeRecord entities',
      () async {
        final mistakes = await repository.getGrammarMistakes();
        expect(mistakes.length, equals(1));
        expect(mistakes.first, isA<GrammarMistakeRecord>());
        expect(mistakes.first.topicCategory, equals('Articles'));
      },
    );

    test('EvaluateGrammar UseCase executes repository correctly', () async {
      final useCase = EvaluateGrammar(repository: repository);
      final eval = await useCase(sentence: 'Test sentence');
      expect(eval.isCorrect, isTrue);
    });

    test('GetGrammarRoadmap UseCase executes repository correctly', () async {
      final useCase = GetGrammarRoadmap(repository: repository);
      final topics = await useCase();
      expect(topics.first.id, equals('mock_topic'));
    });

    test('GetGrammarMistakes UseCase executes repository correctly', () async {
      final useCase = GetGrammarMistakes(repository: repository);
      final mistakes = await useCase();
      expect(mistakes.first.id, equals('mock_mistake'));
    });

    test('GrammarProvider loads roadmap and mistakes successfully', () async {
      final provider = GrammarProvider(
        getGrammarRoadmap: GetGrammarRoadmap(repository: repository),
        getGrammarMistakes: GetGrammarMistakes(repository: repository),
        evaluateGrammar: EvaluateGrammar(repository: repository),
      );

      expect(provider.topics.isEmpty, isTrue);
      expect(provider.mistakes.isEmpty, isTrue);

      await provider.loadRoadmap();
      expect(provider.topics.length, equals(1));

      await provider.loadMistakes();
      expect(provider.mistakes.length, equals(1));
    });
  });
}
