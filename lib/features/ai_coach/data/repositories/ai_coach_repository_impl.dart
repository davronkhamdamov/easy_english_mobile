import '../../domain/entities/ai_coach_recommendation.dart';
import '../../domain/entities/five_tier_recommendation.dart';
import '../../domain/repositories/ai_coach_repository.dart';
import '../../domain/services/recommendation_engine_service.dart';
import '../datasources/ai_coach_remote_datasource.dart';

class AiCoachRepositoryImpl implements AiCoachRepository {
  final AiCoachRemoteDatasource _remoteDatasource;
  final RecommendationEngineService _recommendationEngineService;

  AiCoachRepositoryImpl({
    AiCoachRemoteDatasource? remoteDatasource,
    RecommendationEngineService? recommendationEngineService,
  }) : _remoteDatasource = remoteDatasource ?? AiCoachRemoteDatasource(),
       _recommendationEngineService =
           recommendationEngineService ?? const RecommendationEngineService();

  @override
  Future<AiCoachRecommendation> getRecommendations() async {
    try {
      final dto = await _remoteDatasource.fetchRecommendations();
      if (dto != null) {
        return dto.toDomain();
      }
    } catch (_) {}
    return _recommendationEngineService.getFallbackRecommendations();
  }

  @override
  Future<FiveTierRecommendation> get5TierRecommendations() async {
    try {
      final dto = await _remoteDatasource.fetch5TierRecommendations();
      if (dto != null) {
        return dto.toDomain();
      }
    } catch (_) {}
    return _recommendationEngineService.getFallback5TierRecommendations();
  }
}
