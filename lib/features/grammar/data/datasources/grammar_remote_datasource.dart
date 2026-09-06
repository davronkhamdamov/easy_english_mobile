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
      final decoded = jsonDecode(response.body);
      final Map<String, dynamic> jsonMap;
      if (decoded is Map) {
        if (decoded['data'] is Map) {
          jsonMap = Map<String, dynamic>.from(decoded['data'] as Map);
        } else if (decoded['evaluation'] is Map) {
          jsonMap = Map<String, dynamic>.from(decoded['evaluation'] as Map);
        } else if (decoded['result'] is Map) {
          jsonMap = Map<String, dynamic>.from(decoded['result'] as Map);
        } else {
          jsonMap = Map<String, dynamic>.from(decoded);
        }
      } else {
        throw Exception('Invalid response format for grammar evaluation');
      }
      return GrammarEvaluationModel.fromJson(jsonMap);
    } else {
      throw Exception('Failed to evaluate grammar sentence: ${response.statusCode}');
    }
  }

  @override
  Future<List<GrammarTopicModel>> fetchRoadmapTopics() async {
    final response = await _client.get('/api/v1/grammar/topics');

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final List<dynamic> jsonList = _extractList(decoded, const ['topics', 'results', 'data', 'items']);
      return jsonList
          .whereType<Map>()
          .map((json) => GrammarTopicModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    } else {
      throw Exception('Failed to fetch grammar topics: ${response.statusCode}');
    }
  }

  @override
  Future<List<GrammarMistakeRecordModel>> fetchMistakeRecords() async {
    final response = await _client.get('/api/v1/grammar/mistakes');

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final List<dynamic> jsonList = _extractList(decoded, const ['mistakes', 'results', 'data', 'items', 'records']);
      return jsonList
          .whereType<Map>()
          .map((json) => GrammarMistakeRecordModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    } else {
      throw Exception('Failed to fetch grammar mistakes: ${response.statusCode}');
    }
  }

  List<dynamic> _extractList(dynamic decoded, List<String> preferredKeys) {
    if (decoded is List) {
      return decoded;
    }
    if (decoded is Map) {
      for (final key in preferredKeys) {
        if (decoded[key] is List) {
          return decoded[key] as List<dynamic>;
        }
      }
      for (final value in decoded.values) {
        if (value is List) {
          return value;
        }
      }
    }
    return const [];
  }
}
