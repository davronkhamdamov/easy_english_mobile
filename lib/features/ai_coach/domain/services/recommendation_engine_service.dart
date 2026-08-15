import '../entities/ai_coach_recommendation.dart';
import '../entities/five_tier_recommendation.dart';
import '../entities/recommendation_tier.dart';

/// Domain service for calculating band gaps and action item totals.
class RecommendationEngineService {
  const RecommendationEngineService();

  /// Calculates total action items across all tiers in a 5-Tier plan.
  int calculateTotalActionItems(FiveTierRecommendation recommendation) {
    return recommendation.tier1Foundations.items.length +
        recommendation.tier2SkillBuilding.items.length +
        recommendation.tier3PracticeDrills.items.length +
        recommendation.tier4MockSimulation.items.length +
        recommendation.tier5AdvancedMastery.items.length;
  }

  /// Calculates the performance gap between target band and current estimated band.
  double calculateBandGap(AiCoachRecommendation recommendation) {
    final gap = recommendation.targetBand - recommendation.currentEstimatedBand;
    return gap > 0 ? double.parse(gap.toStringAsFixed(1)) : 0.0;
  }

  /// Testing helper method for fallback test cases
  AiCoachRecommendation getFallbackRecommendations() {
    return const AiCoachRecommendation(
      userId: 'fallback_usr',
      currentEstimatedBand: 7.0,
      targetBand: 7.5,
      primaryWeakness: 'Task 2 Grammatical Range & Coherence',
      aiCoachMessage:
          'Your Speaking Part 1 fluency score rose to Band 7.5! Focus on Task 2 writing structure next.',
      recommendedTopics: [
        'Complete 1 Sentence Builder exercise on "Conditionals"',
        'Review 5 C1 Academic Flashcards',
        'Listen to 1 Short Academic Segment',
      ],
      fiveTierPlan: FiveTierRecommendation(
        tier1Foundations: RecommendationTier(
          title: 'Tier 1: Foundations',
          status: 'completed',
          items: ['Task 2 Grammatical Range & Coherence'],
        ),
        tier2SkillBuilding: RecommendationTier(
          title: 'Tier 2: Skill Drills',
          status: 'in_progress',
          items: ['Review 5 C1 Academic Flashcards (SM-2 Spaced Repetition)'],
        ),
        tier3PracticeDrills: RecommendationTier(
          title: 'Tier 3: Guided Practice',
          status: 'locked',
          items: ['Lesson 4: Advanced Complex Sentence Structures'],
        ),
        tier4MockSimulation: RecommendationTier(
          title: 'Tier 4: Exam Simulation',
          status: 'locked',
          items: ['Speaking Part 3 Fluency Drill'],
        ),
        tier5AdvancedMastery: RecommendationTier(
          title: 'Tier 5: Band 8+ Mastery',
          status: 'locked',
          items: ['Full-Length IELTS Reading Mock Test'],
        ),
      ),
    );
  }

  /// Testing helper method for fallback 5-tier test cases
  FiveTierRecommendation getFallback5TierRecommendations() {
    return getFallbackRecommendations().fiveTierPlan;
  }
}
