import '../../domain/entities/study_plan_recommendation.dart';
import 'daily_schedule_item_model.dart';

class StudyPlanRecommendationModel {
  final double currentOverallBand;
  final double targetBand;
  final int recommendedDailyMinutes;
  final int estimatedWeeksToTarget;
  final List<String> focusAreas;
  final List<DailyScheduleItemModel> weeklySchedule;
  final List<String> keyMilestones;

  StudyPlanRecommendationModel({
    required this.currentOverallBand,
    required this.targetBand,
    required this.recommendedDailyMinutes,
    required this.estimatedWeeksToTarget,
    required this.focusAreas,
    required this.weeklySchedule,
    required this.keyMilestones,
  });

  factory StudyPlanRecommendationModel.fromJson(Map<String, dynamic> json) {
    return StudyPlanRecommendationModel(
      currentOverallBand:
          (json['current_overall_band'] as num?)?.toDouble() ?? 6.0,
      targetBand: (json['target_band'] as num?)?.toDouble() ?? 7.5,
      recommendedDailyMinutes:
          (json['recommended_daily_minutes'] as num?)?.toInt() ?? 45,
      estimatedWeeksToTarget:
          (json['estimated_weeks_to_target'] as num?)?.toInt() ?? 8,
      focusAreas:
          (json['focus_areas'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      weeklySchedule:
          (json['weekly_schedule'] as List<dynamic>?)
              ?.map(
                (item) => DailyScheduleItemModel.fromJson(
                  item as Map<String, dynamic>,
                ),
              )
              .toList() ??
          [],
      keyMilestones:
          (json['key_milestones'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_overall_band': currentOverallBand,
      'target_band': targetBand,
      'recommended_daily_minutes': recommendedDailyMinutes,
      'estimated_weeks_to_target': estimatedWeeksToTarget,
      'focus_areas': focusAreas,
      'weekly_schedule': weeklySchedule.map((s) => s.toJson()).toList(),
      'key_milestones': keyMilestones,
    };
  }

  StudyPlanRecommendation toEntity() {
    return StudyPlanRecommendation(
      currentOverallBand: currentOverallBand,
      targetBand: targetBand,
      recommendedDailyMinutes: recommendedDailyMinutes,
      estimatedWeeksToTarget: estimatedWeeksToTarget,
      focusAreas: focusAreas,
      weeklySchedule: weeklySchedule.map((s) => s.toEntity()).toList(),
      keyMilestones: keyMilestones,
    );
  }

  factory StudyPlanRecommendationModel.fromEntity(
    StudyPlanRecommendation entity,
  ) {
    return StudyPlanRecommendationModel(
      currentOverallBand: entity.currentOverallBand,
      targetBand: entity.targetBand,
      recommendedDailyMinutes: entity.recommendedDailyMinutes,
      estimatedWeeksToTarget: entity.estimatedWeeksToTarget,
      focusAreas: entity.focusAreas,
      weeklySchedule: entity.weeklySchedule
          .map((s) => DailyScheduleItemModel.fromEntity(s))
          .toList(),
      keyMilestones: entity.keyMilestones,
    );
  }
}
