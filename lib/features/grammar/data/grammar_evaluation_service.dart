import 'dart:convert';
import '../../../core/auth/api_client.dart';

class GrammarEvaluationResult {
  final bool isCorrect;
  final String feedback;
  final List<String> corrections;
  final List<String> modelExpressions;

  GrammarEvaluationResult({
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

  factory GrammarEvaluationResult.fromJson(Map<String, dynamic> json) {
    return GrammarEvaluationResult(
      isCorrect: json['is_correct'] as bool? ?? false,
      feedback: (json['feedback'] ?? json['explanation'] ?? '').toString(),
      corrections: _parseStringList(json['corrections'] ?? json['grammar_corrections']),
      modelExpressions: _parseStringList(json['band_8_expressions'] ?? json['model_expressions']),
    );
  }
}

class GrammarEvaluationService {
  final ApiClient _client = ApiClient();

  /// Submits sentence for Grammar Error Evaluation (POST /api/v1/grammar/evaluate/)
  Future<GrammarEvaluationResult> evaluateSentence({
    required String sentence,
    String? targetWord,
  }) async {
    final response = await _client.post('/api/v1/grammar/evaluate/', {
      'user_sentence': sentence,
      'sentence': sentence,
      if (targetWord != null && targetWord.isNotEmpty) 'target_word': targetWord,
    });

    if (response.statusCode == 200 || response.statusCode == 201) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return GrammarEvaluationResult.fromJson(json);
    } else {
      throw Exception('Failed to evaluate grammar (${response.statusCode}): ${response.body}');
    }
  }
}
