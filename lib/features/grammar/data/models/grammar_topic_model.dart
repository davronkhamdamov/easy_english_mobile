import '../../domain/entities/grammar_topic.dart';
import 'grammar_exercise_model.dart';
import 'grammar_rule_model.dart';

class GrammarTopicModel {
  final String id;
  final String title;
  final String description;
  final String cefrLevel;
  final GrammarTopicStatus status;
  final double masteryPercentage;
  final int orderIndex;
  final List<String> prerequisiteIds;
  final String iconName;
  final List<GrammarRuleModel> rules;
  final List<GrammarExerciseModel> exercises;

  const GrammarTopicModel({
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

  factory GrammarTopicModel.fromJson(Map<String, dynamic> json) {
    return GrammarTopicModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      cefrLevel: json['cefr_level'] as String? ?? 'B1',
      status: GrammarTopicStatusExtension.fromString(
        json['status'] as String? ?? 'locked',
      ),
      masteryPercentage: (json['mastery_percentage'] as num? ?? 0.0).toDouble(),
      orderIndex: json['order_index'] as int? ?? 0,
      prerequisiteIds: List<String>.from(
        json['prerequisite_ids'] as List? ?? [],
      ),
      iconName: json['icon_name'] as String? ?? 'book',
      rules: (json['rules'] as List? ?? [])
          .map((r) => GrammarRuleModel.fromJson(r as Map<String, dynamic>))
          .toList(),
      exercises: (json['exercises'] as List? ?? [])
          .map((e) => GrammarExerciseModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'cefr_level': cefrLevel,
      'status': status.value,
      'mastery_percentage': masteryPercentage,
      'order_index': orderIndex,
      'prerequisite_ids': prerequisiteIds,
      'icon_name': iconName,
      'rules': rules.map((r) => r.toJson()).toList(),
      'exercises': exercises.map((e) => e.toJson()).toList(),
    };
  }

  GrammarTopic toEntity() {
    return GrammarTopic(
      id: id,
      title: title,
      description: description,
      cefrLevel: cefrLevel,
      status: status,
      masteryPercentage: masteryPercentage,
      orderIndex: orderIndex,
      prerequisiteIds: prerequisiteIds,
      iconName: iconName,
      rules: rules.map((r) => r.toEntity()).toList(),
      exercises: exercises.map((e) => e.toEntity()).toList(),
    );
  }

  factory GrammarTopicModel.fromEntity(GrammarTopic entity) {
    return GrammarTopicModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      cefrLevel: entity.cefrLevel,
      status: entity.status,
      masteryPercentage: entity.masteryPercentage,
      orderIndex: entity.orderIndex,
      prerequisiteIds: entity.prerequisiteIds,
      iconName: entity.iconName,
      rules: entity.rules.map((r) => GrammarRuleModel.fromEntity(r)).toList(),
      exercises: entity.exercises
          .map((e) => GrammarExerciseModel.fromEntity(e))
          .toList(),
    );
  }
}
