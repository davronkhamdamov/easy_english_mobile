import '../../domain/entities/grammar_evaluation.dart';
import '../../domain/entities/grammar_mistake_record.dart';
import '../../domain/entities/grammar_topic.dart';
import '../../domain/repositories/grammar_repository.dart';
import '../datasources/grammar_remote_datasource.dart';

class GrammarRepositoryImpl implements GrammarRepository {
  final GrammarRemoteDataSource _remoteDataSource;

  GrammarRepositoryImpl({GrammarRemoteDataSource? remoteDataSource})
    : _remoteDataSource = remoteDataSource ?? GrammarRemoteDataSourceImpl();

  @override
  Future<GrammarEvaluation> evaluateGrammar({
    required String sentence,
    String? targetWord,
  }) async {
    final model = await _remoteDataSource.evaluateSentence(
      sentence: sentence,
      targetWord: targetWord,
    );
    return model.toEntity();
  }

  @override
  Future<List<GrammarTopic>> getGrammarRoadmap() async {
    final models = await _remoteDataSource.fetchRoadmapTopics();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<GrammarMistakeRecord>> getGrammarMistakes() async {
    final models = await _remoteDataSource.fetchMistakeRecords();
    return models.map((m) => m.toEntity()).toList();
  }
}
