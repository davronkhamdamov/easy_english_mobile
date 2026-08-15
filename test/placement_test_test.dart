import 'package:easy_english/features/placement_test/data/models/diagnostic_session_model.dart';
import 'package:easy_english/features/placement_test/data/models/placement_question_model.dart';
import 'package:easy_english/features/placement_test/data/models/placement_result_model.dart';
import 'package:easy_english/features/placement_test/domain/entities/diagnostic_session.dart';
import 'package:easy_english/features/placement_test/domain/entities/diagnostic_skill.dart';
import 'package:easy_english/features/placement_test/domain/entities/estimated_band_score.dart';
import 'package:easy_english/features/placement_test/domain/entities/placement_question.dart';
import 'package:easy_english/features/placement_test/domain/entities/study_plan_recommendation.dart';
import 'package:easy_english/features/placement_test/presentation/providers/placement_test_provider.dart';
import 'package:easy_english/features/placement_test/presentation/screens/placement_test_screen.dart';
import 'package:easy_english/features/placement_test/presentation/widgets/placement_progress_indicator.dart';
import 'package:easy_english/features/placement_test/presentation/widgets/placement_question_card.dart';
import 'package:easy_english/features/placement_test/presentation/widgets/placement_result_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

final mockQuestions = [
  const PlacementQuestion(
    id: 'place_q01',
    section: 'Grammar & Vocabulary',
    questionText: 'Choose the sentence that is grammatically correct:',
    options: [
      'If I would have known, I had called you.',
      'If I had known, I would have called you.',
      'If I knew, I will call you.',
      'If I know, I would call you.',
    ],
    correctOptionIndex: 1,
    difficultyLevel: 'Intermediate',
  ),
  const PlacementQuestion(
    id: 'place_q02',
    section: 'Listening Comprehension',
    questionText: 'Listen to the recording and answer: What is the speaker main objective?',
    options: [
      'To complain about service',
      'To request a schedule change',
      'To confirm a booking',
      'To cancel a reservation',
    ],
    correctOptionIndex: 2,
    difficultyLevel: 'Upper-Intermediate',
    audioUrl: 'https://cdn.easyenglish.app/audio/placement_q02.mp3',
  ),
];

void main() {
  group('Placement Test Domain & Data Unit Tests', () {
    test('DiagnosticSkill enum properties and parsing', () {
      expect(DiagnosticSkill.grammar.displayName, equals('Grammar'));
      expect(DiagnosticSkill.vocabulary.displayName, equals('Vocabulary'));
      expect(DiagnosticSkill.reading.displayName, equals('Reading'));
      expect(DiagnosticSkill.listening.displayName, equals('Listening'));

      expect(DiagnosticSkill.fromString('grammar'), equals(DiagnosticSkill.grammar));
      expect(DiagnosticSkill.fromString('READING'), equals(DiagnosticSkill.reading));
      expect(DiagnosticSkill.fromString('invalid'), equals(DiagnosticSkill.grammar));
    });

    test('PlacementQuestion creation and copyWith', () {
      expect(mockQuestions.length, equals(2));
      expect(mockQuestions[0].section, equals('Grammar & Vocabulary'));
      expect(mockQuestions[1].section, equals('Listening Comprehension'));

      final q0 = mockQuestions[0];
      final copy = q0.copyWith(questionText: 'Updated Prompt');
      expect(copy.questionText, equals('Updated Prompt'));
      expect(copy.id, equals(q0.id));
    });

    test('DiagnosticSession getters and progress calculation', () {
      final session = DiagnosticSession(
        id: 'test_session_1',
        startTime: DateTime.now(),
        durationSeconds: 600,
        questions: mockQuestions,
        userAnswers: {'place_q01': 1},
      );

      expect(session.answeredCount, equals(1));
      expect(session.totalQuestions, equals(2));
      expect(session.progressPercentage, equals(0.5));
      expect(session.currentQuestion.id, equals('place_q01'));
    });

    test('EstimatedBandScore.fromSession scoring calculation algorithm', () {
      final userAnswers = <String, int>{
        for (final q in mockQuestions) q.id: q.correctOptionIndex,
      };

      final session = DiagnosticSession(
        id: 'perf_session',
        startTime: DateTime.now(),
        durationSeconds: 600,
        questions: mockQuestions,
        userAnswers: userAnswers,
      );

      final bandScore = EstimatedBandScore.fromSession(session);
      expect(bandScore.overallBand, greaterThan(6.0));
      expect(bandScore.strengths.length, greaterThanOrEqualTo(0));
    });

    test('StudyPlanRecommendation.generate study plan calculation algorithm', () {
      const bandScore = EstimatedBandScore(
        overallBand: 6.0,
        grammarBand: 6.0,
        vocabularyBand: 6.0,
        readingBand: 6.0,
        listeningBand: 6.0,
        cefrEquivalent: 'B2 Upper Intermediate',
        skillBreakdown: {'Grammar': 6.0},
        strengths: ['Good grammar'],
        weaknesses: ['Article usage'],
      );

      final plan = StudyPlanRecommendation.generate(
        bandScore: bandScore,
        targetBand: 7.5,
      );
      expect(plan.currentOverallBand, equals(6.0));
      expect(plan.targetBand, equals(7.5));
      expect(plan.recommendedDailyMinutes, equals(45));
    });

    test('PlacementQuestionModel JSON roundtrip and toEntity', () {
      final json = {
        'id': 'pq_100',
        'section': 'vocabulary',
        'question_text': 'Choose synonym',
        'options': ['Option A', 'Option B'],
        'correct_option_index': 0,
        'explanation': 'Explanation text',
        'difficulty_level': 'B2',
      };

      final model = PlacementQuestionModel.fromJson(json);
      expect(model.id, equals('pq_100'));
      expect(model.skill, equals(DiagnosticSkill.vocabulary));

      final entity = model.toEntity();
      expect(entity.id, equals('pq_100'));
      expect(entity.cefrLevel, equals('B2'));
    });

    test('DiagnosticSessionModel JSON roundtrip and toEntity', () {
      final json = {
        'id': 'sess_123',
        'start_time': '2026-08-09T12:00:00.000Z',
        'duration_seconds': 600,
        'questions': [
          {
            'id': 'pq_1',
            'section': 'grammar',
            'question_text': 'Prompt text',
            'options': ['A', 'B'],
            'correct_option_index': 0,
            'explanation': 'Exp',
            'difficulty_level': 'B1',
          },
        ],
        'user_answers': {'pq_1': 0},
        'current_question_index': 0,
        'is_completed': false,
        'remaining_seconds': 550,
      };

      final model = DiagnosticSessionModel.fromJson(json);
      expect(model.id, equals('sess_123'));
      expect(model.remainingSeconds, equals(550));

      final entity = model.toEntity();
      expect(entity.id, equals('sess_123'));
      expect(entity.answeredCount, equals(1));
    });

    test('PlacementResultModel JSON roundtrip', () {
      final resultJson = {
        'id': 'place_res_551',
        'estimated_cefr_level': 'B2',
        'estimated_ielts_band': 6.5,
        'accuracy_percentage': 78.5,
        'section_scores': {
          'grammar_vocabulary': {'score': 80, 'level': 'B2'},
        },
        'recommended_starting_point': 'Intermediate Course Plan',
      };
      final resultModel = PlacementResultModel.fromJson(resultJson);
      expect(resultModel.estimatedIeltsBand, equals(6.5));
      expect(resultModel.estimatedCefrLevel, equals('B2'));
      expect(resultModel.toEntity().recommendedStartingPoint, equals('Intermediate Course Plan'));
    });
  });

  group('Placement Test Provider Unit Tests', () {
    test('PlacementTestProvider initializes with custom questions and updates answers', () {
      final provider = PlacementTestProvider(initialQuestions: mockQuestions);

      expect(provider.questions.length, equals(2));
      expect(provider.currentIndex, equals(0));
      expect(provider.isSubmitting, isFalse);

      provider.selectOption(1);
      expect(provider.userAnswers['place_q01'], equals(1));

      provider.nextQuestion();
      expect(provider.currentIndex, equals(1));

      provider.previousQuestion();
      expect(provider.currentIndex, equals(0));

      provider.dispose();
    });
  });

  group('Placement Test UI Presentation Widget Tests', () {
    testWidgets('PlacementTestScreen renders interface with initialQuestions', (WidgetTester tester) async {
      final provider = PlacementTestProvider(initialQuestions: mockQuestions);
      await tester.pumpWidget(MaterialApp(home: PlacementTestScreen(provider: provider)));
      await tester.pump();

      expect(find.text('IELTS Diagnostic Placement Test'), findsOneWidget);
      expect(find.byType(PlacementProgressIndicator), findsOneWidget);
      expect(find.byType(PlacementQuestionCard), findsOneWidget);
      expect(find.text('Question 1 of 2'), findsOneWidget);
      expect(find.text('Next Question'), findsOneWidget);

      provider.dispose();
    });

    testWidgets('PlacementResultCard renders estimated band score banner', (WidgetTester tester) async {
      const sampleScore = EstimatedBandScore(
        overallBand: 7.0,
        grammarBand: 7.5,
        vocabularyBand: 7.0,
        readingBand: 6.5,
        listeningBand: 7.0,
        cefrEquivalent: 'C1 Advanced',
        skillBreakdown: {'Grammar': 7.5},
        strengths: ['High grammatical accuracy'],
        weaknesses: ['Academic vocabulary range'],
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PlacementResultCard(score: sampleScore),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Estimated IELTS Band Score'), findsOneWidget);
      expect(find.text('7.0'), findsOneWidget);
      expect(find.text('CEFR Level: C1 Advanced'), findsOneWidget);
    });
  });
}
