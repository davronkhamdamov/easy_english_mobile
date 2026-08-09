import 'grammar_exercise.dart';
import 'grammar_rule.dart';

enum GrammarTopicStatus { completed, current, locked }

extension GrammarTopicStatusExtension on GrammarTopicStatus {
  String get value {
    switch (this) {
      case GrammarTopicStatus.completed:
        return 'completed';
      case GrammarTopicStatus.current:
        return 'current';
      case GrammarTopicStatus.locked:
        return 'locked';
    }
  }

  static GrammarTopicStatus fromString(String val) {
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
}

class GrammarTopic {
  final String id;
  final String title;
  final String description;
  final String cefrLevel;
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
    required this.status,
    required this.masteryPercentage,
    required this.orderIndex,
    required this.prerequisiteIds,
    required this.iconName,
    required this.rules,
    required this.exercises,
  });

  GrammarTopic copyWith({
    String? id,
    String? title,
    String? description,
    String? cefrLevel,
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
