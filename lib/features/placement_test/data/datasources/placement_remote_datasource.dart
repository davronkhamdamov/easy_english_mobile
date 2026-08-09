import 'dart:convert';
import '../../../../core/network/api_client.dart';
import '../models/placement_question_model.dart';
import '../models/placement_result_model.dart';
import '../../domain/entities/placement_question.dart';

class PlacementRemoteDatasource {
  final ApiClient _client;

  PlacementRemoteDatasource({ApiClient? client})
    : _client = client ?? ApiClient();

  /// Submits diagnostic placement test responses (POST /api/v1/placement/submit/)
  Future<PlacementResultModel> submitPlacementTest(
    Map<String, dynamic> answers,
  ) async {
    final response = await _client.post('/api/v1/placement/submit/', answers);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return PlacementResultModel.fromJson(json);
    } else {
      throw Exception(
        'Failed to submit placement test (${response.statusCode}): ${response.body}',
      );
    }
  }

  /// Fetches placement test diagnostic questions (GET /api/v1/placement/questions/)
  Future<List<PlacementQuestionModel>> fetchPlacementQuestions() async {
    try {
      final response = await _client.get('/api/v1/placement/questions/');
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data
            .map(
              (e) => PlacementQuestionModel.fromJson(e as Map<String, dynamic>),
            )
            .toList();
      }
    } catch (_) {}
    return PlacementQuestion.sampleQuestions
        .map((q) => PlacementQuestionModel.fromEntity(q))
        .toList();
  }
}
