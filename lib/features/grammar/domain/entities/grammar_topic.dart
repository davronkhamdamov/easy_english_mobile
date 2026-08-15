import 'grammar_exercise.dart';
import 'grammar_rule.dart';

enum GrammarTopicStatus { completed, current, locked }

class GrammarTopic {
  final String id;
  final String title;
  final String description;
  final String cefrLevel;
  final bool isCompleted;
  final double progressPercent;
  final GrammarTopicStatus status;
  final double masteryPercentage;
  final int orderIndex;
  final List<String> prerequisiteIds;
  final String iconName;
  final List<GrammarRule> rules;
  final List<GrammarExercise> exercises;

  const GrammarTopic({
    required this.id,
    required this.title,
    required this.description,
    required this.cefrLevel,
    this.isCompleted = false,
    this.progressPercent = 0.0,
    this.status = GrammarTopicStatus.locked,
    this.masteryPercentage = 0.0,
    this.orderIndex = 1,
    this.prerequisiteIds = const [],
    this.iconName = 'book',
    this.rules = const [],
    this.exercises = const [],
  });

  factory GrammarTopic.fromJson(Map<String, dynamic> json) {
    final isComp = json['is_completed'] as bool? ?? json['isCompleted'] as bool? ?? false;
    final pct = (json['progress_percent'] ?? json['progressPercent'] ?? json['mastery_percentage'] ?? json['masteryPercentage'] ?? 0) as num;
    final statusStr = json['status'] as String? ?? (isComp ? 'completed' : (pct > 0 ? 'current' : 'locked'));

    return GrammarTopic(
      id: json['id'] as String? ?? 'topic_1',
      title: json['title'] as String? ?? 'Grammar Topic',
      description: json['description'] as String? ?? '',
      cefrLevel: json['cefr_level'] as String? ?? json['cefrLevel'] as String? ?? 'A1',
      isCompleted: isComp,
      progressPercent: pct.toDouble(),
      status: _statusFromString(statusStr),
      masteryPercentage: pct.toDouble(),
      orderIndex: (json['order_index'] ?? json['orderIndex'] ?? 1) as int,
      prerequisiteIds: (json['prerequisite_ids'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      iconName: json['icon_name'] as String? ?? 'book',
      rules: (json['rules'] as List<dynamic>?)?.map((r) => GrammarRule.fromJson(r as Map<String, dynamic>)).toList() ?? [],
      exercises: (json['exercises'] as List<dynamic>?)?.map((e) => GrammarExercise.fromJson(e as Map<String, dynamic>)).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'cefr_level': cefrLevel,
      'is_completed': isCompleted,
      'progress_percent': progressPercent,
      'status': status.name,
      'mastery_percentage': masteryPercentage,
      'order_index': orderIndex,
      'prerequisite_ids': prerequisiteIds,
      'icon_name': iconName,
      'rules': rules.map((r) => r.toJson()).toList(),
      'exercises': exercises.map((e) => e.toJson()).toList(),
    };
  }

  static GrammarTopicStatus _statusFromString(String val) {
    switch (val.toLowerCase()) {
      case 'completed':
        return GrammarTopicStatus.completed;
      case 'current':
      case 'in_progress':
        return GrammarTopicStatus.current;
      case 'locked':
      default:
        return GrammarTopicStatus.locked;
    }
  }

  GrammarTopic copyWith({
    String? id,
    String? title,
    String? description,
    String? cefrLevel,
    bool? isCompleted,
    double? progressPercent,
    GrammarTopicStatus? status,
    double? masteryPercentage,
    int? orderIndex,
    List<String>? prerequisiteIds,
    String? iconName,
    List<GrammarRule>? rules,
    List<GrammarExercise>? exercises,
  }) {
    return GrammarTopic(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      cefrLevel: cefrLevel ?? this.cefrLevel,
      isCompleted: isCompleted ?? this.isCompleted,
      progressPercent: progressPercent ?? this.progressPercent,
      status: status ?? this.status,
      masteryPercentage: masteryPercentage ?? this.masteryPercentage,
      orderIndex: orderIndex ?? this.orderIndex,
      prerequisiteIds: prerequisiteIds ?? List.from(this.prerequisiteIds),
      iconName: iconName ?? this.iconName,
      rules: rules ?? List.from(this.rules),
      exercises: exercises ?? List.from(this.exercises),
    );
  }
}
