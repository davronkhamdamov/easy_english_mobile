import 'recommendation_tier.dart';

class FiveTierRecommendation {
  final RecommendationTier tier1Foundations;
  final RecommendationTier tier2SkillBuilding;
  final RecommendationTier tier3PracticeDrills;
  final RecommendationTier tier4MockSimulation;
  final RecommendationTier tier5AdvancedMastery;

  const FiveTierRecommendation({
    required this.tier1Foundations,
    required this.tier2SkillBuilding,
    required this.tier3PracticeDrills,
    required this.tier4MockSimulation,
    required this.tier5AdvancedMastery,
  });

  List<RecommendationTier> get allTiers => [
    tier1Foundations,
    tier2SkillBuilding,
    tier3PracticeDrills,
    tier4MockSimulation,
    tier5AdvancedMastery,
  ];

  // Legacy getters for backward compatibility
  List<String> get tier1CriticalWeaknesses => tier1Foundations.items;
  List<String> get tier2ScheduledReviews => tier2SkillBuilding.items;
  List<String> get tier3PersonalizedRoadmap => tier3PracticeDrills.items;
  List<String> get tier4AiSuggestions => tier4MockSimulation.items;
  List<String> get tier5OptionalPractice => tier5AdvancedMastery.items;

  FiveTierRecommendation copyWith({
    RecommendationTier? tier1Foundations,
    RecommendationTier? tier2SkillBuilding,
    RecommendationTier? tier3PracticeDrills,
    RecommendationTier? tier4MockSimulation,
    RecommendationTier? tier5AdvancedMastery,
    List<String>? tier1CriticalWeaknesses,
    List<String>? tier2ScheduledReviews,
    List<String>? tier3PersonalizedRoadmap,
    List<String>? tier4AiSuggestions,
    List<String>? tier5OptionalPractice,
  }) {
    return FiveTierRecommendation(
      tier1Foundations: tier1Foundations ??
          (tier1CriticalWeaknesses != null
              ? RecommendationTier(
                  title: this.tier1Foundations.title,
                  status: this.tier1Foundations.status,
                  items: tier1CriticalWeaknesses,
                )
              : this.tier1Foundations),
      tier2SkillBuilding: tier2SkillBuilding ??
          (tier2ScheduledReviews != null
              ? RecommendationTier(
                  title: this.tier2SkillBuilding.title,
                  status: this.tier2SkillBuilding.status,
                  items: tier2ScheduledReviews,
                )
              : this.tier2SkillBuilding),
      tier3PracticeDrills: tier3PracticeDrills ??
          (tier3PersonalizedRoadmap != null
              ? RecommendationTier(
                  title: this.tier3PracticeDrills.title,
                  status: this.tier3PracticeDrills.status,
                  items: tier3PersonalizedRoadmap,
                )
              : this.tier3PracticeDrills),
      tier4MockSimulation: tier4MockSimulation ??
          (tier4AiSuggestions != null
              ? RecommendationTier(
                  title: this.tier4MockSimulation.title,
                  status: this.tier4MockSimulation.status,
                  items: tier4AiSuggestions,
                )
              : this.tier4MockSimulation),
      tier5AdvancedMastery: tier5AdvancedMastery ??
          (tier5OptionalPractice != null
              ? RecommendationTier(
                  title: this.tier5AdvancedMastery.title,
                  status: this.tier5AdvancedMastery.status,
                  items: tier5OptionalPractice,
                )
              : this.tier5AdvancedMastery),
    );
  }

  factory FiveTierRecommendation.empty() {
    return const FiveTierRecommendation(
      tier1Foundations: RecommendationTier(
        title: 'Tier 1: Foundations & Core Rules',
        status: 'locked',
        items: [],
      ),
      tier2SkillBuilding: RecommendationTier(
        title: 'Tier 2: Targeted Skill Drills',
        status: 'locked',
        items: [],
      ),
      tier3PracticeDrills: RecommendationTier(
        title: 'Tier 3: Guided Practice Modules',
        status: 'locked',
        items: [],
      ),
      tier4MockSimulation: RecommendationTier(
        title: 'Tier 4: Exam Simulation',
        status: 'locked',
        items: [],
      ),
      tier5AdvancedMastery: RecommendationTier(
        title: 'Tier 5: Band 8+ Mastery',
        status: 'locked',
        items: [],
      ),
    );
  }
}
