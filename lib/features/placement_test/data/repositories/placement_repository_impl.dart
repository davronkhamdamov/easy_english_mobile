import '../../domain/entities/diagnostic_session.dart';
import '../../domain/entities/estimated_band_score.dart';
import '../../domain/entities/placement_question.dart';
import '../../domain/entities/placement_result.dart';
import '../../domain/entities/study_plan_recommendation.dart';
import '../../domain/repositories/placement_repository.dart';
import '../datasources/placement_remote_datasource.dart';

class PlacementRepositoryImpl implements PlacementRepository {
  final PlacementRemoteDatasource _remoteDatasource;

  PlacementRepositoryImpl({PlacementRemoteDatasource? remoteDatasource})
      : _remoteDatasource = remoteDatasource ?? PlacementRemoteDatasource();

  @override
  Future<List<PlacementQuestion>> fetchPlacementQuestions() async {
    final models = await _remoteDatasource.fetchPlacementQuestions();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<PlacementResult> submitPlacementTest({
    required Map<String, int> answers,
    required int totalTimeSeconds,
  }) async {
    final payload = {
      'answers': answers,
      'total_time_seconds': totalTimeSeconds,
    };
    final model = await _remoteDatasource.submitPlacementTest(payload);
    return model.toEntity();
  }

  @override
  EstimatedBandScore calculateEstimatedBandScore(DiagnosticSession session) {
    return EstimatedBandScore.fromSession(session);
  }

  @override
  StudyPlanRecommendation generateStudyPlan(
    EstimatedBandScore bandScore, {
    double targetBand = 7.5,
  }) {
    return StudyPlanRecommendation.generate(
      bandScore: bandScore,
      targetBand: targetBand,
    );
  }
}
