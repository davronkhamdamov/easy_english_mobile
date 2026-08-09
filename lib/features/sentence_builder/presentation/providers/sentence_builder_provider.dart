import 'package:flutter/foundation.dart';
import '../../../grammar/domain/entities/grammar_evaluation.dart';
import '../../../grammar/domain/usecases/evaluate_grammar.dart';

/// State management provider for Sentence Builder feature.
class SentenceBuilderProvider extends ChangeNotifier {
  final EvaluateGrammar _evaluateGrammar;
  final String targetWord;
  final String promptInstructions;

  bool _isEvaluating = false;
  GrammarEvaluation? _evaluation;
  String? _errorMessage;

  SentenceBuilderProvider({
    String? initialWord,
    String? initialPrompt,
    EvaluateGrammar? evaluateGrammar,
  }) : _evaluateGrammar = evaluateGrammar ?? EvaluateGrammar(),
       targetWord = initialWord ?? 'Foster',
       promptInstructions =
           initialPrompt ??
           'Construct a formal IELTS Academic sentence using the target word "${initialWord ?? 'Foster'}". Include a complex clause or passive voice.';

  bool get isEvaluating => _isEvaluating;
  GrammarEvaluation? get evaluation => _evaluation;
  String? get errorMessage => _errorMessage;

  /// Submits sentence for AI grammar and vocabulary evaluation.
  Future<GrammarEvaluation?> submitSentence(String sentence) async {
    final text = sentence.trim();
    if (text.isEmpty) return null;

    _isEvaluating = true;
    _errorMessage = null;
    _evaluation = null;
    notifyListeners();

    try {
      final result = await _evaluateGrammar.call(
        sentence: text,
        targetWord: targetWord,
      );

      _isEvaluating = false;
      _evaluation = result;
      notifyListeners();
      return result;
    } catch (e) {
      _isEvaluating = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return null;
    }
  }

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }
}
