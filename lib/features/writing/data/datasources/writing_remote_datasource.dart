import 'dart:convert';
import '../../../../core/network/api_client.dart';
import '../models/writing_evaluation_model.dart';
import '../models/writing_prompt_model.dart';

class WritingRemoteDatasource {
  final ApiClient _client;

  WritingRemoteDatasource({ApiClient? client})
      : _client = client ?? ApiClient();

  /// Submits IELTS essay for AI evaluation (POST /api/v1/writing/evaluate/)
  Future<WritingEvaluationModel> evaluateEssay({
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
      return WritingEvaluationModel.fromJson(json);
    } else {
      throw Exception(
        'Failed to evaluate essay (${response.statusCode}): ${response.body}',
      );
    }
  }

  /// Fetches IELTS writing prompts (GET /api/v1/content/writing-prompts/)
  Future<List<WritingPromptModel>> fetchWritingPrompts() async {
    final response = await _client.get('/api/v1/content/writing-prompts/');

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data
          .map((e) => WritingPromptModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception(
        'Failed to fetch writing prompts (${response.statusCode}): ${response.body}',
      );
    }
  }
}
