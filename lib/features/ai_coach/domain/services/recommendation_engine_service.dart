import '../entities/ai_coach_recommendation.dart';
import '../entities/five_tier_recommendation.dart';

/// Pure domain service managing AI recommendation calculations, ranking rules,
/// and default fallback recommendation sets.
class RecommendationEngineService {
  const RecommendationEngineService();

  /// Resolves standard recommendation fallback data when API responses are empty or unavailable.
  AiCoachRecommendation getFallbackRecommendations() {
    return const AiCoachRecommendation(
      predictedOverallBand: 7.0,
      targetBand: 7.5,
      weaknessSummary: [
        'Task 2 Grammatical Range & Coherence',
        'Listening Section 3 Multiple Choice',
        'Academic C1 Synonyms',
      ],
      remediationTasks: [
        'Complete 1 Sentence Builder exercise on "Conditionals"',
        'Review 5 C1 Academic Flashcards',
        'Listen to 1 Short Academic Segment',
      ],
      aiCoachNotes:
          'Your Speaking Part 1 fluency score rose to Band 7.5! Focus on Task 2 writing structure next.',
    );
  }

  /// Resolves 5-Tier educational plan fallback data when API responses are empty or unavailable.
  FiveTierRecommendation getFallback5TierRecommendations() {
    return const FiveTierRecommendation(
      tier1CriticalWeaknesses: ['Task 2 Grammatical Range & Coherence'],
      tier2ScheduledReviews: [
        'Review 5 C1 Academic Flashcards (SM-2 Spaced Repetition)',
      ],
      tier3PersonalizedRoadmap: [
        'Lesson 4: Advanced Complex Sentence Structures',
      ],
      tier4AiSuggestions: [
        'Google Antigravity Memory Agent: Focus on Speaking Part 3 Fluency',
      ],
      tier5OptionalPractice: ['Full-Length IELTS Reading Mock Test'],
    );
  }

  /// Calculates total action items across all tiers in a 5-Tier recommendation.
  int calculateTotalActionItems(FiveTierRecommendation recommendation) {
    return recommendation.tier1CriticalWeaknesses.length +
        recommendation.tier2ScheduledReviews.length +
        recommendation.tier3PersonalizedRoadmap.length +
        recommendation.tier4AiSuggestions.length +
        recommendation.tier5OptionalPractice.length;
  }

  /// Calculates the performance gap between predicted overall band and target band.
  double calculateBandGap(AiCoachRecommendation recommendation) {
    final gap = recommendation.targetBand - recommendation.predictedOverallBand;
    return gap > 0 ? double.parse(gap.toStringAsFixed(1)) : 0.0;
  }
}
