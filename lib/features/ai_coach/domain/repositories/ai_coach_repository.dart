import '../entities/ai_coach_recommendation.dart';
import '../entities/five_tier_recommendation.dart';

abstract class AiCoachRepository {
  Future<AiCoachRecommendation> getRecommendations();
  Future<FiveTierRecommendation> get5TierRecommendations();
}
