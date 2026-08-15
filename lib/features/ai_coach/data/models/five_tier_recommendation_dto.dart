import '../../domain/entities/five_tier_recommendation.dart';
import '../../domain/entities/recommendation_tier.dart';
import 'recommendation_tier_dto.dart';

class FiveTierRecommendationDto {
  final RecommendationTierDto? tier1Foundations;
  final RecommendationTierDto? tier2SkillBuilding;
  final RecommendationTierDto? tier3PracticeDrills;
  final RecommendationTierDto? tier4MockSimulation;
  final RecommendationTierDto? tier5AdvancedMastery;

  // Legacy fields
  final List<String>? tier1CriticalWeaknesses;
  final List<String>? tier2ScheduledReviews;
  final List<String>? tier3PersonalizedRoadmap;
  final List<String>? tier4AiSuggestions;
  final List<String>? tier5OptionalPractice;

  FiveTierRecommendationDto({
    this.tier1Foundations,
    this.tier2SkillBuilding,
    this.tier3PracticeDrills,
    this.tier4MockSimulation,
    this.tier5AdvancedMastery,
    this.tier1CriticalWeaknesses,
    this.tier2ScheduledReviews,
    this.tier3PersonalizedRoadmap,
    this.tier4AiSuggestions,
    this.tier5OptionalPractice,
  });

  factory FiveTierRecommendationDto.fromJson(Map<String, dynamic> json) {
    RecommendationTierDto? parseTier(String key) {
      if (json[key] is Map<String, dynamic>) {
        return RecommendationTierDto.fromJson(
          json[key] as Map<String, dynamic>,
        );
      }
      return null;
    }

    return FiveTierRecommendationDto(
      tier1Foundations: parseTier('tier_1_foundations'),
      tier2SkillBuilding: parseTier('tier_2_skill_building'),
      tier3PracticeDrills: parseTier('tier_3_practice_drills'),
      tier4MockSimulation: parseTier('tier_4_mock_simulation'),
      tier5AdvancedMastery: parseTier('tier_5_advanced_mastery'),
      tier1CriticalWeaknesses: (json['tier1_critical_weaknesses'] as List?)
          ?.map((e) => e.toString())
          .toList(),
      tier2ScheduledReviews: (json['tier2_scheduled_reviews'] as List?)
          ?.map((e) => e.toString())
          .toList(),
      tier3PersonalizedRoadmap: (json['tier3_personalized_roadmap'] as List?)
          ?.map((e) => e.toString())
          .toList(),
      tier4AiSuggestions: (json['tier4_ai_suggestions'] as List?)
          ?.map((e) => e.toString())
          .toList(),
      tier5OptionalPractice: (json['tier5_optional_practice'] as List?)
          ?.map((e) => e.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (tier1Foundations != null) 'tier_1_foundations': tier1Foundations!.toJson(),
      if (tier2SkillBuilding != null) 'tier_2_skill_building': tier2SkillBuilding!.toJson(),
      if (tier3PracticeDrills != null) 'tier_3_practice_drills': tier3PracticeDrills!.toJson(),
      if (tier4MockSimulation != null) 'tier_4_mock_simulation': tier4MockSimulation!.toJson(),
      if (tier5AdvancedMastery != null) 'tier_5_advanced_mastery': tier5AdvancedMastery!.toJson(),
      'tier1_critical_weaknesses': tier1CriticalWeaknesses ?? tier1Foundations?.items,
      'tier2_scheduled_reviews': tier2ScheduledReviews ?? tier2SkillBuilding?.items,
      'tier3_personalized_roadmap': tier3PersonalizedRoadmap ?? tier3PracticeDrills?.items,
      'tier4_ai_suggestions': tier4AiSuggestions ?? tier4MockSimulation?.items,
      'tier5_optional_practice': tier5OptionalPractice ?? tier5AdvancedMastery?.items,
    };
  }

  FiveTierRecommendation toDomain() {
    final t1 = tier1Foundations?.toDomain(
          defaultTitle: 'Tier 1: Foundations & Core Rules',
          defaultStatus: 'completed',
        ) ??
        RecommendationTier(
          title: 'Tier 1: Foundations & Core Rules',
          status: 'completed',
          items: tier1CriticalWeaknesses ?? const [],
        );

    final t2 = tier2SkillBuilding?.toDomain(
          defaultTitle: 'Tier 2: Targeted Skill Drills',
          defaultStatus: 'in_progress',
        ) ??
        RecommendationTier(
          title: 'Tier 2: Targeted Skill Drills',
          status: 'in_progress',
          items: tier2ScheduledReviews ?? const [],
        );

    final t3 = tier3PracticeDrills?.toDomain(
          defaultTitle: 'Tier 3: Guided Practice Modules',
          defaultStatus: 'locked',
        ) ??
        RecommendationTier(
          title: 'Tier 3: Guided Practice Modules',
          status: 'locked',
          items: tier3PersonalizedRoadmap ?? const [],
        );

    final t4 = tier4MockSimulation?.toDomain(
          defaultTitle: 'Tier 4: Exam Simulation',
          defaultStatus: 'locked',
        ) ??
        RecommendationTier(
          title: 'Tier 4: Exam Simulation',
          status: 'locked',
          items: tier4AiSuggestions ?? const [],
        );

    final t5 = tier5AdvancedMastery?.toDomain(
          defaultTitle: 'Tier 5: Band 8+ Mastery',
          defaultStatus: 'locked',
        ) ??
        RecommendationTier(
          title: 'Tier 5: Band 8+ Mastery',
          status: 'locked',
          items: tier5OptionalPractice ?? const [],
        );

    return FiveTierRecommendation(
      tier1Foundations: t1,
      tier2SkillBuilding: t2,
      tier3PracticeDrills: t3,
      tier4MockSimulation: t4,
      tier5AdvancedMastery: t5,
    );
  }
}
