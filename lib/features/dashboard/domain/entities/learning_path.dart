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
}

class LearningPathResponse {
  final DailyPlan todayPlan;
  final DailyPlan tomorrowPlan;

  const LearningPathResponse({
    required this.todayPlan,
    required this.tomorrowPlan,
  });
}
