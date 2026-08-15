import '../../domain/entities/placement_result.dart';

class PlacementResultModel {
  final String id;
  final String estimatedCefrLevel;
  final double estimatedIeltsBand;
  final double accuracyPercentage;
  final Map<String, SectionScoreDetail> sectionScores;
  final String recommendedStartingPoint;

  PlacementResultModel({
    required this.id,
    required this.estimatedCefrLevel,
    required this.estimatedIeltsBand,
    required this.accuracyPercentage,
    required this.sectionScores,
    required this.recommendedStartingPoint,
  });

  double get initialBandScore => estimatedIeltsBand;

  factory PlacementResultModel.fromJson(Map<String, dynamic> json) {
    final rawScores = json['section_scores'] as Map<String, dynamic>? ?? {};
    final parsedScores = rawScores.map(
      (k, v) => MapEntry(
        k,
        SectionScoreDetail.fromJson((v as Map<String, dynamic>?) ?? {}),
      ),
    );

    return PlacementResultModel(
      id: json['id'] as String? ?? 'res_${DateTime.now().millisecondsSinceEpoch}',
      estimatedCefrLevel: json['estimated_cefr_level'] as String? ?? 'B2',
      estimatedIeltsBand: (json['estimated_ielts_band'] as num?)?.toDouble() ??
          (json['initial_band_score'] as num?)?.toDouble() ?? 6.5,
      accuracyPercentage: (json['accuracy_percentage'] as num?)?.toDouble() ?? 75.0,
      sectionScores: parsedScores,
      recommendedStartingPoint: json['recommended_starting_point'] as String? ??
          json['study_plan_summary'] as String? ??
          'Intermediate Course Plan',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'estimated_cefr_level': estimatedCefrLevel,
      'estimated_ielts_band': estimatedIeltsBand,
      'accuracy_percentage': accuracyPercentage,
      'section_scores': sectionScores.map((k, v) => MapEntry(k, v.toJson())),
      'recommended_starting_point': recommendedStartingPoint,
    };
  }

  PlacementResult toEntity() {
    return PlacementResult(
      id: id,
      estimatedCefrLevel: estimatedCefrLevel,
      estimatedIeltsBand: estimatedIeltsBand,
      accuracyPercentage: accuracyPercentage,
      sectionScores: sectionScores,
      recommendedStartingPoint: recommendedStartingPoint,
    );
  }

  factory PlacementResultModel.fromEntity(PlacementResult entity) {
    return PlacementResultModel(
      id: entity.id,
      estimatedCefrLevel: entity.estimatedCefrLevel,
      estimatedIeltsBand: entity.estimatedIeltsBand,
      accuracyPercentage: entity.accuracyPercentage,
      sectionScores: entity.sectionScores,
      recommendedStartingPoint: entity.recommendedStartingPoint,
    );
  }
}
