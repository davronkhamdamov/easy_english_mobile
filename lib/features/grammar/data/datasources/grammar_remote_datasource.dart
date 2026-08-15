import 'dart:convert';
import '../../../../core/network/api_client.dart';
import '../models/grammar_evaluation_model.dart';
import '../models/grammar_mistake_model.dart';
import '../models/grammar_topic_model.dart';

abstract class GrammarRemoteDataSource {
  Future<GrammarEvaluationModel> evaluateSentence({
    required String sentence,
    String? targetWord,
  });
  Future<List<GrammarTopicModel>> fetchRoadmapTopics();
  Future<List<GrammarMistakeRecordModel>> fetchMistakeRecords();
}

class GrammarRemoteDataSourceImpl implements GrammarRemoteDataSource {
  final ApiClient _client;

  GrammarRemoteDataSourceImpl({ApiClient? client})
      : _client = client ?? ApiClient();

  @override
  Future<GrammarEvaluationModel> evaluateSentence({
    required String sentence,
    String? targetWord,
  }) async {
    final body = {
      'user_sentence': sentence,
      if (targetWord != null && targetWord.isNotEmpty) 'target_word': targetWord,
    };

    final response = await _client.post('/api/v1/grammar/evaluate/', body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonMap = jsonDecode(response.body) as Map<String, dynamic>;
      return GrammarEvaluationModel.fromJson(jsonMap);
    } else {
      throw Exception('Failed to evaluate grammar sentence: ${response.statusCode}');
    }
  }

  @override
  Future<List<GrammarTopicModel>> fetchRoadmapTopics() async {
    final response = await _client.get('/api/v1/grammar/topics');

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body) as List<dynamic>;
      return jsonList
          .map((json) => GrammarTopicModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to fetch grammar topics: ${response.statusCode}');
    }
  }

  @override
  Future<List<GrammarMistakeRecordModel>> fetchMistakeRecords() async {
    final response = await _client.get('/api/v1/grammar/mistakes');

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body) as List<dynamic>;
      return jsonList
          .map((json) => GrammarMistakeRecordModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to fetch grammar mistakes: ${response.statusCode}');
    }
  }
}
