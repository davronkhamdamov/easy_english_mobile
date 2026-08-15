import '../../data/repositories/grammar_repository_impl.dart';
import '../entities/grammar_evaluation.dart';
import '../repositories/grammar_repository.dart';

class EvaluateGrammar {
  final GrammarRepository _repository;

  EvaluateGrammar({GrammarRepository? repository})
      : _repository = repository ?? GrammarRepositoryImpl();

  Future<GrammarEvaluation> call({
    required String sentence,
    String? targetWord,
  }) {
    return _repository.evaluateGrammar(
      sentence: sentence,
      targetWord: targetWord,
    );
  }
}

typedef EvaluateGrammarSentenceUseCase = EvaluateGrammar;
