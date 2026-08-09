import 'package:easy_english/features/placement_test/data/models/daily_schedule_item_model.dart';
import 'package:easy_english/features/placement_test/data/models/diagnostic_session_model.dart';
import 'package:easy_english/features/placement_test/data/models/estimated_band_score_model.dart';
import 'package:easy_english/features/placement_test/data/models/placement_question_model.dart';
import 'package:easy_english/features/placement_test/data/models/placement_result_model.dart';
import 'package:easy_english/features/placement_test/data/models/study_plan_recommendation_model.dart';
import 'package:easy_english/features/placement_test/domain/entities/diagnostic_session.dart';
import 'package:easy_english/features/placement_test/domain/entities/diagnostic_skill.dart';
import 'package:easy_english/features/placement_test/domain/entities/estimated_band_score.dart';
import 'package:easy_english/features/placement_test/domain/entities/placement_question.dart';
import 'package:easy_english/features/placement_test/domain/entities/study_plan_recommendation.dart';
import 'package:easy_english/features/placement_test/domain/usecases/calculate_placement_result.dart';
import 'package:easy_english/features/placement_test/domain/usecases/fetch_placement_questions.dart';
import 'package:easy_english/features/placement_test/domain/usecases/submit_placement_test.dart';
import 'package:easy_english/features/placement_test/presentation/providers/placement_test_provider.dart';
import 'package:easy_english/features/placement_test/presentation/screens/placement_test_screen.dart';
import 'package:easy_english/features/placement_test/presentation/widgets/placement_progress_indicator.dart';
import 'package:easy_english/features/placement_test/presentation/widgets/placement_question_card.dart';
import 'package:easy_english/features/placement_test/presentation/widgets/placement_result_card.dart';
import 'package:easy_english/features/placement_test/presentation/widgets/study_plan_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Placement Test Domain & Data Unit Tests', () {
    test('DiagnosticSkill enum properties and parsing', () {
      expect(DiagnosticSkill.grammar.displayName, equals('Grammar'));
      expect(DiagnosticSkill.vocabulary.displayName, equals('Vocabulary'));
      expect(DiagnosticSkill.reading.displayName, equals('Reading'));
      expect(DiagnosticSkill.listening.displayName, equals('Listening'));

      expect(
        DiagnosticSkill.fromString('grammar'),
        equals(DiagnosticSkill.grammar),
      );
      expect(
        DiagnosticSkill.fromString('READING'),
        equals(DiagnosticSkill.reading),
      );
      expect(
        DiagnosticSkill.fromString('invalid'),
        equals(DiagnosticSkill.grammar),
      );
    });

    test('PlacementQuestion sampleQuestions and copyWith', () {
      final questions = PlacementQuestion.sampleQuestions;
      expect(questions.length, equals(8));
      expect(questions[0].skill, equals(DiagnosticSkill.grammar));
      expect(questions[4].skill, equals(DiagnosticSkill.reading));
      expect(questions[6].skill, equals(DiagnosticSkill.listening));

      final q0 = questions[0];
      final copy = q0.copyWith(prompt: 'Updated Prompt');
      expect(copy.prompt, equals('Updated Prompt'));
      expect(copy.id, equals(q0.id));
    });

    test('DiagnosticSession getters and progress calculation', () {
      final questions = PlacementQuestion.sampleQuestions;
      final session = DiagnosticSession(
        id: 'test_session_1',
        startTime: DateTime.now(),
        durationSeconds: 600,
        questions: questions,
        userAnswers: {'q1_grammar': 1, 'q2_grammar': 2},
      );

      expect(session.answeredCount, equals(2));
      expect(session.totalQuestions, equals(8));
      expect(session.progressPercentage, equals(0.25));
      expect(session.currentQuestion.id, equals('q1_grammar'));
    });

    test('EstimatedBandScore.fromSession scoring calculation algorithm', () {
      final questions = PlacementQuestion.sampleQuestions;
      // Answer all correctly
      final userAnswers = <String, int>{
        for (final q in questions) q.id: q.correctOptionIndex,
      };

      final session = DiagnosticSession(
        id: 'perf_session',
        startTime: DateTime.now(),
        durationSeconds: 600,
        questions: questions,
        userAnswers: userAnswers,
      );

      final bandScore = EstimatedBandScore.fromSession(session);
      expect(bandScore.overallBand, equals(9.0));
      expect(bandScore.grammarBand, equals(9.0));
      expect(bandScore.cefrEquivalent, contains('C2'));
      expect(bandScore.strengths.length, greaterThan(0));
    });

    test(
      'StudyPlanRecommendation.generate study plan calculation algorithm',
      () {
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
        expect(plan.weeklySchedule.length, equals(7));
        expect(plan.keyMilestones.length, equals(3));
      },
    );

    test('PlacementQuestionModel JSON roundtrip and toEntity', () {
      final json = {
        'id': 'pq_100',
        'skill': 'vocabulary',
        'prompt': 'Choose synonym',
        'options': ['Option A', 'Option B'],
        'correct_option_index': 0,
        'explanation': 'Explanation text',
        'cefr_level': 'B2',
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
            'skill': 'grammar',
            'prompt': 'Prompt text',
            'options': ['A', 'B'],
            'correct_option_index': 0,
            'explanation': 'Exp',
            'cefr_level': 'B1',
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

    test(
      'EstimatedBandScoreModel, DailyScheduleItemModel, StudyPlanRecommendationModel, and PlacementResultModel JSON roundtrips',
      () {
        final bandJson = {
          'overall_band': 7.0,
          'grammar_band': 7.0,
          'vocabulary_band': 7.0,
          'reading_band': 7.0,
          'listening_band': 7.0,
          'cefr_equivalent': 'C1 Advanced',
          'skill_breakdown': {'Grammar': 7.0},
          'strengths': ['Good sentence structure'],
          'weaknesses': ['Targeted collocations'],
        };

        final bandModel = EstimatedBandScoreModel.fromJson(bandJson);
        expect(bandModel.overallBand, equals(7.0));
        expect(bandModel.toEntity().cefrEquivalent, equals('C1 Advanced'));

        final itemJson = {
          'day': 'Monday',
          'focus_skill': 'Writing',
          'duration_minutes': 45,
          'topic': 'Task 2 Essay',
          'action': 'Write essay',
        };
        final itemModel = DailyScheduleItemModel.fromJson(itemJson);
        expect(itemModel.durationMinutes, equals(45));

        final planJson = {
          'current_overall_band': 6.5,
          'target_band': 7.5,
          'recommended_daily_minutes': 45,
          'estimated_weeks_to_target': 6,
          'focus_areas': ['Grammar'],
          'weekly_schedule': [itemJson],
          'key_milestones': ['Week 2 milestone'],
        };
        final planModel = StudyPlanRecommendationModel.fromJson(planJson);
        expect(planModel.currentOverallBand, equals(6.5));
        expect(planModel.toEntity().weeklySchedule.length, equals(1));

        final resultJson = {
          'initial_band_score': 6.0,
          'target_band_score': 7.5,
          'weak_areas': ['Listening'],
          'study_plan_summary': 'Plan created',
        };
        final resultModel = PlacementResultModel.fromJson(resultJson);
        expect(resultModel.initialBandScore, equals(6.0));
        expect(resultModel.toEntity().studyPlanSummary, equals('Plan created'));
      },
    );
  });

  group('Placement Test Use Cases Unit Tests', () {
    test(
      'FetchPlacementQuestions, SubmitPlacementTest, and CalculatePlacementResult instantiate and run cleanly',
      () {
        final fetch = FetchPlacementQuestions();
        final submit = SubmitPlacementTest();
        final calc = CalculatePlacementResult();

        expect(fetch, isNotNull);
        expect(submit, isNotNull);
        expect(calc, isNotNull);

        final session = DiagnosticSession(
          id: 'usecase_sess',
          startTime: DateTime.now(),
          durationSeconds: 600,
          questions: PlacementQuestion.sampleQuestions,
        );

        final res = calc(session);
        expect(res.score.overallBand, greaterThanOrEqualTo(4.0));
        expect(res.studyPlan.recommendedDailyMinutes, greaterThan(0));
      },
    );
  });

  group('Placement Test Provider Unit Tests', () {
    test(
      'PlacementTestProvider initializes session, updates options, navigates questions, and handles audio toggle',
      () {
        final provider = PlacementTestProvider();

        expect(provider.session.questions.length, equals(8));
        expect(provider.session.currentQuestionIndex, equals(0));
        expect(provider.isSubmitting, isFalse);
        expect(provider.calculatedScore, isNull);

        provider.selectOption(1);
        expect(provider.session.userAnswers['q1_grammar'], equals(1));

        provider.nextQuestion();
        expect(provider.session.currentQuestionIndex, equals(1));

        provider.previousQuestion();
        expect(provider.session.currentQuestionIndex, equals(0));

        provider.goToQuestion(4);
        expect(provider.session.currentQuestionIndex, equals(4));

        provider.toggleAudioPlay();
        expect(provider.isPlayingAudio, isTrue);
        provider.toggleAudioPlay();
        expect(provider.isPlayingAudio, isFalse);

        provider.dispose();
      },
    );
  });

  group('Placement Test UI Presentation Widget Tests', () {
    testWidgets(
      'PlacementTestScreen renders header, timer, skill badge, and active question cards',
      (WidgetTester tester) async {
        await tester.pumpWidget(const MaterialApp(home: PlacementTestScreen()));
        await tester.pump();

        expect(find.text('IELTS Diagnostic Placement Test'), findsOneWidget);
        expect(find.byType(PlacementProgressIndicator), findsOneWidget);
        expect(find.byType(PlacementQuestionCard), findsOneWidget);
        expect(find.text('Question 1 of 8'), findsOneWidget);
        expect(find.text('Next Question'), findsOneWidget);
      },
    );

    testWidgets(
      'PlacementResultCard renders estimated band score banner and skill proficiency cards',
      (WidgetTester tester) async {
        const sampleScore = EstimatedBandScore(
          overallBand: 7.0,
          grammarBand: 7.5,
          vocabularyBand: 7.0,
          readingBand: 6.5,
          listeningBand: 7.0,
          cefrEquivalent: 'C1 Advanced',
          skillBreakdown: {
            'Grammar': 7.5,
            'Vocabulary': 7.0,
            'Reading': 6.5,
            'Listening': 7.0,
          },
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
        expect(find.text('Skill Proficiency Breakdown'), findsOneWidget);
        expect(
          find.textContaining('High grammatical accuracy'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'StudyPlanCard renders target band chip, metric tiles, and weekly schedule',
      (WidgetTester tester) async {
        const sampleScore = EstimatedBandScore(
          overallBand: 6.5,
          grammarBand: 6.5,
          vocabularyBand: 6.5,
          readingBand: 6.5,
          listeningBand: 6.5,
          cefrEquivalent: 'B2 Upper Intermediate',
          skillBreakdown: {'Grammar': 6.5},
          strengths: ['Good grammar'],
          weaknesses: ['Article usage'],
        );

        final plan = StudyPlanRecommendation.generate(
          bandScore: sampleScore,
          targetBand: 7.5,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: StudyPlanCard(
                  plan: plan,
                  onSavePlan: () {},
                  onRetakeTest: () {},
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Personalized IELTS Study Plan'), findsOneWidget);
        expect(find.text('Target Band 7.5'), findsOneWidget);
        expect(find.text('Daily Target'), findsOneWidget);
        expect(find.text('Recommended Daily Schedule:'), findsOneWidget);
        expect(find.text('Save Study Plan to Dashboard'), findsOneWidget);
        expect(find.text('Retake Diagnostic Test'), findsOneWidget);
      },
    );
  });
}
