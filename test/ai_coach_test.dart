import 'package:easy_english/features/ai_coach/data/datasources/ai_coach_remote_datasource.dart';
import 'package:easy_english/features/ai_coach/data/models/ai_coach_recommendation_dto.dart';
import 'package:easy_english/features/ai_coach/data/models/five_tier_recommendation_dto.dart';
import 'package:easy_english/features/ai_coach/data/repositories/ai_coach_repository_impl.dart';
import 'package:easy_english/features/ai_coach/domain/entities/ai_coach_recommendation.dart';
import 'package:easy_english/features/ai_coach/domain/entities/five_tier_recommendation.dart';
import 'package:easy_english/features/ai_coach/domain/entities/recommendation_tier.dart';
import 'package:easy_english/features/ai_coach/domain/repositories/ai_coach_repository.dart';
import 'package:easy_english/features/ai_coach/domain/services/recommendation_engine_service.dart';
import 'package:easy_english/features/ai_coach/domain/usecases/fetch_ai_recommendations_usecase.dart';
import 'package:easy_english/features/ai_coach/domain/usecases/fetch_five_tier_plan_usecase.dart';
import 'package:easy_english/features/ai_coach/presentation/providers/ai_coach_provider.dart';
import 'package:easy_english/features/ai_coach/presentation/screens/ai_coach_screen.dart';
import 'package:easy_english/features/ai_coach/presentation/widgets/ai_coach_error_widget.dart';
import 'package:easy_english/features/ai_coach/presentation/widgets/ai_coach_header_card.dart';
import 'package:easy_english/features/ai_coach/presentation/widgets/five_tier_plan_widget.dart';
import 'package:easy_english/features/ai_coach/presentation/widgets/recommended_topics_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class MockAiCoachRemoteDatasource implements AiCoachRemoteDatasource {
  final bool shouldReturnNull;
  final bool shouldThrow;

  MockAiCoachRemoteDatasource({
    this.shouldReturnNull = false,
    this.shouldThrow = false,
  });

  @override
  Future<AiCoachRecommendationDto?> fetchRecommendations() async {
    if (shouldThrow) throw Exception('API Network Error');
    if (shouldReturnNull) return null;
    return AiCoachRecommendationDto(
      userId: 'usr_9981',
      currentEstimatedBand: 7.5,
      targetBand: 8.0,
      primaryWeakness: 'Grammar Task 2',
      aiCoachMessage: 'Great job',
      recommendedTopics: ['Do 1 exercise'],
    );
  }

  @override
  Future<FiveTierRecommendationDto?> fetch5TierRecommendations() async {
    if (shouldThrow) throw Exception('API Network Error');
    if (shouldReturnNull) return null;
    return FiveTierRecommendationDto(
      tier1CriticalWeaknesses: ['Weakness 1'],
      tier2ScheduledReviews: ['Review 1'],
      tier3PersonalizedRoadmap: ['Roadmap 1'],
      tier4AiSuggestions: ['Suggestion 1'],
      tier5OptionalPractice: ['Practice 1'],
    );
  }
}

class MockAiCoachRepository implements AiCoachRepository {
  final AiCoachRecommendation recommendation;
  final FiveTierRecommendation fiveTierRecommendation;
  final bool shouldThrow;

  MockAiCoachRepository({
    required this.recommendation,
    required this.fiveTierRecommendation,
    this.shouldThrow = false,
  });

  @override
  Future<AiCoachRecommendation> getRecommendations() async {
    if (shouldThrow) throw Exception('Server unreachable');
    return recommendation;
  }

  @override
  Future<FiveTierRecommendation> get5TierRecommendations() async {
    if (shouldThrow) throw Exception('Server unreachable');
    return fiveTierRecommendation;
  }
}

void main() {
  group('AI Coach Domain Entity & Service Tests', () {
    test('AiCoachRecommendation construction and copyWith', () {
      const rec = AiCoachRecommendation(
        userId: 'usr_1',
        currentEstimatedBand: 7.0,
        targetBand: 7.5,
        primaryWeakness: 'Task 2 Grammatical Range',
        aiCoachMessage: 'Keep practicing',
        recommendedTopics: ['Complete 1 exercise'],
        fiveTierPlan: FiveTierRecommendation(
          tier1Foundations: RecommendationTier(
            title: 'T1',
            status: 'completed',
            items: [],
          ),
          tier2SkillBuilding: RecommendationTier(
            title: 'T2',
            status: 'in_progress',
            items: [],
          ),
          tier3PracticeDrills: RecommendationTier(
            title: 'T3',
            status: 'locked',
            items: [],
          ),
          tier4MockSimulation: RecommendationTier(
            title: 'T4',
            status: 'locked',
            items: [],
          ),
          tier5AdvancedMastery: RecommendationTier(
            title: 'T5',
            status: 'locked',
            items: [],
          ),
        ),
      );

      expect(rec.predictedOverallBand, equals(7.0));
      expect(rec.targetBand, equals(7.5));
      expect(rec.weaknessSummary.length, equals(1));

      final copy = rec.copyWith(targetBand: 8.0);
      expect(copy.targetBand, equals(8.0));
      expect(copy.predictedOverallBand, equals(7.0));
    });

    test('FiveTierRecommendation construction and copyWith', () {
      final fiveTier = FiveTierRecommendation.empty().copyWith(
        tier1CriticalWeaknesses: ['Tier 1 Task'],
        tier5OptionalPractice: ['Tier 5 Task'],
      );

      expect(fiveTier.tier1CriticalWeaknesses.length, equals(1));
      expect(fiveTier.tier5OptionalPractice.first, equals('Tier 5 Task'));
    });

    test('RecommendationEngineService fallbacks and business logic', () {
      const service = RecommendationEngineService();

      final fallbackRec = service.getFallbackRecommendations();
      expect(fallbackRec.predictedOverallBand, equals(7.0));
      expect(fallbackRec.targetBand, equals(7.5));

      final totalActions = service.calculateTotalActionItems(fallbackRec.fiveTierPlan);
      expect(totalActions, equals(5));

      final bandGap = service.calculateBandGap(fallbackRec);
      expect(bandGap, equals(0.5));
    });
  });

  group('AI Coach Data Layer DTO & Repository Tests', () {
    test('AiCoachRecommendationDto fromJson, toJson, and toDomain', () {
      final json = {
        'user_id': 'usr_9981',
        'current_estimated_band': 7.0,
        'target_band': 8.0,
        'primary_weakness': 'Grammatical Accuracy & Coherence',
        'ai_coach_message': 'Focus on complex sentence structures.',
        'recommended_topics': ['Complex Sentences', 'Academic Collocations'],
      };

      final dto = AiCoachRecommendationDto.fromJson(json);
      expect(dto.currentEstimatedBand, equals(7.0));
      expect(dto.targetBand, equals(8.0));
      expect(dto.primaryWeakness, equals('Grammatical Accuracy & Coherence'));

      final domain = dto.toDomain();
      expect(domain.currentEstimatedBand, equals(7.0));
      expect(domain.targetBand, equals(8.0));
      expect(domain.primaryWeakness, equals('Grammatical Accuracy & Coherence'));
    });

    test('FiveTierRecommendationDto fromJson with 5-tier nested plan', () {
      final json = {
        'tier_1_foundations': {
          'title': 'Tier 1: Foundations & Core Rules',
          'status': 'completed',
          'items': ['Relative Clauses Review']
        },
        'tier_2_skill_building': {
          'title': 'Tier 2: Targeted Skill Drills',
          'status': 'in_progress',
          'items': ['Cohesive Devices Drill']
        },
        'tier_3_practice_drills': {
          'title': 'Tier 3: Guided Practice Modules',
          'status': 'locked',
          'items': ['Task 2 Paragraph Building']
        },
        'tier_4_mock_simulation': {
          'title': 'Tier 4: Exam Simulation',
          'status': 'locked',
          'items': ['Timed Mock']
        },
        'tier_5_advanced_mastery': {
          'title': 'Tier 5: Band 8+ Mastery',
          'status': 'locked',
          'items': ['Lexical Variety Challenge']
        }
      };

      final dto = FiveTierRecommendationDto.fromJson(json);
      final domain = dto.toDomain();

      expect(domain.tier1Foundations.title, equals('Tier 1: Foundations & Core Rules'));
      expect(domain.tier1Foundations.status, equals('completed'));
      expect(domain.tier1Foundations.items.first, equals('Relative Clauses Review'));
    });

    test('AiCoachRepositoryImpl fetches data directly from datasource', () async {
      final datasource = MockAiCoachRemoteDatasource();
      final repository = AiCoachRepositoryImpl(remoteDatasource: datasource);

      final rec = await repository.getRecommendations();
      expect(rec.predictedOverallBand, equals(7.5));
      expect(rec.targetBand, equals(8.0));
    });

    test('AiCoachRepositoryImpl throws exception on error without mock fallback', () async {
      final datasource = MockAiCoachRemoteDatasource(shouldThrow: true);
      final repository = AiCoachRepositoryImpl(remoteDatasource: datasource);

      expect(() => repository.getRecommendations(), throwsA(isA<Exception>()));
    });
  });

  group('AI Coach Use Cases & Provider Tests', () {
    const testRec = AiCoachRecommendation(
      userId: 'usr_9981',
      currentEstimatedBand: 7.0,
      targetBand: 7.5,
      primaryWeakness: 'Weakness A',
      aiCoachMessage: 'Notes A',
      recommendedTopics: ['Topic A'],
      fiveTierPlan: FiveTierRecommendation(
        tier1Foundations: RecommendationTier(
          title: 'T1',
          status: 'completed',
          items: ['T1 item'],
        ),
        tier2SkillBuilding: RecommendationTier(
          title: 'T2',
          status: 'in_progress',
          items: ['T2 item'],
        ),
        tier3PracticeDrills: RecommendationTier(
          title: 'T3',
          status: 'locked',
          items: ['T3 item'],
        ),
        tier4MockSimulation: RecommendationTier(
          title: 'T4',
          status: 'locked',
          items: ['T4 item'],
        ),
        tier5AdvancedMastery: RecommendationTier(
          title: 'T5',
          status: 'locked',
          items: ['T5 item'],
        ),
      ),
    );

    test('FetchAiRecommendationsUseCase calls repository', () async {
      final repo = MockAiCoachRepository(
        recommendation: testRec,
        fiveTierRecommendation: testRec.fiveTierPlan,
      );
      final useCase = FetchAiRecommendationsUseCase(repo);

      final result = await useCase();
      expect(result.currentEstimatedBand, equals(7.0));
    });

    test('FetchFiveTierPlanUseCase calls repository', () async {
      final repo = MockAiCoachRepository(
        recommendation: testRec,
        fiveTierRecommendation: testRec.fiveTierPlan,
      );
      final useCase = FetchFiveTierPlanUseCase(repo);

      final result = await useCase();
      expect(result.tier1Foundations.items.first, equals('T1 item'));
    });

    test('AiCoachProvider loads recommendations and updates state', () async {
      final repo = MockAiCoachRepository(
        recommendation: testRec,
        fiveTierRecommendation: testRec.fiveTierPlan,
      );
      final provider = AiCoachProvider(
        fetchAiRecommendationsUseCase: FetchAiRecommendationsUseCase(repo),
        fetchFiveTierPlanUseCase: FetchFiveTierPlanUseCase(repo),
      );

      expect(provider.isLoading, isFalse);
      expect(provider.recommendation, isNull);

      await provider.fetchRecommendations();
      expect(provider.isLoading, isFalse);
      expect(provider.recommendation?.currentEstimatedBand, equals(7.0));
      expect(provider.fiveTierPlan?.tier1Foundations.items.first, equals('T1 item'));
    });

    test('AiCoachProvider sets error state on network failure', () async {
      final repo = MockAiCoachRepository(
        recommendation: testRec,
        fiveTierRecommendation: testRec.fiveTierPlan,
        shouldThrow: true,
      );
      final provider = AiCoachProvider(
        fetchAiRecommendationsUseCase: FetchAiRecommendationsUseCase(repo),
      );

      await provider.fetchRecommendations();
      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, contains('Server unreachable'));
    });
  });

  group('AI Coach Widget & Screen Rendering Tests', () {
    testWidgets('AiCoachHeaderCard renders band scores & weakness badge', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AiCoachHeaderCard(
              predictedOverallBand: 7.0,
              targetBand: 7.5,
              primaryWeakness: 'Grammar Accuracy',
            ),
          ),
        ),
      );

      expect(find.text('Predicted IELTS Band'), findsOneWidget);
      expect(find.text('Band 7.0'), findsOneWidget);
      expect(find.text('Target: Band 7.5'), findsOneWidget);
      expect(find.text('Focus Area: Grammar Accuracy'), findsOneWidget);
    });

    testWidgets('RecommendedTopicsList renders practice topic chips', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RecommendedTopicsList(
              topics: ['Complex Sentences', 'Task 2 Essay'],
            ),
          ),
        ),
      );

      expect(find.text('Recommended Practice Topics'), findsOneWidget);
      expect(find.text('Complex Sentences'), findsOneWidget);
      expect(find.text('Task 2 Essay'), findsOneWidget);
    });

    testWidgets('FiveTierPlanWidget renders tier stack', (
      WidgetTester tester,
    ) async {
      final plan = FiveTierRecommendation.empty().copyWith(
        tier1CriticalWeaknesses: ['Subject-Verb Agreement'],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FiveTierPlanWidget(plan: plan, selectedIndex: 0),
          ),
        ),
      );

      expect(find.text('5-Tier Learning Roadmap'), findsOneWidget);
      expect(find.text('Subject-Verb Agreement'), findsOneWidget);
    });

    testWidgets('AiCoachErrorWidget renders error state with retry button', (
      WidgetTester tester,
    ) async {
      bool retried = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AiCoachErrorWidget(
              errorMessage: 'Network Connection Failed',
              onRetry: () => retried = true,
            ),
          ),
        ),
      );

      expect(find.text('Unable to Load AI Recommendations'), findsOneWidget);
      expect(find.text('Network Connection Failed'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      expect(retried, isTrue);
    });

    testWidgets('AICoachScreen renders error state when provider fails', (
      WidgetTester tester,
    ) async {
      const rec = AiCoachRecommendation(
        userId: 'usr_1',
        currentEstimatedBand: 7.0,
        targetBand: 7.5,
        primaryWeakness: 'Weakness A',
        aiCoachMessage: 'Notes A',
        recommendedTopics: ['Topic A'],
        fiveTierPlan: FiveTierRecommendation(
          tier1Foundations: RecommendationTier(
            title: 'T1',
            status: 'completed',
            items: [],
          ),
          tier2SkillBuilding: RecommendationTier(
            title: 'T2',
            status: 'in_progress',
            items: [],
          ),
          tier3PracticeDrills: RecommendationTier(
            title: 'T3',
            status: 'locked',
            items: [],
          ),
          tier4MockSimulation: RecommendationTier(
            title: 'T4',
            status: 'locked',
            items: [],
          ),
          tier5AdvancedMastery: RecommendationTier(
            title: 'T5',
            status: 'locked',
            items: [],
          ),
        ),
      );

      final repo = MockAiCoachRepository(
        recommendation: rec,
        fiveTierRecommendation: rec.fiveTierPlan,
        shouldThrow: true,
      );
      final provider = AiCoachProvider(
        fetchAiRecommendationsUseCase: FetchAiRecommendationsUseCase(repo),
      );

      await tester.pumpWidget(
        MaterialApp(home: AICoachScreen(provider: provider)),
      );

      await tester.pumpAndSettle();

      expect(find.text('AI Personal Coach'), findsOneWidget);
      expect(find.text('Unable to Load AI Recommendations'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });
  });
}
