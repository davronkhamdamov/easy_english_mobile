import '../../domain/entities/grammar_exercise.dart';

class GrammarExerciseModel {
  final String id;
  final String topicId;
  final String ruleId;
  final ExerciseType type;
  final String prompt;
  final String? sentenceWithBlank;
  final List<String> options;
  final String correctAnswer;
  final String explanation;
  final ExerciseDifficulty difficulty;

  const GrammarExerciseModel({
    required this.id,
    required this.topicId,
    required this.ruleId,
    required this.type,
    required this.prompt,
    this.sentenceWithBlank,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    this.difficulty = ExerciseDifficulty.medium,
  });

  factory GrammarExerciseModel.fromJson(Map<String, dynamic> json) {
    return GrammarExerciseModel(
      id: json['id'] as String? ?? '',
      topicId: json['topic_id'] as String? ?? '',
      ruleId: json['rule_id'] as String? ?? '',
      type: ExerciseTypeExtension.fromString(
        json['type'] as String? ?? 'multiple_choice',
      ),
      prompt: json['prompt'] as String? ?? '',
      sentenceWithBlank: json['sentence_with_blank'] as String?,
      options: List<String>.from(json['options'] as List? ?? []),
      correctAnswer: json['correct_answer'] as String? ?? '',
      explanation: json['explanation'] as String? ?? '',
      difficulty: ExerciseDifficultyExtension.fromString(
        json['difficulty'] as String? ?? 'medium',
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'topic_id': topicId,
      'rule_id': ruleId,
      'type': type.value,
      'prompt': prompt,
      'sentence_with_blank': sentenceWithBlank,
      'options': options,
      'correct_answer': correctAnswer,
      'explanation': explanation,
      'difficulty': difficulty.value,
    };
  }

  GrammarExercise toEntity() {
    return GrammarExercise(
      id: id,
      topicId: topicId,
      ruleId: ruleId,
      type: type,
      prompt: prompt,
      sentenceWithBlank: sentenceWithBlank,
      options: options,
      correctAnswer: correctAnswer,
      explanation: explanation,
      difficulty: difficulty,
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
      difficulty: entity.difficulty,
    );
  }
}
