import 'package:flutter/foundation.dart';
import '../../domain/entities/grammar_evaluation.dart';
import '../../domain/entities/grammar_mistake_record.dart';
import '../../domain/entities/grammar_topic.dart';
import '../../domain/usecases/evaluate_grammar.dart';
import '../../domain/usecases/get_grammar_mistakes.dart';
import '../../domain/usecases/get_grammar_roadmap.dart';

class GrammarProvider extends ChangeNotifier {
  final GetGrammarRoadmap _getGrammarRoadmap;
  final GetGrammarMistakes _getGrammarMistakes;
  final EvaluateGrammar _evaluateGrammar;

  List<GrammarTopic> _topics = [];
  List<GrammarMistakeRecord> _mistakes = [];
  bool _isLoading = false;
  String? _errorMessage;

  GrammarProvider({
    GetGrammarRoadmap? getGrammarRoadmap,
    GetGrammarMistakes? getGrammarMistakes,
    EvaluateGrammar? evaluateGrammar,
  }) : _getGrammarRoadmap = getGrammarRoadmap ?? GetGrammarRoadmap(),
       _getGrammarMistakes = getGrammarMistakes ?? GetGrammarMistakes(),
       _evaluateGrammar = evaluateGrammar ?? EvaluateGrammar();

  List<GrammarTopic> get topics => _topics;
  List<GrammarMistakeRecord> get mistakes => _mistakes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadRoadmap() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _topics = await _getGrammarRoadmap();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMistakes() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _mistakes = await _getGrammarMistakes();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<GrammarEvaluation> evaluateSentence({
    required String sentence,
    String? targetWord,
  }) {
    return _evaluateGrammar(sentence: sentence, targetWord: targetWord);
  }
}
