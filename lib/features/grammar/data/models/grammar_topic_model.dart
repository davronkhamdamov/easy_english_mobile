import '../../domain/entities/grammar_topic.dart';

class GrammarTopicModel extends GrammarTopic {
  const GrammarTopicModel({
    required super.id,
    required super.title,
    required super.description,
    required super.cefrLevel,
    super.isCompleted = false,
    super.progressPercent = 0.0,
    super.status = GrammarTopicStatus.locked,
    super.masteryPercentage = 0.0,
    super.orderIndex = 1,
    super.prerequisiteIds = const [],
    super.iconName = 'book',
    super.rules = const [],
    super.exercises = const [],
  });

  factory GrammarTopicModel.fromJson(Map<String, dynamic> json) {
    final parsed = GrammarTopic.fromJson(json);
    return GrammarTopicModel(
      id: parsed.id,
      title: parsed.title,
      description: parsed.description,
      cefrLevel: parsed.cefrLevel,
      isCompleted: parsed.isCompleted,
      progressPercent: parsed.progressPercent,
      status: parsed.status,
      masteryPercentage: parsed.masteryPercentage,
      orderIndex: parsed.orderIndex,
      prerequisiteIds: parsed.prerequisiteIds,
      iconName: parsed.iconName,
      rules: parsed.rules,
      exercises: parsed.exercises,
    );
  }

  factory GrammarTopicModel.fromEntity(GrammarTopic entity) {
    return GrammarTopicModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      cefrLevel: entity.cefrLevel,
      isCompleted: entity.isCompleted,
      progressPercent: entity.progressPercent,
      status: entity.status,
      masteryPercentage: entity.masteryPercentage,
      orderIndex: entity.orderIndex,
      prerequisiteIds: entity.prerequisiteIds,
      iconName: entity.iconName,
      rules: entity.rules,
      exercises: entity.exercises,
    );
  }

  GrammarTopic toEntity() => this;
}
