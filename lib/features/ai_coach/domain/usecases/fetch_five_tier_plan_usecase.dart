import '../entities/five_tier_recommendation.dart';
import '../repositories/ai_coach_repository.dart';

class FetchFiveTierPlanUseCase {
  final AiCoachRepository _repository;

  FetchFiveTierPlanUseCase(this._repository);

  Future<FiveTierRecommendation> call() {
    return _repository.get5TierRecommendations();
  }
}
