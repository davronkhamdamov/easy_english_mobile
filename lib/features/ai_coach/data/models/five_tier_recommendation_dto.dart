import '../../domain/entities/five_tier_recommendation.dart';

class FiveTierRecommendationDto {
  final List<String>? tier1CriticalWeaknesses;
  final List<String>? tier2ScheduledReviews;
  final List<String>? tier3PersonalizedRoadmap;
  final List<String>? tier4AiSuggestions;
  final List<String>? tier5OptionalPractice;

  FiveTierRecommendationDto({
    this.tier1CriticalWeaknesses,
    this.tier2ScheduledReviews,
    this.tier3PersonalizedRoadmap,
    this.tier4AiSuggestions,
    this.tier5OptionalPractice,
  });

  factory FiveTierRecommendationDto.fromJson(Map<String, dynamic> json) {
    return FiveTierRecommendationDto(
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
      'tier1_critical_weaknesses': tier1CriticalWeaknesses,
      'tier2_scheduled_reviews': tier2ScheduledReviews,
      'tier3_personalized_roadmap': tier3PersonalizedRoadmap,
      'tier4_ai_suggestions': tier4AiSuggestions,
      'tier5_optional_practice': tier5OptionalPractice,
    };
  }

  FiveTierRecommendation toDomain() {
    return FiveTierRecommendation(
      tier1CriticalWeaknesses:
          tier1CriticalWeaknesses ??
          const ['Task 2 Grammatical Range & Coherence'],
      tier2ScheduledReviews:
          tier2ScheduledReviews ??
          const ['Review 5 C1 Academic Flashcards (SM-2 Spaced Repetition)'],
      tier3PersonalizedRoadmap:
          tier3PersonalizedRoadmap ??
          const ['Lesson 4: Advanced Complex Sentence Structures'],
      tier4AiSuggestions:
          tier4AiSuggestions ??
          const [
            'Google Antigravity Memory Agent: Focus on Speaking Part 3 Fluency',
          ],
      tier5OptionalPractice:
          tier5OptionalPractice ??
          const ['Full-Length IELTS Reading Mock Test'],
    );
  }
}
