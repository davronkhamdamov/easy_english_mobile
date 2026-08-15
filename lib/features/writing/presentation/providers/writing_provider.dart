import 'package:flutter/foundation.dart';
import '../../domain/entities/writing_evaluation.dart';
import '../../domain/entities/writing_prompt.dart';
import '../../domain/usecases/evaluate_essay_usecase.dart';
import '../../domain/usecases/get_writing_prompts_usecase.dart';

class WritingProvider extends ChangeNotifier {
  final GetWritingPromptsUseCase _getWritingPrompts;
  final EvaluateEssayUseCase _evaluateEssay;

  bool _isLoadingPrompts = false;
  bool _isEvaluating = false;
  String _selectedTaskType = 'task2'; // 'task1' or 'task2'
  List<WritingPrompt> _allPrompts = [];
  WritingPrompt? _selectedPrompt;
  String _essayText = '';
  int _wordCount = 0;
  WritingEvaluation? _evaluationResult;
  String? _errorMessage;
  String? _validationError;

  WritingProvider({
    GetWritingPromptsUseCase? getWritingPrompts,
    EvaluateEssayUseCase? evaluateEssay,
  })  : _getWritingPrompts = getWritingPrompts ?? GetWritingPromptsUseCase(),
        _evaluateEssay = evaluateEssay ?? EvaluateEssayUseCase();

  bool get isLoadingPrompts => _isLoadingPrompts;
  bool get isEvaluating => _isEvaluating;
  String get selectedTaskType => _selectedTaskType;
  List<WritingPrompt> get allPrompts => _allPrompts;

  List<WritingPrompt> get filteredPrompts {
    return _allPrompts
        .where((p) => p.taskType.toLowerCase() == _selectedTaskType.toLowerCase())
        .toList();
  }

  WritingPrompt? get selectedPrompt => _selectedPrompt;
  String get essayText => _essayText;
  int get wordCount => _wordCount;
  WritingEvaluation? get evaluationResult => _evaluationResult;
  String? get errorMessage => _errorMessage;
  String? get validationError => _validationError;

  // Convenience getter for task selection integer (1 or 2)
  int get selectedTask => _selectedTaskType == 'task1' ? 1 : 2;

  void selectTaskType(String taskType) {
    if (_selectedTaskType != taskType) {
      _selectedTaskType = taskType;
      _evaluationResult = null;
      _validationError = null;
      _updateSelectedPromptForCurrentTask();
      notifyListeners();
    }
  }

  void selectTask(int task) {
    selectTaskType(task == 1 ? 'task1' : 'task2');
  }

  void selectPrompt(WritingPrompt prompt) {
    _selectedPrompt = prompt;
    _evaluationResult = null;
    _validationError = null;
    notifyListeners();
  }

  void updateEssayText(String text) {
    _essayText = text;
    final trimmed = text.trim();
    _wordCount = trimmed.isEmpty
        ? 0
        : trimmed.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;

    if (_wordCount >= 50 && _validationError != null) {
      _validationError = null;
    }
    notifyListeners();
  }

  Future<void> loadPrompts() async {
    _isLoadingPrompts = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fetched = await _getWritingPrompts();
      _allPrompts = fetched;
      _updateSelectedPromptForCurrentTask();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoadingPrompts = false;
      notifyListeners();
    }
  }

  void _updateSelectedPromptForCurrentTask() {
    final available = filteredPrompts;
    if (available.isNotEmpty) {
      _selectedPrompt = available.first;
    } else {
      _selectedPrompt = null;
    }
  }

  Future<WritingEvaluation?> evaluateEssay({
    String? essayText,
    String? prompt,
  }) async {
    final textToSubmit = (essayText ?? _essayText).trim();
    final promptToSubmit = prompt ?? _selectedPrompt?.promptText ?? '';

    final words = textToSubmit.isEmpty
        ? 0
        : textToSubmit.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;

    if (words < 50) {
      _validationError =
          'Essay must be at least 50 words to submit for AI evaluation. (Current: $words words)';
      notifyListeners();
      return null;
    }

    _validationError = null;
    _isEvaluating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _evaluateEssay(
        essayText: textToSubmit,
        prompt: promptToSubmit,
        taskType: _selectedTaskType,
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
