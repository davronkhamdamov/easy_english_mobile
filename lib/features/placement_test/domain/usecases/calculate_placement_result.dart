import '../../data/repositories/placement_repository_impl.dart';
import '../entities/diagnostic_session.dart';
import '../entities/estimated_band_score.dart';
import '../entities/study_plan_recommendation.dart';
import '../repositories/placement_repository.dart';

class PlacementCalculationResult {
  final EstimatedBandScore score;
  final StudyPlanRecommendation studyPlan;

  const PlacementCalculationResult({
    required this.score,
    required this.studyPlan,
  });
}

class CalculatePlacementResult {
  final PlacementRepository _repository;

  CalculatePlacementResult({PlacementRepository? repository})
    : _repository = repository ?? PlacementRepositoryImpl();

  PlacementCalculationResult call(
    DiagnosticSession session, {
    double targetBand = 7.5,
  }) {
    final score = _repository.calculateEstimatedBandScore(session);
    final studyPlan = _repository.generateStudyPlan(
      score,
      targetBand: targetBand,
    );
    return PlacementCalculationResult(score: score, studyPlan: studyPlan);
  }
}
