import '../../domain/entities/grammar_evaluation.dart';

class GrammarEvaluationModel extends GrammarEvaluation {
  const GrammarEvaluationModel({
    required super.isCorrect,
    super.originalSentence = '',
    super.correctedSentence = '',
    super.score = 100,
    super.errorType = 'General',
    super.explanation = '',
    super.ruleReference = '',
    super.suggestedExercises = const [],
  });

  factory GrammarEvaluationModel.fromJson(Map<String, dynamic> json) {
    final parsed = GrammarEvaluation.fromJson(json);
    return GrammarEvaluationModel(
      isCorrect: parsed.isCorrect,
      originalSentence: parsed.originalSentence,
      correctedSentence: parsed.correctedSentence,
      score: parsed.score,
      errorType: parsed.errorType,
      explanation: parsed.explanation,
      ruleReference: parsed.ruleReference,
      suggestedExercises: parsed.suggestedExercises,
    );
  }

  factory GrammarEvaluationModel.fromEntity(GrammarEvaluation entity) {
    return GrammarEvaluationModel(
      isCorrect: entity.isCorrect,
      originalSentence: entity.originalSentence,
      correctedSentence: entity.correctedSentence,
      score: entity.score,
      errorType: entity.errorType,
      explanation: entity.explanation,
      ruleReference: entity.ruleReference,
      suggestedExercises: entity.suggestedExercises,
    );
  }

  GrammarEvaluation toEntity() => this;
}
