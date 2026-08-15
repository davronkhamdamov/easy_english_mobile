/// Domain entity representing a Grammar sentence evaluation result.
class GrammarEvaluation {
  final bool isCorrect;
  final String originalSentence;
  final String correctedSentence;
  final int score;
  final String errorType;
  final String explanation;
  final String ruleReference;
  final List<String> suggestedExercises;

  const GrammarEvaluation({
    required this.isCorrect,
    this.originalSentence = '',
    this.correctedSentence = '',
    this.score = 100,
    this.errorType = 'General',
    this.explanation = '',
    this.ruleReference = '',
    this.suggestedExercises = const [],
  });

  // Legacy getters
  String get feedback => explanation;
  List<String> get corrections => [correctedSentence];
  List<String> get modelExpressions => suggestedExercises;

  factory GrammarEvaluation.fromJson(Map<String, dynamic> json) {
    return GrammarEvaluation(
      isCorrect: json['is_correct'] as bool? ?? json['isCorrect'] as bool? ?? false,
      originalSentence: json['original_sentence'] as String? ?? json['originalSentence'] as String? ?? '',
      correctedSentence: json['corrected_sentence'] as String? ?? json['correctedSentence'] as String? ?? '',
      score: (json['score'] ?? 0) as int,
      errorType: json['error_type'] as String? ?? json['errorType'] as String? ?? 'General',
      explanation: json['explanation'] as String? ?? json['feedback'] as String? ?? '',
      ruleReference: json['rule_reference'] as String? ?? json['ruleReference'] as String? ?? '',
      suggestedExercises: (json['suggested_exercises'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_correct': isCorrect,
      'original_sentence': originalSentence,
      'corrected_sentence': correctedSentence,
      'score': score,
      'error_type': errorType,
      'explanation': explanation,
      'rule_reference': ruleReference,
      'suggested_exercises': suggestedExercises,
    };
  }
}
