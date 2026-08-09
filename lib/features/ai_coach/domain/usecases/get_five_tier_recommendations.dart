import '../../data/repositories/ai_coach_repository_impl.dart';
import '../entities/five_tier_recommendation.dart';
import '../repositories/ai_coach_repository.dart';

class GetFiveTierRecommendations {
  final AiCoachRepository _repository;

  GetFiveTierRecommendations({AiCoachRepository? repository})
    : _repository = repository ?? AiCoachRepositoryImpl();

  Future<FiveTierRecommendation> call() {
    return _repository.get5TierRecommendations();
  }
}
