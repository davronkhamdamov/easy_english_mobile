import 'package:flutter/foundation.dart';
import '../../data/repositories/grammar_repository_impl.dart';
import '../../domain/entities/grammar_evaluation.dart';
import '../../domain/entities/grammar_mistake_record.dart';
import '../../domain/entities/grammar_topic.dart';
import '../../domain/repositories/grammar_repository.dart';
import '../../domain/usecases/evaluate_grammar.dart';
import '../../domain/usecases/get_grammar_mistakes.dart';
import '../../domain/usecases/get_grammar_roadmap.dart';
import '../state/grammar_state.dart';

class GrammarProvider extends ChangeNotifier {
  final FetchGrammarRoadmapUseCase _getGrammarRoadmap;
  final FetchGrammarMistakesUseCase _getGrammarMistakes;
  final EvaluateGrammarSentenceUseCase _evaluateGrammar;

  GrammarState _state = const GrammarState();

  GrammarProvider({
    GrammarRepository? repository,
    FetchGrammarRoadmapUseCase? getGrammarRoadmap,
    FetchGrammarMistakesUseCase? getGrammarMistakes,
    EvaluateGrammarSentenceUseCase? evaluateGrammar,
  })  : _getGrammarRoadmap = getGrammarRoadmap ?? GetGrammarRoadmap(repository: repository ?? GrammarRepositoryImpl()),
        _getGrammarMistakes = getGrammarMistakes ?? GetGrammarMistakes(repository: repository ?? GrammarRepositoryImpl()),
        _evaluateGrammar = evaluateGrammar ?? EvaluateGrammar(repository: repository ?? GrammarRepositoryImpl());

  GrammarState get state => _state;
  String get selectedCefrLevel => _state.selectedCefrLevel;
  List<GrammarTopic> get topics => _state.topics;
  List<GrammarMistakeRecord> get mistakes => _state.mistakes;
  GrammarEvaluation? get currentEvaluation => _state.currentEvaluation;
  bool get isLoading => _state.isLoading;
  bool get isEvaluating => _state.isEvaluating;
  String? get errorMessage => _state.errorMessage;

  List<GrammarTopic> get filteredTopics {
    if (_state.selectedCefrLevel == 'All') return _state.topics;
    return _state.topics.where((t) => t.cefrLevel.toUpperCase() == _state.selectedCefrLevel.toUpperCase()).toList();
  }

  void selectCefrLevel(String level) {
    if (_state.selectedCefrLevel != level) {
      _state = _state.copyWith(selectedCefrLevel: level);
      notifyListeners();
    }
  }

  Future<void> loadRoadmap() async {
    _state = _state.copyWith(isLoading: true, clearError: true);
    notifyListeners();

    try {
      final loadedTopics = await _getGrammarRoadmap();
      _state = _state.copyWith(isLoading: false, topics: loadedTopics);
    } catch (e) {
      _state = _state.copyWith(isLoading: false, errorMessage: e.toString().replaceAll('Exception: ', ''));
    }
    notifyListeners();
  }

  Future<void> loadMistakes() async {
    _state = _state.copyWith(isLoading: true, clearError: true);
    notifyListeners();

    try {
      final loadedMistakes = await _getGrammarMistakes();
      _state = _state.copyWith(isLoading: false, mistakes: loadedMistakes);
    } catch (e) {
      _state = _state.copyWith(isLoading: false, errorMessage: e.toString().replaceAll('Exception: ', ''));
    }
    notifyListeners();
  }

  Future<GrammarEvaluation?> evaluateSentence({
    required String sentence,
    String? targetWord,
  }) async {
    _state = _state.copyWith(isEvaluating: true, clearError: true, clearEvaluation: true);
    notifyListeners();

    try {
      final eval = await _evaluateGrammar(sentence: sentence, targetWord: targetWord);
      _state = _state.copyWith(isEvaluating: false, currentEvaluation: eval);
      notifyListeners();
      return eval;
    } catch (e) {
      _state = _state.copyWith(isEvaluating: false, errorMessage: e.toString().replaceAll('Exception: ', ''));
      notifyListeners();
      return null;
    }
  }

  void clearEvaluation() {
    _state = _state.copyWith(clearEvaluation: true);
    notifyListeners();
  }
}
