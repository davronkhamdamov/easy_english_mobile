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

  static const List<WritingPrompt> fallbackPrompts = [
    WritingPrompt(
      id: 'default_task1_renewables',
      taskType: 'task1',
      topic: 'Charts & Trends',
      title: 'Renewable Electricity Generation (2010–2025)',
      promptText:
          'The bar chart illustrates the percentage of electricity generated from renewable sources in four European countries between 2010 and 2025.\n\nSummarise the information by selecting and reporting the main features, and make comparisons where relevant. Write at least 150 words.',
      minWordCount: 150,
      difficulty: 'Academic',
    ),
    WritingPrompt(
      id: 'default_task1_desalination',
      taskType: 'task1',
      topic: 'Process Diagram',
      title: 'Seawater Desalination Plant',
      promptText:
          'The diagram below illustrates the stages involved in purifying and desalinating seawater for municipal consumption.\n\nSummarise the information by selecting and reporting the main features, and make comparisons where relevant. Write at least 150 words.',
      minWordCount: 150,
      difficulty: 'Academic',
    ),
    WritingPrompt(
      id: 'default_task2_tech',
      taskType: 'task2',
      topic: 'Technology & Society',
      title: 'AI Automation in Education',
      promptText:
          'Some people believe that artificial intelligence will eventually replace human teachers in schools and universities. Others argue that human educators remain indispensable for student development.\n\nDiscuss both views and give your own opinion. Write at least 250 words.',
      minWordCount: 250,
      difficulty: 'Intermediate',
    ),
  ];

  WritingProvider({
    GetWritingPromptsUseCase? getWritingPrompts,
    EvaluateEssayUseCase? evaluateEssay,
    String initialTaskType = 'task2',
  })  : _getWritingPrompts = getWritingPrompts ?? GetWritingPromptsUseCase(),
        _evaluateEssay = evaluateEssay ?? EvaluateEssayUseCase(),
        _selectedTaskType = initialTaskType;

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
      if (fetched.isNotEmpty) {
        _allPrompts = fetched;
      } else {
        _allPrompts = fallbackPrompts;
      }
      _updateSelectedPromptForCurrentTask();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      if (_allPrompts.isEmpty) {
        _allPrompts = fallbackPrompts;
        _updateSelectedPromptForCurrentTask();
      }
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
