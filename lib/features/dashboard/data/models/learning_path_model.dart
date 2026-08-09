import '../../domain/entities/learning_path.dart';

class DailyTaskModel extends DailyTask {
  const DailyTaskModel({
    required super.id,
    required super.moduleType,
    required super.title,
    required super.description,
    required super.durationMinutes,
    required super.targetObjective,
    required super.isCompleted,
    required super.actionRoute,
  });

  factory DailyTaskModel.fromJson(Map<String, dynamic> json) {
    return DailyTaskModel(
      id: json['id'] as String? ?? '',
      moduleType: json['module_type'] as String? ?? 'general',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      durationMinutes: (json['duration_minutes'] as num?)?.toInt() ?? 10,
      targetObjective: json['target_objective'] as String? ?? '',
      isCompleted: json['is_completed'] as bool? ?? false,
      actionRoute: json['action_route'] as String? ?? '',
    );
  }

  DailyTask toEntity() {
    return DailyTask(
      id: id,
      moduleType: moduleType,
      title: title,
      description: description,
      durationMinutes: durationMinutes,
      targetObjective: targetObjective,
      isCompleted: isCompleted,
      actionRoute: actionRoute,
    );
  }
}

class DailyPlanModel extends DailyPlan {
  const DailyPlanModel({
    required super.date,
    required super.focusSkill,
    required super.dailyGoalMinutes,
    required super.tasks,
    required super.totalEstimatedMinutes,
    required super.completedTasksCount,
    required super.totalTasksCount,
    required super.completionPercentage,
  });

  factory DailyPlanModel.fromJson(Map<String, dynamic> json) {
    final rawTasks = json['tasks'] as List<dynamic>? ?? [];
    final tasksList = rawTasks
        .map((e) => DailyTaskModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return DailyPlanModel(
      date: json['date'] as String? ?? '',
      focusSkill: json['focus_skill'] as String? ?? 'General Practice',
      dailyGoalMinutes: (json['daily_goal_minutes'] as num?)?.toInt() ?? 30,
      tasks: tasksList,
      totalEstimatedMinutes:
          (json['total_estimated_minutes'] as num?)?.toInt() ?? 30,
      completedTasksCount:
          (json['completed_tasks_count'] as num?)?.toInt() ?? 0,
      totalTasksCount:
          (json['total_tasks_count'] as num?)?.toInt() ?? tasksList.length,
      completionPercentage:
          (json['completion_percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }

  DailyPlan toEntity() {
    return DailyPlan(
      date: date,
      focusSkill: focusSkill,
      dailyGoalMinutes: dailyGoalMinutes,
      tasks: tasks,
      totalEstimatedMinutes: totalEstimatedMinutes,
      completedTasksCount: completedTasksCount,
      totalTasksCount: totalTasksCount,
      completionPercentage: completionPercentage,
    );
  }
}

class LearningPathResponseModel extends LearningPathResponse {
  const LearningPathResponseModel({
    required super.todayPlan,
    required super.tomorrowPlan,
  });

  factory LearningPathResponseModel.fromJson(Map<String, dynamic> json) {
    return LearningPathResponseModel(
      todayPlan: DailyPlanModel.fromJson(
        json['today'] as Map<String, dynamic>? ?? {},
      ),
      tomorrowPlan: DailyPlanModel.fromJson(
        json['tomorrow'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  LearningPathResponse toEntity() {
    return LearningPathResponse(
      todayPlan: todayPlan,
      tomorrowPlan: tomorrowPlan,
    );
  }
}
