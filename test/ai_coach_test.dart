import 'package:easy_english/features/ai_coach/data/datasources/ai_coach_remote_datasource.dart';
import 'package:easy_english/features/ai_coach/data/models/ai_coach_recommendation_dto.dart';
import 'package:easy_english/features/ai_coach/data/models/five_tier_recommendation_dto.dart';
import 'package:easy_english/features/ai_coach/data/repositories/ai_coach_repository_impl.dart';
import 'package:easy_english/features/ai_coach/domain/entities/ai_coach_recommendation.dart';
import 'package:easy_english/features/ai_coach/domain/entities/five_tier_recommendation.dart';
import 'package:easy_english/features/ai_coach/domain/repositories/ai_coach_repository.dart';
import 'package:easy_english/features/ai_coach/domain/services/recommendation_engine_service.dart';
import 'package:easy_english/features/ai_coach/domain/usecases/get_ai_coach_recommendations.dart';
import 'package:easy_english/features/ai_coach/domain/usecases/get_five_tier_recommendations.dart';
import 'package:easy_english/features/ai_coach/presentation/providers/ai_coach_provider.dart';
import 'package:easy_english/features/ai_coach/presentation/screens/ai_coach_screen.dart';
import 'package:easy_english/features/ai_coach/presentation/widgets/ai_coach_guidance_card.dart';
import 'package:easy_english/features/ai_coach/presentation/widgets/ai_coach_header_card.dart';
import 'package:easy_english/features/ai_coach/presentation/widgets/remediation_plan_section.dart';
import 'package:easy_english/features/ai_coach/presentation/widgets/weakness_matrix_section.dart';
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
      predictedOverallBand: 7.5,
      targetBand: 8.0,
      weaknessSummary: ['Grammar Task 2'],
      remediationTasks: ['Do 1 exercise'],
      aiCoachNotes: 'Great job',
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

  MockAiCoachRepository({
    required this.recommendation,
    required this.fiveTierRecommendation,
  });

  @override
  Future<AiCoachRecommendation> getRecommendations() async {
    return recommendation;
  }

  @override
  Future<FiveTierRecommendation> get5TierRecommendations() async {
    return fiveTierRecommendation;
  }
}

void main() {
  group('AI Coach Domain Entity & Service Tests', () {
    test('AiCoachRecommendation construction and copyWith', () {
      const rec = AiCoachRecommendation(
        predictedOverallBand: 7.0,
        targetBand: 7.5,
        weaknessSummary: ['Task 2 Grammatical Range'],
        remediationTasks: ['Complete 1 exercise'],
        aiCoachNotes: 'Keep practicing',
      );

      expect(rec.predictedOverallBand, equals(7.0));
      expect(rec.targetBand, equals(7.5));
      expect(rec.weaknessSummary.length, equals(1));

      final copy = rec.copyWith(targetBand: 8.0);
      expect(copy.targetBand, equals(8.0));
      expect(copy.predictedOverallBand, equals(7.0));
    });

    test('FiveTierRecommendation construction and copyWith', () {
      const fiveTier = FiveTierRecommendation(
        tier1CriticalWeaknesses: ['Tier 1 Task'],
        tier2ScheduledReviews: ['Tier 2 Task'],
        tier3PersonalizedRoadmap: ['Tier 3 Task'],
        tier4AiSuggestions: ['Tier 4 Task'],
        tier5OptionalPractice: ['Tier 5 Task'],
      );

      expect(fiveTier.tier1CriticalWeaknesses.length, equals(1));
      expect(fiveTier.tier5OptionalPractice.first, equals('Tier 5 Task'));

      final copy = fiveTier.copyWith(
        tier1CriticalWeaknesses: ['Updated Tier 1'],
      );
      expect(copy.tier1CriticalWeaknesses.first, equals('Updated Tier 1'));
      expect(copy.tier2ScheduledReviews.first, equals('Tier 2 Task'));
    });

    test('RecommendationEngineService fallbacks and business logic', () {
      const service = RecommendationEngineService();

      final fallbackRec = service.getFallbackRecommendations();
      expect(fallbackRec.predictedOverallBand, equals(7.0));
      expect(fallbackRec.targetBand, equals(7.5));
      expect(fallbackRec.weaknessSummary, isNotEmpty);

      final fallback5Tier = service.getFallback5TierRecommendations();
      expect(fallback5Tier.tier1CriticalWeaknesses, isNotEmpty);
      expect(fallback5Tier.tier4AiSuggestions, isNotEmpty);

      final totalActions = service.calculateTotalActionItems(fallback5Tier);
      expect(totalActions, equals(5));

      final bandGap = service.calculateBandGap(fallbackRec);
      expect(bandGap, equals(0.5));
    });
  });

  group('AI Coach Data Layer DTO & Repository Tests', () {
    test('AiCoachRecommendationDto fromJson, toJson, and toDomain', () {
      final json = {
        'predicted_overall_band': 7.0,
        'target_band': 8.0,
        'weakness_summary': ['Listening S3'],
        'remediation_tasks': ['Sentence Builder'],
        'ai_coach_notes': 'Well done',
      };

      final dto = AiCoachRecommendationDto.fromJson(json);
      expect(dto.predictedOverallBand, equals(7.0));
      expect(dto.targetBand, equals(8.0));

      final jsonOut = dto.toJson();
      expect(jsonOut['predicted_overall_band'], equals(7.0));

      final domain = dto.toDomain();
      expect(domain.predictedOverallBand, equals(7.0));
      expect(domain.targetBand, equals(8.0));
      expect(domain.weaknessSummary.first, equals('Listening S3'));
    });

    test('FiveTierRecommendationDto fromJson, toJson, and toDomain', () {
      final json = {
        'tier1_critical_weaknesses': ['W1'],
        'tier2_scheduled_reviews': ['R1'],
        'tier3_personalized_roadmap': ['P1'],
        'tier4_ai_suggestions': ['S1'],
        'tier5_optional_practice': ['O1'],
      };

      final dto = FiveTierRecommendationDto.fromJson(json);
      expect(dto.tier1CriticalWeaknesses?.first, equals('W1'));

      final jsonOut = dto.toJson();
      expect(jsonOut['tier1_critical_weaknesses'], equals(['W1']));

      final domain = dto.toDomain();
      expect(domain.tier1CriticalWeaknesses.first, equals('W1'));
      expect(domain.tier5OptionalPractice.first, equals('O1'));
    });

    test('AiCoachRepositoryImpl fetches data from datasource', () async {
      final datasource = MockAiCoachRemoteDatasource();
      final repository = AiCoachRepositoryImpl(remoteDatasource: datasource);

      final rec = await repository.getRecommendations();
      expect(rec.predictedOverallBand, equals(7.5));
      expect(rec.targetBand, equals(8.0));

      final fiveTier = await repository.get5TierRecommendations();
      expect(fiveTier.tier1CriticalWeaknesses.first, equals('Weakness 1'));
    });

    test('AiCoachRepositoryImpl uses domain fallback on error', () async {
      final datasource = MockAiCoachRemoteDatasource(shouldThrow: true);
      final repository = AiCoachRepositoryImpl(remoteDatasource: datasource);

      final rec = await repository.getRecommendations();
      expect(rec.predictedOverallBand, equals(7.0));
      expect(rec.targetBand, equals(7.5));

      final fiveTier = await repository.get5TierRecommendations();
      expect(
        fiveTier.tier1CriticalWeaknesses.first,
        equals('Task 2 Grammatical Range & Coherence'),
      );
    });
  });

  group('AI Coach Use Cases & Provider Tests', () {
    const testRec = AiCoachRecommendation(
      predictedOverallBand: 7.0,
      targetBand: 7.5,
      weaknessSummary: ['Weakness A'],
      remediationTasks: ['Task A'],
      aiCoachNotes: 'Notes A',
    );

    const test5Tier = FiveTierRecommendation(
      tier1CriticalWeaknesses: ['T1'],
      tier2ScheduledReviews: ['T2'],
      tier3PersonalizedRoadmap: ['T3'],
      tier4AiSuggestions: ['T4'],
      tier5OptionalPractice: ['T5'],
    );

    test('GetAiCoachRecommendations use case calls repository', () async {
      final repo = MockAiCoachRepository(
        recommendation: testRec,
        fiveTierRecommendation: test5Tier,
      );
      final useCase = GetAiCoachRecommendations(repository: repo);

      final result = await useCase();
      expect(result.predictedOverallBand, equals(7.0));
    });

    test('GetFiveTierRecommendations use case calls repository', () async {
      final repo = MockAiCoachRepository(
        recommendation: testRec,
        fiveTierRecommendation: test5Tier,
      );
      final useCase = GetFiveTierRecommendations(repository: repo);

      final result = await useCase();
      expect(result.tier1CriticalWeaknesses.first, equals('T1'));
    });

    test('AiCoachProvider loads recommendations and updates state', () async {
      final repo = MockAiCoachRepository(
        recommendation: testRec,
        fiveTierRecommendation: test5Tier,
      );
      final provider = AiCoachProvider(
        getAiCoachRecommendations: GetAiCoachRecommendations(repository: repo),
        getFiveTierRecommendations: GetFiveTierRecommendations(
          repository: repo,
        ),
      );

      expect(provider.isLoading, isFalse);
      expect(provider.recommendation, isNull);

      await provider.loadRecommendations();
      expect(provider.isLoading, isFalse);
      expect(provider.recommendation?.predictedOverallBand, equals(7.0));

      await provider.loadFiveTierRecommendations();
      expect(
        provider.fiveTierRecommendation?.tier1CriticalWeaknesses.first,
        equals('T1'),
      );
    });
  });

  group('AI Coach Widget & Screen Rendering Tests', () {
    testWidgets('AiCoachHeaderCard renders band scores', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AiCoachHeaderCard(predictedOverallBand: 7.0, targetBand: 7.5),
          ),
        ),
      );

      expect(find.text('Predicted IELTS Band'), findsOneWidget);
      expect(find.text('Band 7.0'), findsOneWidget);
      expect(find.text('Target: Band 7.5'), findsOneWidget);
      expect(find.byIcon(Icons.psychology), findsOneWidget);
    });

    testWidgets('AiCoachGuidanceCard renders coach notes', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AiCoachGuidanceCard(
              notes: 'Focus on Task 2 writing structure next.',
            ),
          ),
        ),
      );

      expect(find.text('Coach Guidance'), findsOneWidget);
      expect(
        find.text('Focus on Task 2 writing structure next.'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
    });

    testWidgets('RemediationPlanSection renders task items', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RemediationPlanSection(
              tasks: ['Complete 1 Sentence Builder', 'Review 5 Flashcards'],
            ),
          ),
        ),
      );

      expect(find.text('Personalized Remediation Plan:'), findsOneWidget);
      expect(find.text('Complete 1 Sentence Builder'), findsOneWidget);
      expect(find.text('Review 5 Flashcards'), findsOneWidget);
    });

    testWidgets('WeaknessMatrixSection renders weakness items', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WeaknessMatrixSection(
              weaknesses: ['Task 2 Grammatical Range & Coherence'],
            ),
          ),
        ),
      );

      expect(find.text('Identified Weak Points:'), findsOneWidget);
      expect(find.text('Task 2 Grammatical Range & Coherence'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });

    testWidgets('AICoachScreen renders full screen with loaded provider', (
      WidgetTester tester,
    ) async {
      const rec = AiCoachRecommendation(
        predictedOverallBand: 7.0,
        targetBand: 7.5,
        weaknessSummary: ['Task 2 Grammatical Range'],
        remediationTasks: ['Complete 1 exercise'],
        aiCoachNotes: 'Awesome progress!',
      );
      const fiveTier = FiveTierRecommendation(
        tier1CriticalWeaknesses: ['T1'],
        tier2ScheduledReviews: ['T2'],
        tier3PersonalizedRoadmap: ['T3'],
        tier4AiSuggestions: ['T4'],
        tier5OptionalPractice: ['T5'],
      );

      final repo = MockAiCoachRepository(
        recommendation: rec,
        fiveTierRecommendation: fiveTier,
      );
      final provider = AiCoachProvider(
        getAiCoachRecommendations: GetAiCoachRecommendations(repository: repo),
        getFiveTierRecommendations: GetFiveTierRecommendations(
          repository: repo,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(home: AICoachScreen(provider: provider)),
      );

      await tester.pumpAndSettle();

      expect(find.text('AI Personal Coach'), findsOneWidget);
      expect(find.text('Predicted IELTS Band'), findsOneWidget);
      expect(find.text('Band 7.0'), findsOneWidget);
      expect(find.text('Target: Band 7.5'), findsOneWidget);
      expect(find.text('Coach Guidance'), findsOneWidget);
      expect(find.text('Awesome progress!'), findsOneWidget);
      expect(find.text('Personalized Remediation Plan:'), findsOneWidget);
      expect(find.text('Complete 1 exercise'), findsOneWidget);
      expect(find.text('Identified Weak Points:'), findsOneWidget);
      expect(find.text('Task 2 Grammatical Range'), findsOneWidget);
    });
  });
}
