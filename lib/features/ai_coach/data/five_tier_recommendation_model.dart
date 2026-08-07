class FiveTierRecommendation {
  final List<String> tier1CriticalWeaknesses;
  final List<String> tier2ScheduledReviews;
  final List<String> tier3PersonalizedRoadmap;
  final List<String> tier4AiSuggestions;
  final List<String> tier5OptionalPractice;

  FiveTierRecommendation({
    required this.tier1CriticalWeaknesses,
    required this.tier2ScheduledReviews,
    required this.tier3PersonalizedRoadmap,
    required this.tier4AiSuggestions,
    required this.tier5OptionalPractice,
  });

  factory FiveTierRecommendation.fromJson(Map<String, dynamic> json) {
    return FiveTierRecommendation(
      tier1CriticalWeaknesses: (json['tier1_critical_weaknesses'] as List?)?.map((e) => e.toString()).toList() ?? [],
      tier2ScheduledReviews: (json['tier2_scheduled_reviews'] as List?)?.map((e) => e.toString()).toList() ?? [],
      tier3PersonalizedRoadmap: (json['tier3_personalized_roadmap'] as List?)?.map((e) => e.toString()).toList() ?? [],
      tier4AiSuggestions: (json['tier4_ai_suggestions'] as List?)?.map((e) => e.toString()).toList() ?? [],
      tier5OptionalPractice: (json['tier5_optional_practice'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}
