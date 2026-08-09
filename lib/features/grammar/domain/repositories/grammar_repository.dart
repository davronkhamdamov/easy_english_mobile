import '../entities/grammar_evaluation.dart';
import '../entities/grammar_mistake_record.dart';
import '../entities/grammar_topic.dart';

abstract class GrammarRepository {
  Future<GrammarEvaluation> evaluateGrammar({
    required String sentence,
    String? targetWord,
  });
  Future<List<GrammarTopic>> getGrammarRoadmap();
  Future<List<GrammarMistakeRecord>> getGrammarMistakes();
}
