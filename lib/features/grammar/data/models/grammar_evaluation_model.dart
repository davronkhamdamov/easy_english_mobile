import '../../domain/entities/grammar_evaluation.dart';

class GrammarEvaluationModel {
  final bool isCorrect;
  final String feedback;
  final List<String> corrections;
  final List<String> modelExpressions;

  GrammarEvaluationModel({
    required this.isCorrect,
    required this.feedback,
    required this.corrections,
    required this.modelExpressions,
  });

  static List<String> _parseStringList(dynamic raw) {
    if (raw is List) {
      return raw.map((e) => e.toString()).toList();
    }
    return <String>[];
  }

  factory GrammarEvaluationModel.fromJson(Map<String, dynamic> json) {
    return GrammarEvaluationModel(
      isCorrect: json['is_correct'] as bool? ?? false,
      feedback: (json['feedback'] ?? json['explanation'] ?? '').toString(),
      corrections: _parseStringList(
        json['corrections'] ?? json['grammar_corrections'],
      ),
      modelExpressions: _parseStringList(
        json['band_8_expressions'] ?? json['model_expressions'],
      ),
    );
  }

  GrammarEvaluation toEntity() {
    return GrammarEvaluation(
      isCorrect: isCorrect,
      feedback: feedback,
      corrections: corrections,
      modelExpressions: modelExpressions,
    );
  }
}
