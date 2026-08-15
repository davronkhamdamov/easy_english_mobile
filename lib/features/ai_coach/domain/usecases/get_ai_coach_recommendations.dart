import '../entities/ai_coach_recommendation.dart';
import '../repositories/ai_coach_repository.dart';

class GetAiCoachRecommendations {
  final AiCoachRepository _repository;

  GetAiCoachRecommendations({required AiCoachRepository repository})
      : _repository = repository;

  Future<AiCoachRecommendation> call() {
    return _repository.getRecommendations();
  }
}
