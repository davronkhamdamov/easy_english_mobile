import '../../domain/entities/ai_coach_recommendation.dart';
import '../../domain/entities/five_tier_recommendation.dart';
import '../../domain/repositories/ai_coach_repository.dart';
import '../datasources/ai_coach_remote_datasource.dart';

class AiCoachRepositoryImpl implements AiCoachRepository {
  final AiCoachRemoteDatasource _remoteDatasource;

  AiCoachRepositoryImpl({
    AiCoachRemoteDatasource? remoteDatasource,
  }) : _remoteDatasource = remoteDatasource ?? AiCoachRemoteDatasource();

  @override
  Future<AiCoachRecommendation> getRecommendations() async {
    final dto = await _remoteDatasource.fetchRecommendations();
    if (dto != null) {
      return dto.toDomain();
    }
    throw Exception('Failed to fetch recommendations from backend API');
  }

  @override
  Future<FiveTierRecommendation> get5TierRecommendations() async {
    final dto = await _remoteDatasource.fetch5TierRecommendations();
    if (dto != null) {
      return dto.toDomain();
    }
    throw Exception('Failed to fetch 5-tier plan from backend API');
  }
}
