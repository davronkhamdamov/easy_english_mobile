class DailyTask {
  final String id;
  final String moduleType;
  final String title;
  final String description;
  final int durationMinutes;
  final String targetObjective;
  final bool isCompleted;
  final String actionRoute;

  const DailyTask({
    required this.id,
    required this.moduleType,
    required this.title,
    required this.description,
    required this.durationMinutes,
    required this.targetObjective,
    required this.isCompleted,
    required this.actionRoute,
  });

  factory DailyTask.fromJson(Map<String, dynamic> json) {
    return DailyTask(
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

  DailyTask copyWith({bool? isCompleted}) {
    return DailyTask(
      id: id,
      moduleType: moduleType,
      title: title,
      description: description,
      durationMinutes: durationMinutes,
      targetObjective: targetObjective,
      isCompleted: isCompleted ?? this.isCompleted,
      actionRoute: actionRoute,
    );
  }
}

class DailyPlan {
  final String date;
  final String focusSkill;
  final int dailyGoalMinutes;
  final List<DailyTask> tasks;
  final int totalEstimatedMinutes;
  final int completedTasksCount;
  final int totalTasksCount;
  final double completionPercentage;

  const DailyPlan({
    required this.date,
    required this.focusSkill,
    required this.dailyGoalMinutes,
    required this.tasks,
    required this.totalEstimatedMinutes,
    required this.completedTasksCount,
    required this.totalTasksCount,
    required this.completionPercentage,
  });

  factory DailyPlan.fromJson(Map<String, dynamic> json) {
    final rawTasks = json['tasks'] as List<dynamic>? ?? [];
    final tasksList = rawTasks.map((e) => DailyTask.fromJson(e as Map<String, dynamic>)).toList();

    return DailyPlan(
      date: json['date'] as String? ?? '',
      focusSkill: json['focus_skill'] as String? ?? 'General Practice',
      dailyGoalMinutes: (json['daily_goal_minutes'] as num?)?.toInt() ?? 30,
      tasks: tasksList,
      totalEstimatedMinutes: (json['total_estimated_minutes'] as num?)?.toInt() ?? 30,
      completedTasksCount: (json['completed_tasks_count'] as num?)?.toInt() ?? 0,
      totalTasksCount: (json['total_tasks_count'] as num?)?.toInt() ?? tasksList.length,
      completionPercentage: (json['completion_percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class LearningPathResponse {
  final DailyPlan todayPlan;
  final DailyPlan tomorrowPlan;

  const LearningPathResponse({
    required this.todayPlan,
    required this.tomorrowPlan,
  });

  factory LearningPathResponse.fromJson(Map<String, dynamic> json) {
    return LearningPathResponse(
      todayPlan: DailyPlan.fromJson(json['today'] as Map<String, dynamic>? ?? {}),
      tomorrowPlan: DailyPlan.fromJson(json['tomorrow'] as Map<String, dynamic>? ?? {}),
    );
  }
}
