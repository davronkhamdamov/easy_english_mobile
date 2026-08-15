import '../entities/five_tier_recommendation.dart';
import '../repositories/ai_coach_repository.dart';

class GetFiveTierRecommendations {
  final AiCoachRepository _repository;

  GetFiveTierRecommendations({required AiCoachRepository repository})
      : _repository = repository;

  Future<FiveTierRecommendation> call() {
    return _repository.get5TierRecommendations();
  }
}
