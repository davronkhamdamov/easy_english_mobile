import '../../domain/entities/study_plan_recommendation.dart';

class DailyScheduleItemModel {
  final String day;
  final String focusSkill;
  final int durationMinutes;
  final String topic;
  final String action;

  DailyScheduleItemModel({
    required this.day,
    required this.focusSkill,
    required this.durationMinutes,
    required this.topic,
    required this.action,
  });

  factory DailyScheduleItemModel.fromJson(Map<String, dynamic> json) {
    return DailyScheduleItemModel(
      day: json['day'] as String? ?? 'Day 1',
      focusSkill: json['focus_skill'] as String? ?? 'Reading',
      durationMinutes: (json['duration_minutes'] ?? 30) as int,
      topic: json['topic'] as String? ?? '',
      action: json['action'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'focus_skill': focusSkill,
      'duration_minutes': durationMinutes,
      'topic': topic,
      'action': action,
    };
  }

  DailyScheduleItem toEntity() {
    return DailyScheduleItem(
      day: day,
      focusSkill: focusSkill,
      durationMinutes: durationMinutes,
      topic: topic,
      action: action,
    );
  }

  factory DailyScheduleItemModel.fromEntity(DailyScheduleItem entity) {
    return DailyScheduleItemModel(
      day: entity.day,
      focusSkill: entity.focusSkill,
      durationMinutes: entity.durationMinutes,
      topic: entity.topic,
      action: entity.action,
    );
  }
}
