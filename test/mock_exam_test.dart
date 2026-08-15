import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:easy_english/core/network/api_client.dart';
import 'package:easy_english/features/mock_exam/data/datasources/mock_exam_remote_datasource.dart';
import 'package:easy_english/features/mock_exam/data/models/mock_exam_paper_model.dart';
import 'package:easy_english/features/mock_exam/data/repositories/mock_exam_repository_impl.dart';
import 'package:easy_english/features/mock_exam/domain/entities/answer_analysis.dart';
import 'package:easy_english/features/mock_exam/domain/entities/mock_exam_result.dart';
import 'package:easy_english/features/mock_exam/domain/entities/mock_question.dart';
import 'package:easy_english/features/mock_exam/domain/usecases/get_available_mock_exams.dart';
import 'package:easy_english/features/mock_exam/presentation/providers/mock_exam_provider.dart';
import 'package:easy_english/features/mock_exam/presentation/screens/mock_exam_selection_screen.dart';
import 'package:easy_english/features/mock_exam/presentation/screens/mock_result_screen.dart';
import 'package:easy_english/features/mock_exam/presentation/widgets/mock_exam_error_widget.dart';

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
  group('IELTS Mock Exam Data & API Contracts Unit Tests', () {
    test('MockQuestion & AnswerAnalysis JSON serialization', () {
      final qJson = {
        'id': 'q1',
        'question_number': 1,
        'question_text': 'Glass was first produced in Ancient Egypt.',
        'type': 'true_false_not_given',
        'options': ['TRUE', 'FALSE', 'NOT GIVEN'],
        'correct_answer': 'FALSE',
        'explanation': 'Originated in Mesopotamia.'
      };
      final q = MockQuestion.fromJson(qJson);
      expect(q.id, 'q1');
      expect(q.questionNumber, 1);
      expect(q.questionText, 'Glass was first produced in Ancient Egypt.');
      expect(q.options.length, 3);

      final aJson = {
        'question_id': 'q1',
        'user_answer': 'TRUE',
        'correct_answer': 'FALSE',
        'is_correct': false,
        'explanation': 'Incorrect statement.'
      };
      final analysis = AnswerAnalysis.fromJson(aJson);
      expect(analysis.questionId, 'q1');
      expect(analysis.isCorrect, false);
    });

    test('MockExamPaperModel parses backend paper catalog & detail response', () {
      final catalogJson = {
        'id': 'exam_001',
        'title': 'Cambridge IELTS 18 - Test 1',
        'type': 'full',
        'duration_minutes': 160,
        'total_questions': 80,
        'difficulty': 'Hard'
      };
      final paper = MockExamPaperModel.fromJson(catalogJson);
      expect(paper.id, 'exam_001');
      expect(paper.durationMinutes, 160);
      expect(paper.totalQuestions, 80);
      expect(paper.difficulty, 'Hard');
    });

    test('MockExamRemoteDatasourceImpl fetches from backend endpoints', () async {
      final mockClient = MockApiClient(
        onGet: (path) async {
          if (path.contains('/mock-exams/exam_001')) {
            return http.Response(jsonEncode({
              'id': 'exam_001',
              'title': 'Test 1',
              'type': 'reading',
              'passage_text': 'Passage content',
              'questions': []
            }), 200);
          }
          return http.Response(jsonEncode([
            {'id': 'exam_001', 'title': 'Test 1', 'type': 'reading', 'duration_minutes': 60, 'total_questions': 40, 'difficulty': 'Medium'}
          ]), 200);
        },
      );
      final datasource = MockExamRemoteDatasourceImpl(apiClient: mockClient);
      final exams = await datasource.getAvailableExams(type: 'reading');
      expect(exams.length, 1);
      expect(exams.first.id, 'exam_001');
    });

    test('MockExamRepositoryImpl & UseCases bubble remote exceptions for UI handling', () async {
      final mockClient = MockApiClient(
        onGet: (path) async => http.Response('Internal Server Error', 500),
      );
      final repo = MockExamRepositoryImpl(remoteDatasource: MockExamRemoteDatasourceImpl(apiClient: mockClient));
      final useCase = GetAvailableExamsUseCase(repo);

      expect(() => useCase(type: 'reading'), throwsA(isA<Exception>()));
    });
  });

  group('Mock Exam UI & Error State Widget Tests', () {
    testWidgets('MockExamErrorWidget renders connection error and triggers retry', (tester) async {
      bool retried = false;
      await tester.pumpWidget(MaterialApp(
        home: MockExamErrorWidget(
          errorMessage: 'Server unreachable',
          onRetry: () => retried = true,
        ),
      ));

      expect(find.text('Connection Error'), findsOneWidget);
      expect(find.text('Server unreachable'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);

      await tester.tap(find.text('Try Again'));
      expect(retried, true);
    });

    testWidgets('MockExamSelectionScreen renders category chips and paper list', (tester) async {
      final mockClient = MockApiClient(
        onGet: (path) async => http.Response(jsonEncode([
          {'id': 'exam_001', 'title': 'Cambridge IELTS 18 - Test 1', 'type': 'full', 'duration_minutes': 160, 'total_questions': 80, 'difficulty': 'Hard'}
        ]), 200),
      );
      final provider = MockExamProvider(repository: MockExamRepositoryImpl(remoteDatasource: MockExamRemoteDatasourceImpl(apiClient: mockClient)));

      await tester.pumpWidget(MaterialApp(
        home: MockExamSelectionScreen(provider: provider),
      ));
      await tester.pumpAndSettle();

      expect(find.text('IELTS Mock Exam Center'), findsOneWidget);
      expect(find.text('All Tests'), findsOneWidget);
      expect(find.text('Cambridge IELTS 18 - Test 1'), findsOneWidget);
    });

    testWidgets('MockResultScreen renders band badge summary and answer breakdown', (tester) async {
      final mockResult = MockExamResult(
        id: 'result_7712',
        examPaperId: 'exam_001',
        overallBand: 7.5,
        listeningBand: 8.0,
        readingBand: 7.0,
        readingRawScore: 32,
        totalReadingQuestions: 40,
        answerAnalysis: const [
          AnswerAnalysis(
            questionId: 'q1',
            userAnswer: 'TRUE',
            correctAnswer: 'TRUE',
            isCorrect: true,
            explanation: 'Paragraph 2 states that early glass objects were found in Egypt.',
          ),
        ],
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(MaterialApp(home: MockResultScreen(result: mockResult)));

      expect(find.text('Mock Exam Performance Report'), findsOneWidget);
      expect(find.text('7.5'), findsOneWidget);
      expect(find.text('Detailed Answer Key'), findsOneWidget);
      expect(find.text('Explanation: Paragraph 2 states that early glass objects were found in Egypt.'), findsOneWidget);
    });
  });
}
