import '../../domain/entities/placement_result.dart';

class PlacementResultModel {
  final double initialBandScore;
  final double targetBandScore;
  final List<String> weakAreas;
  final String studyPlanSummary;

  PlacementResultModel({
    required this.initialBandScore,
    required this.targetBandScore,
    required this.weakAreas,
    required this.studyPlanSummary,
  });

  factory PlacementResultModel.fromJson(Map<String, dynamic> json) {
    return PlacementResultModel(
      initialBandScore: (json['initial_band_score'] as num?)?.toDouble() ?? 6.0,
      targetBandScore: (json['target_band_score'] as num?)?.toDouble() ?? 7.5,
      weakAreas:
          (json['weak_areas'] as List?)?.map((e) => e.toString()).toList() ??
          [],
      studyPlanSummary:
          json['study_plan_summary']?.toString() ??
          'Initial study plan generated.',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'initial_band_score': initialBandScore,
      'target_band_score': targetBandScore,
      'weak_areas': weakAreas,
      'study_plan_summary': studyPlanSummary,
    };
  }

  PlacementResult toEntity() {
    return PlacementResult(
      initialBandScore: initialBandScore,
      targetBandScore: targetBandScore,
      weakAreas: weakAreas,
      studyPlanSummary: studyPlanSummary,
    );
  }

  factory PlacementResultModel.fromEntity(PlacementResult entity) {
    return PlacementResultModel(
      initialBandScore: entity.initialBandScore,
      targetBandScore: entity.targetBandScore,
      weakAreas: entity.weakAreas,
      studyPlanSummary: entity.studyPlanSummary,
    );
  }
}
