import 'dart:convert';
import '../../../../core/network/api_client.dart';
import '../models/grammar_evaluation_model.dart';
import '../models/grammar_mistake_model.dart';
import '../models/grammar_topic_model.dart';
import 'grammar_seed_data.dart';

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
    final response = await _client.post('/api/v1/grammar/evaluate/', {
      'user_sentence': sentence,
      'sentence': sentence,
      if (targetWord != null && targetWord.isNotEmpty)
        'target_word': targetWord,
    });

    if (response.statusCode == 200 || response.statusCode == 201) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return GrammarEvaluationModel.fromJson(json);
    } else {
      throw Exception(
        'Failed to evaluate grammar (${response.statusCode}): ${response.body}',
      );
    }
  }

  @override
  Future<List<GrammarTopicModel>> fetchRoadmapTopics() async {
    final seedTopics = GrammarSeedData.sampleTopics;
    return seedTopics.map((t) => GrammarTopicModel.fromEntity(t)).toList();
  }

  @override
  Future<List<GrammarMistakeRecordModel>> fetchMistakeRecords() async {
    final seedMistakes = GrammarSeedData.sampleMistakes;
    return seedMistakes
        .map((m) => GrammarMistakeRecordModel.fromEntity(m))
        .toList();
  }
}
