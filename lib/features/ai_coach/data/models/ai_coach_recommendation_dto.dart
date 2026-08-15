import '../../domain/entities/ai_coach_recommendation.dart';
import '../../domain/entities/five_tier_recommendation.dart';
import 'five_tier_recommendation_dto.dart';

class AiCoachRecommendationDto {
  final String? userId;
  final double? currentEstimatedBand;
  final double? targetBand;
  final String? primaryWeakness;
  final String? aiCoachMessage;
  final List<String>? recommendedTopics;
  final FiveTierRecommendationDto? fiveTierPlan;

  // Legacy compatibility fields
  final double? predictedOverallBand;
  final List<String>? weaknessSummary;
  final List<String>? remediationTasks;
  final String? aiCoachNotes;

  AiCoachRecommendationDto({
    this.userId,
    this.currentEstimatedBand,
    this.targetBand,
    this.primaryWeakness,
    this.aiCoachMessage,
    this.recommendedTopics,
    this.fiveTierPlan,
    this.predictedOverallBand,
    this.weaknessSummary,
    this.remediationTasks,
    this.aiCoachNotes,
  });

  factory AiCoachRecommendationDto.fromJson(Map<String, dynamic> json) {
    final curBand = (json['current_estimated_band'] ?? json['predicted_overall_band']) as num?;
    final target = (json['target_band'] as num?)?.toDouble();
    final weakness = json['primary_weakness']?.toString() ??
        ((json['weakness_summary'] as List?)?.isNotEmpty == true
            ? (json['weakness_summary'] as List).first.toString()
            : null);
    final message = json['ai_coach_message']?.toString() ?? json['ai_coach_notes']?.toString();
    final topics = (json['recommended_topics'] ?? json['remediation_tasks']) as List?;

    FiveTierRecommendationDto? fiveTier;
    if (json['five_tier_plan'] is Map<String, dynamic>) {
      fiveTier = FiveTierRecommendationDto.fromJson(json['five_tier_plan'] as Map<String, dynamic>);
    } else if (json.containsKey('tier1_critical_weaknesses')) {
      fiveTier = FiveTierRecommendationDto.fromJson(json);
    }

    return AiCoachRecommendationDto(
      userId: json['user_id']?.toString(),
      currentEstimatedBand: curBand?.toDouble(),
      targetBand: target,
      primaryWeakness: weakness,
      aiCoachMessage: message,
      recommendedTopics: topics?.map((e) => e.toString()).toList(),
      fiveTierPlan: fiveTier,
      predictedOverallBand: curBand?.toDouble(),
      weaknessSummary: (json['weakness_summary'] as List?)?.map((e) => e.toString()).toList(),
      remediationTasks: (json['remediation_tasks'] as List?)?.map((e) => e.toString()).toList(),
      aiCoachNotes: message,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'current_estimated_band': currentEstimatedBand ?? predictedOverallBand,
      'target_band': targetBand,
      'primary_weakness': primaryWeakness ?? (weaknessSummary?.isNotEmpty == true ? weaknessSummary!.first : null),
      'ai_coach_message': aiCoachMessage ?? aiCoachNotes,
      'recommended_topics': recommendedTopics ?? remediationTasks,
      if (fiveTierPlan != null) 'five_tier_plan': fiveTierPlan!.toJson(),
      'predicted_overall_band': predictedOverallBand ?? currentEstimatedBand,
      'weakness_summary': weaknessSummary ?? (primaryWeakness != null ? [primaryWeakness!] : null),
      'remediation_tasks': remediationTasks ?? recommendedTopics,
      'ai_coach_notes': aiCoachNotes ?? aiCoachMessage,
    };
  }

  AiCoachRecommendation toDomain() {
    return AiCoachRecommendation(
      userId: userId ?? 'usr_default',
      currentEstimatedBand: currentEstimatedBand ?? predictedOverallBand ?? 6.5,
      targetBand: targetBand ?? 7.5,
      primaryWeakness: primaryWeakness ??
          (weaknessSummary?.isNotEmpty == true ? weaknessSummary!.first : 'Grammatical Accuracy'),
      aiCoachMessage: aiCoachMessage ?? aiCoachNotes ?? 'Focus on writing cohesion.',
      recommendedTopics: recommendedTopics ?? remediationTasks ?? const [],
      fiveTierPlan: fiveTierPlan?.toDomain() ?? FiveTierRecommendation.empty(),
    );
  }
}
