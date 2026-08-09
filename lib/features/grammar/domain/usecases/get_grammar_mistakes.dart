import '../../data/repositories/grammar_repository_impl.dart';
import '../entities/grammar_mistake_record.dart';
import '../repositories/grammar_repository.dart';

class GetGrammarMistakes {
  final GrammarRepository _repository;

  GetGrammarMistakes({GrammarRepository? repository})
    : _repository = repository ?? GrammarRepositoryImpl();

  Future<List<GrammarMistakeRecord>> call() {
    return _repository.getGrammarMistakes();
  }
}
