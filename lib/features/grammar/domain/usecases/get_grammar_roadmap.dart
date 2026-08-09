import '../../data/repositories/grammar_repository_impl.dart';
import '../entities/grammar_topic.dart';
import '../repositories/grammar_repository.dart';

class GetGrammarRoadmap {
  final GrammarRepository _repository;

  GetGrammarRoadmap({GrammarRepository? repository})
    : _repository = repository ?? GrammarRepositoryImpl();

  Future<List<GrammarTopic>> call() {
    return _repository.getGrammarRoadmap();
  }
}
