import '../../domain/entities/grammar_exercise.dart';

class GrammarExerciseModel extends GrammarExercise {
  const GrammarExerciseModel({
    required super.id,
    super.topicId = '',
    super.ruleId = '',
    super.type = ExerciseType.multipleChoice,
    required super.prompt,
    super.sentenceWithBlank,
    super.options = const [],
    required super.correctAnswer,
    required super.explanation,
    super.difficultyScore = 1,
  });

  factory GrammarExerciseModel.fromJson(Map<String, dynamic> json) {
    final parsed = GrammarExercise.fromJson(json);
    return GrammarExerciseModel(
      id: parsed.id,
      topicId: parsed.topicId,
      ruleId: parsed.ruleId,
      type: parsed.type,
      prompt: parsed.prompt,
      sentenceWithBlank: parsed.sentenceWithBlank,
      options: parsed.options,
      correctAnswer: parsed.correctAnswer,
      explanation: parsed.explanation,
      difficultyScore: parsed.difficultyScore,
    );
  }

  factory GrammarExerciseModel.fromEntity(GrammarExercise entity) {
    return GrammarExerciseModel(
      id: entity.id,
      topicId: entity.topicId,
      ruleId: entity.ruleId,
      type: entity.type,
      prompt: entity.prompt,
      sentenceWithBlank: entity.sentenceWithBlank,
      options: entity.options,
      correctAnswer: entity.correctAnswer,
      explanation: entity.explanation,
      difficultyScore: entity.difficultyScore,
    );
  }

  GrammarExercise toEntity() => this;
}
