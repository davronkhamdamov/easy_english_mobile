/// Section score breakdown detail
class SectionScoreDetail {
  final double score;
  final String level;

  const SectionScoreDetail({
    required this.score,
    required this.level,
  });

  factory SectionScoreDetail.fromJson(Map<String, dynamic> json) {
    return SectionScoreDetail(
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      level: json['level']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'score': score,
    'level': level,
  };
}

/// Domain entity representing submitted diagnostic placement test result.
class PlacementResult {
  final String id;
  final String estimatedCefrLevel;
  final double estimatedIeltsBand;
  final double accuracyPercentage;
  final Map<String, SectionScoreDetail> sectionScores;
  final String recommendedStartingPoint;

  const PlacementResult({
    required this.id,
    required this.estimatedCefrLevel,
    required this.estimatedIeltsBand,
    required this.accuracyPercentage,
    required this.sectionScores,
    required this.recommendedStartingPoint,
  });

  // Backward compatibility getters
  double get initialBandScore => estimatedIeltsBand;
  double get targetBandScore => (estimatedIeltsBand + 1.0).clamp(1.0, 9.0);
  List<String> get weakAreas => sectionScores.entries
      .where((e) => e.value.score < 80)
      .map((e) => e.key)
      .toList();
  String get studyPlanSummary => recommendedStartingPoint;
}
