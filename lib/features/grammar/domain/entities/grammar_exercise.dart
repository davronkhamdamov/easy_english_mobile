enum ExerciseType { multipleChoice, fillInTheBlank }

extension ExerciseTypeExtension on ExerciseType {
  String get value {
    switch (this) {
      case ExerciseType.multipleChoice:
        return 'multiple_choice';
      case ExerciseType.fillInTheBlank:
        return 'fill_in_the_blank';
    }
  }

  static ExerciseType fromString(String val) {
    switch (val.toLowerCase()) {
      case 'fill_in_the_blank':
      case 'fill_blank':
        return ExerciseType.fillInTheBlank;
      case 'multiple_choice':
      default:
        return ExerciseType.multipleChoice;
    }
  }
}

enum ExerciseDifficulty { easy, medium, hard }

extension ExerciseDifficultyExtension on ExerciseDifficulty {
  String get value {
    switch (this) {
      case ExerciseDifficulty.easy:
        return 'easy';
      case ExerciseDifficulty.medium:
        return 'medium';
      case ExerciseDifficulty.hard:
        return 'hard';
    }
  }

  static ExerciseDifficulty fromString(String val) {
    switch (val.toLowerCase()) {
      case 'hard':
        return ExerciseDifficulty.hard;
      case 'medium':
        return ExerciseDifficulty.medium;
      case 'easy':
      default:
        return ExerciseDifficulty.easy;
    }
  }
}

class GrammarExercise {
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

  const GrammarExercise({
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

  GrammarExercise copyWith({
    String? id,
    String? topicId,
    String? ruleId,
    ExerciseType? type,
    String? prompt,
    String? sentenceWithBlank,
    List<String>? options,
    String? correctAnswer,
    String? explanation,
    ExerciseDifficulty? difficulty,
  }) {
    return GrammarExercise(
      id: id ?? this.id,
      topicId: topicId ?? this.topicId,
      ruleId: ruleId ?? this.ruleId,
      type: type ?? this.type,
      prompt: prompt ?? this.prompt,
      sentenceWithBlank: sentenceWithBlank ?? this.sentenceWithBlank,
      options: options ?? List.from(this.options),
      correctAnswer: correctAnswer ?? this.correctAnswer,
      explanation: explanation ?? this.explanation,
      difficulty: difficulty ?? this.difficulty,
    );
  }
}
