enum ExerciseType { multipleChoice, fillInTheBlank }

typedef GrammarExerciseType = ExerciseType;

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
  final int difficultyScore;

  const GrammarExercise({
    required this.id,
    this.topicId = '',
    this.ruleId = '',
    this.type = ExerciseType.multipleChoice,
    required this.prompt,
    this.sentenceWithBlank,
    this.options = const [],
    required this.correctAnswer,
    required this.explanation,
    this.difficultyScore = 1,
  });

  factory GrammarExercise.fromJson(Map<String, dynamic> json) {
    return GrammarExercise(
      id: json['id'] as String? ?? 'ex_1',
      topicId: json['topic_id'] as String? ?? json['topicId'] as String? ?? '',
      ruleId: json['rule_id'] as String? ?? json['ruleId'] as String? ?? '',
      type: ExerciseTypeExtension.fromString(json['type'] as String? ?? 'multiple_choice'),
      prompt: json['prompt'] as String? ?? '',
      sentenceWithBlank: json['sentence_with_blank'] as String? ?? json['sentenceWithBlank'] as String?,
      options: (json['options'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      correctAnswer: json['correct_answer'] as String? ?? json['correctAnswer'] as String? ?? '',
      explanation: json['explanation'] as String? ?? '',
      difficultyScore: (json['difficulty_score'] ?? json['difficultyScore'] ?? 1) as int,
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
      'difficulty_score': difficultyScore,
    };
  }

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
    int? difficultyScore,
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
      difficultyScore: difficultyScore ?? this.difficultyScore,
    );
  }
}
