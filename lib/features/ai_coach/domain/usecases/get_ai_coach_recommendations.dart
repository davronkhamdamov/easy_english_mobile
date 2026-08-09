import '../../data/repositories/ai_coach_repository_impl.dart';
import '../entities/ai_coach_recommendation.dart';
import '../repositories/ai_coach_repository.dart';

class GetAiCoachRecommendations {
  final AiCoachRepository _repository;

  GetAiCoachRecommendations({AiCoachRepository? repository})
    : _repository = repository ?? AiCoachRepositoryImpl();

  Future<AiCoachRecommendation> call() {
    return _repository.getRecommendations();
  }
}
