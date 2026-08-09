class AiCoachRecommendation {
  final double predictedOverallBand;
  final double targetBand;
  final List<String> weaknessSummary;
  final List<String> remediationTasks;
  final String aiCoachNotes;

  const AiCoachRecommendation({
    required this.predictedOverallBand,
    required this.targetBand,
    required this.weaknessSummary,
    required this.remediationTasks,
    required this.aiCoachNotes,
  });

  AiCoachRecommendation copyWith({
    double? predictedOverallBand,
    double? targetBand,
    List<String>? weaknessSummary,
    List<String>? remediationTasks,
    String? aiCoachNotes,
  }) {
    return AiCoachRecommendation(
      predictedOverallBand: predictedOverallBand ?? this.predictedOverallBand,
      targetBand: targetBand ?? this.targetBand,
      weaknessSummary: weaknessSummary ?? this.weaknessSummary,
      remediationTasks: remediationTasks ?? this.remediationTasks,
      aiCoachNotes: aiCoachNotes ?? this.aiCoachNotes,
    );
  }
}
