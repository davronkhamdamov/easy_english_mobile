class FiveTierRecommendation {
  final List<String> tier1CriticalWeaknesses;
  final List<String> tier2ScheduledReviews;
  final List<String> tier3PersonalizedRoadmap;
  final List<String> tier4AiSuggestions;
  final List<String> tier5OptionalPractice;

  const FiveTierRecommendation({
    required this.tier1CriticalWeaknesses,
    required this.tier2ScheduledReviews,
    required this.tier3PersonalizedRoadmap,
    required this.tier4AiSuggestions,
    required this.tier5OptionalPractice,
  });

  FiveTierRecommendation copyWith({
    List<String>? tier1CriticalWeaknesses,
    List<String>? tier2ScheduledReviews,
    List<String>? tier3PersonalizedRoadmap,
    List<String>? tier4AiSuggestions,
    List<String>? tier5OptionalPractice,
  }) {
    return FiveTierRecommendation(
      tier1CriticalWeaknesses:
          tier1CriticalWeaknesses ?? this.tier1CriticalWeaknesses,
      tier2ScheduledReviews:
          tier2ScheduledReviews ?? this.tier2ScheduledReviews,
      tier3PersonalizedRoadmap:
          tier3PersonalizedRoadmap ?? this.tier3PersonalizedRoadmap,
      tier4AiSuggestions: tier4AiSuggestions ?? this.tier4AiSuggestions,
      tier5OptionalPractice:
          tier5OptionalPractice ?? this.tier5OptionalPractice,
    );
  }
}
