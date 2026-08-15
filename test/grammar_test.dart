import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:easy_english/core/network/api_client.dart';
import 'package:easy_english/features/grammar/data/datasources/grammar_remote_datasource.dart';
import 'package:easy_english/features/grammar/data/models/grammar_evaluation_model.dart';
import 'package:easy_english/features/grammar/data/models/grammar_mistake_model.dart';
import 'package:easy_english/features/grammar/data/models/grammar_topic_model.dart';
import 'package:easy_english/features/grammar/data/repositories/grammar_repository_impl.dart';
import 'package:easy_english/features/grammar/domain/usecases/get_grammar_roadmap.dart';
import 'package:easy_english/features/grammar/presentation/providers/grammar_provider.dart';
import 'package:easy_english/features/grammar/presentation/screens/grammar_exercise_screen.dart';
import 'package:easy_english/features/grammar/presentation/screens/grammar_mistakes_screen.dart';
import 'package:easy_english/features/grammar/presentation/screens/grammar_roadmap_screen.dart';
import 'package:easy_english/features/grammar/presentation/widgets/grammar_error_widget.dart';

class MockApiClient extends ApiClient {
  final Future<http.Response> Function(String path)? onGet;
  final Future<http.Response> Function(String path, Map<String, dynamic> body)? onPost;

  MockApiClient({this.onGet, this.onPost});

  @override
  Future<http.Response> get(String path) async {
    if (onGet != null) return await onGet!(path);
    return http.Response('[]', 200);
  }

  @override
  Future<http.Response> post(String path, Map<String, dynamic> body) async {
    if (onPost != null) return await onPost!(path, body);
    return http.Response('{}', 200);
  }
}

void main() {
  group('Grammar Feature Unit & DTO Tests', () {
    test('GrammarEvaluationModel parses backend API response', () {
      final json = {
        'is_correct': false,
        'original_sentence': "She don't like playing tennis.",
        'corrected_sentence': "She doesn't like playing tennis.",
        'score': 60,
        'error_type': 'Subject-Verb Agreement',
        'explanation': "'She' is a third-person singular pronoun and requires 'doesn't'.",
        'rule_reference': 'Present Simple Tense Negative Form',
        'suggested_exercises': ['Third-person Singular Drills']
      };
      final eval = GrammarEvaluationModel.fromJson(json);
      expect(eval.isCorrect, false);
      expect(eval.score, 60);
      expect(eval.errorType, 'Subject-Verb Agreement');
      expect(eval.correctedSentence, "She doesn't like playing tennis.");
    });

    test('GrammarTopicModel & GrammarMistakeRecordModel serialization', () {
      final topicJson = {
        'id': 'gram_top_01',
        'title': 'Present Simple vs Continuous',
        'cefr_level': 'A2',
        'description': 'Master habit actions.',
        'is_completed': true,
        'progress_percent': 100
      };
      final topic = GrammarTopicModel.fromJson(topicJson);
      expect(topic.id, 'gram_top_01');
      expect(topic.cefrLevel, 'A2');

      final mistakeJson = {
        'id': 'mistake_301',
        'original_text': 'I am working here since 2020.',
        'corrected_text': 'I have been working here since 2020.',
        'rule_category': 'Present Perfect Continuous',
        'occurrence_count': 3,
        'last_failed_at': '2026-08-10T14:30:00Z'
      };
      final mistake = GrammarMistakeRecordModel.fromJson(mistakeJson);
      expect(mistake.id, 'mistake_301');
      expect(mistake.ruleCategory, 'Present Perfect Continuous');
    });

    test('GrammarRemoteDataSourceImpl fetches directly from backend API', () async {
      final client = MockApiClient(
        onGet: (path) async {
          if (path.contains('/grammar/topics')) {
            return http.Response(jsonEncode([
              {'id': 'gram_top_01', 'title': 'Present Simple', 'cefr_level': 'A1', 'description': 'Basics', 'is_completed': true, 'progress_percent': 100}
            ]), 200);
          }
          if (path.contains('/grammar/mistakes')) {
            return http.Response(jsonEncode([
              {'id': 'm1', 'original_text': 'I go yesterday', 'corrected_text': 'I went yesterday', 'rule_category': 'Past Simple', 'occurrence_count': 2, 'last_failed_at': '2026-08-10T14:30:00Z'}
            ]), 200);
          }
          return http.Response('[]', 200);
        },
      );
      final ds = GrammarRemoteDataSourceImpl(client: client);
      final topics = await ds.fetchRoadmapTopics();
      expect(topics.length, 1);
      expect(topics.first.title, 'Present Simple');

      final mistakes = await ds.fetchMistakeRecords();
      expect(mistakes.length, 1);
      expect(mistakes.first.ruleCategory, 'Past Simple');
    });

    test('GrammarRepositoryImpl bubbles API network exceptions', () async {
      final client = MockApiClient(
        onGet: (path) async => http.Response('Server Error', 500),
      );
      final repo = GrammarRepositoryImpl(remoteDataSource: GrammarRemoteDataSourceImpl(client: client));
      final useCase = GetGrammarRoadmap(repository: repo);
      expect(() => useCase(), throwsA(isA<Exception>()));
    });
  });

  group('Grammar Presentation Widget Tests', () {
    testWidgets('GrammarErrorWidget renders error message and triggers retry', (tester) async {
      bool retried = false;
      await tester.pumpWidget(MaterialApp(
        home: GrammarErrorWidget(
          errorMessage: 'Backend API unreachable',
          onRetry: () => retried = true,
        ),
      ));

      expect(find.text('Grammar Service Error'), findsOneWidget);
      expect(find.text('Backend API unreachable'), findsOneWidget);

      await tester.tap(find.text('Try Again'));
      expect(retried, true);
    });

    testWidgets('GrammarRoadmapScreen renders CEFR chips and topics', (tester) async {
      final client = MockApiClient(
        onGet: (path) async => http.Response(jsonEncode([
          {'id': 't1', 'title': 'Conditionals', 'cefr_level': 'B1', 'description': 'If clauses', 'is_completed': false, 'progress_percent': 40}
        ]), 200),
      );
      final provider = GrammarProvider(repository: GrammarRepositoryImpl(remoteDataSource: GrammarRemoteDataSourceImpl(client: client)));

      await tester.pumpWidget(MaterialApp(home: GrammarRoadmapScreen(provider: provider)));
      await tester.pumpAndSettle();

      expect(find.text('Grammar Roadmap'), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Conditionals'), findsOneWidget);
    });

    testWidgets('GrammarExerciseScreen evaluates sentence and renders result card', (tester) async {
      final client = MockApiClient(
        onPost: (path, body) async => http.Response(jsonEncode({
          'is_correct': false,
          'original_sentence': "She don't like tennis.",
          'corrected_sentence': "She doesn't like tennis.",
          'score': 70,
          'error_type': 'Subject-Verb',
          'explanation': "Requires doesn't.",
          'rule_reference': 'Present Simple'
        }), 200),
      );
      final provider = GrammarProvider(repository: GrammarRepositoryImpl(remoteDataSource: GrammarRemoteDataSourceImpl(client: client)));

      await tester.pumpWidget(MaterialApp(home: GrammarExerciseScreen(provider: provider)));
      await tester.enterText(find.byType(TextField).first, "She don't like tennis.");
      await tester.tap(find.text('Check Grammar with AI'));
      await tester.pumpAndSettle();

      expect(find.text('Error Detected'), findsOneWidget);
      expect(find.text("She doesn't like tennis."), findsOneWidget);
    });

    testWidgets('GrammarMistakesScreen renders logged mistakes list', (tester) async {
      final client = MockApiClient(
        onGet: (path) async => http.Response(jsonEncode([
          {'id': 'm1', 'original_text': 'I am here since 2020.', 'corrected_text': 'I have been here since 2020.', 'rule_category': 'Present Perfect', 'occurrence_count': 3, 'last_failed_at': '2026-08-10T14:30:00Z'}
        ]), 200),
      );
      final provider = GrammarProvider(repository: GrammarRepositoryImpl(remoteDataSource: GrammarRemoteDataSourceImpl(client: client)));

      await tester.pumpWidget(MaterialApp(home: GrammarMistakesScreen(provider: provider)));
      await tester.pumpAndSettle();

      expect(find.text('Grammar Mistake Log'), findsOneWidget);
      expect(find.text('Present Perfect'), findsOneWidget);
      expect(find.text('Failed 3x'), findsOneWidget);
    });
  });
}
