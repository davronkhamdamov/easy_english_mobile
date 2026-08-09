/// Domain entity representing submitted diagnostic placement test result.
class PlacementResult {
  final double initialBandScore;
  final double targetBandScore;
  final List<String> weakAreas;
  final String studyPlanSummary;

  const PlacementResult({
    required this.initialBandScore,
    required this.targetBandScore,
    required this.weakAreas,
    required this.studyPlanSummary,
  });
}
