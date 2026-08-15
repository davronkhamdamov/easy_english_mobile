import 'five_tier_recommendation.dart';

class AiCoachRecommendation {
  final String userId;
  final double currentEstimatedBand;
  final double targetBand;
  final String primaryWeakness;
  final String aiCoachMessage;
  final List<String> recommendedTopics;
  final FiveTierRecommendation fiveTierPlan;

  const AiCoachRecommendation({
    required this.userId,
    required this.currentEstimatedBand,
    required this.targetBand,
    required this.primaryWeakness,
    required this.aiCoachMessage,
    required this.recommendedTopics,
    required this.fiveTierPlan,
  });

  // Legacy getters for backward compatibility
  double get predictedOverallBand => currentEstimatedBand;
  List<String> get weaknessSummary =>
      primaryWeakness.isNotEmpty ? [primaryWeakness] : const [];
  List<String> get remediationTasks => recommendedTopics;
  String get aiCoachNotes => aiCoachMessage;

  AiCoachRecommendation copyWith({
    String? userId,
    double? currentEstimatedBand,
    double? predictedOverallBand,
    double? targetBand,
    String? primaryWeakness,
    List<String>? weaknessSummary,
    String? aiCoachMessage,
    String? aiCoachNotes,
    List<String>? recommendedTopics,
    List<String>? remediationTasks,
    FiveTierRecommendation? fiveTierPlan,
  }) {
    return AiCoachRecommendation(
      userId: userId ?? this.userId,
      currentEstimatedBand:
          currentEstimatedBand ??
          predictedOverallBand ??
          this.currentEstimatedBand,
      targetBand: targetBand ?? this.targetBand,
      primaryWeakness:
          primaryWeakness ??
          (weaknessSummary != null && weaknessSummary.isNotEmpty
              ? weaknessSummary.first
              : this.primaryWeakness),
      aiCoachMessage: aiCoachMessage ?? aiCoachNotes ?? this.aiCoachMessage,
      recommendedTopics:
          recommendedTopics ?? remediationTasks ?? this.recommendedTopics,
      fiveTierPlan: fiveTierPlan ?? this.fiveTierPlan,
    );
  }
}
