import 'package:flutter/foundation.dart';
import '../../domain/entities/writing_evaluation.dart';
import '../../domain/entities/writing_prompt.dart';
import '../../domain/usecases/evaluate_writing.dart';
import '../../domain/usecases/fetch_writing_prompts.dart';

class WritingProvider extends ChangeNotifier {
  final EvaluateWriting _evaluateWriting;
  final FetchWritingPrompts _fetchWritingPrompts;

  int _selectedTask = 2; // Task 1 or Task 2
  bool _isEvaluating = false;
  WritingEvaluation? _evaluationResult;
  List<WritingPrompt> _prompts = [
    WritingPrompt.defaultTask1Prompt,
    WritingPrompt.defaultTask2Prompt,
  ];
  String? _errorMessage;

  WritingProvider({
    EvaluateWriting? evaluateWriting,
    FetchWritingPrompts? fetchWritingPrompts,
  }) : _evaluateWriting = evaluateWriting ?? EvaluateWriting(),
       _fetchWritingPrompts = fetchWritingPrompts ?? FetchWritingPrompts();

  int get selectedTask => _selectedTask;
  bool get isEvaluating => _isEvaluating;
  WritingEvaluation? get evaluationResult => _evaluationResult;
  List<WritingPrompt> get prompts => _prompts;
  String? get errorMessage => _errorMessage;

  void selectTask(int task) {
    if (_selectedTask != task) {
      _selectedTask = task;
      _evaluationResult = null;
      _errorMessage = null;
      notifyListeners();
    }
  }

  Future<void> loadPrompts() async {
    try {
      final fetched = await _fetchWritingPrompts();
      if (fetched.isNotEmpty) {
        _prompts = fetched;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<WritingEvaluation?> evaluateEssay({
    required String essayText,
    required String prompt,
  }) async {
    if (essayText.trim().isEmpty) return null;

    _isEvaluating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _evaluateWriting(
        essayText: essayText.trim(),
        prompt: prompt,
        taskType: 'task$_selectedTask',
      );
      _evaluationResult = result;
      return result;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      rethrow;
    } finally {
      _isEvaluating = false;
      notifyListeners();
    }
  }
}
