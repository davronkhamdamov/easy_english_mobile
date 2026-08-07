import 'dart:convert';
import '../../../core/auth/api_client.dart';

class WritingEvaluationResult {
  final double overallBandScore;
  final double taskAchievementScore;
  final double coherenceCohesionScore;
  final double lexicalResourceScore;
  final double grammaticalRangeScore;
  final List<String> strengths;
  final List<String> weaknesses;
  final List<String> grammarCorrections;
  final String improvedSample;

  WritingEvaluationResult({
    required this.overallBandScore,
    required this.taskAchievementScore,
    required this.coherenceCohesionScore,
    required this.lexicalResourceScore,
    required this.grammaticalRangeScore,
    required this.strengths,
    required this.weaknesses,
    required this.grammarCorrections,
    required this.improvedSample,
  });

  static List<String> _parseStringList(dynamic raw) {
    if (raw is List) {
      return raw.map((e) => e.toString()).toList();
    }
    return <String>[];
  }

  factory WritingEvaluationResult.fromJson(Map<String, dynamic> json) {
    return WritingEvaluationResult(
      overallBandScore: (json['overall_band'] ?? json['overall_band_score'] as num?)?.toDouble() ?? 7.0,
      taskAchievementScore: (json['task_achievement_band'] ?? json['task_achievement_score'] ?? json['task_achievement'] as num?)?.toDouble() ?? 7.0,
      coherenceCohesionScore: (json['coherence_cohesion_band'] ?? json['coherence_cohesion_score'] ?? json['coherence_cohesion'] as num?)?.toDouble() ?? 7.0,
      lexicalResourceScore: (json['lexical_resource_band'] ?? json['lexical_resource_score'] ?? json['lexical_resource'] as num?)?.toDouble() ?? 7.0,
      grammaticalRangeScore: (json['grammar_accuracy_band'] ?? json['grammatical_range_score'] ?? json['grammar_accuracy'] as num?)?.toDouble() ?? 7.0,
      strengths: _parseStringList(json['strengths']),
      weaknesses: _parseStringList(json['weaknesses']),
      grammarCorrections: _parseStringList(json['grammar_corrections'] ?? json['grammar_errors']),
      improvedSample: (json['improved_sample'] ?? json['model_answer'] ?? '').toString(),
    );
  }
}

class WritingEvaluationService {
  final ApiClient _client = ApiClient();

  /// Submits IELTS essay for AI evaluation (POST /api/v1/writing/evaluate/)
  Future<WritingEvaluationResult> evaluateEssay({
    required String essayText,
    required String prompt,
    String taskType = 'task2',
  }) async {
    final response = await _client.post('/api/v1/writing/evaluate/', {
      'essay_text': essayText,
      'prompt': prompt,
      'task_type': taskType,
    });

    if (response.statusCode == 200 || response.statusCode == 201) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return WritingEvaluationResult.fromJson(json);
    } else {
      throw Exception('Failed to evaluate essay (${response.statusCode}): ${response.body}');
    }
  }
}
