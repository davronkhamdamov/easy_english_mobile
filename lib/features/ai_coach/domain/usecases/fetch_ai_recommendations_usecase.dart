import '../entities/ai_coach_recommendation.dart';
import '../repositories/ai_coach_repository.dart';

class FetchAiRecommendationsUseCase {
  final AiCoachRepository _repository;

  FetchAiRecommendationsUseCase(this._repository);

  Future<AiCoachRecommendation> call() {
    return _repository.getRecommendations();
  }
}
