import '../entities/diagnostic_session.dart';
import '../entities/estimated_band_score.dart';
import '../entities/placement_question.dart';
import '../entities/placement_result.dart';
import '../entities/study_plan_recommendation.dart';

abstract class PlacementRepository {
  Future<List<PlacementQuestion>> fetchPlacementQuestions();

  Future<PlacementResult> submitPlacementTest({
    required Map<String, int> answers,
    required int totalTimeSeconds,
  });

  EstimatedBandScore calculateEstimatedBandScore(DiagnosticSession session);

  StudyPlanRecommendation generateStudyPlan(
    EstimatedBandScore bandScore, {
    double targetBand = 7.5,
  });
}
