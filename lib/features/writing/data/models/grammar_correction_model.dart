import '../../domain/entities/writing_evaluation.dart';

class GrammarCorrectionModel {
  final String original;
  final String corrected;
  final String explanation;

  GrammarCorrectionModel({
    required this.original,
    required this.corrected,
    required this.explanation,
  });

  factory GrammarCorrectionModel.fromJson(Map<String, dynamic> json) {
    return GrammarCorrectionModel(
      original: (json['original'] ?? '').toString(),
      corrected: (json['corrected'] ?? '').toString(),
      explanation: (json['explanation'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'original': original,
      'corrected': corrected,
      'explanation': explanation,
    };
  }

  GrammarCorrection toEntity() {
    return GrammarCorrection(
      original: original,
      corrected: corrected,
      explanation: explanation,
    );
  }
}
