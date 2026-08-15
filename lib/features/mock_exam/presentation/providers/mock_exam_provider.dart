import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../data/repositories/mock_exam_repository_impl.dart';
import '../../domain/entities/exam_enums.dart';
import '../../domain/entities/mock_exam_paper.dart';
import '../../domain/entities/mock_exam_result.dart';
import '../../domain/repositories/mock_exam_repository.dart';
import '../../domain/usecases/get_available_mock_exams.dart';
import '../../domain/usecases/get_exam_history.dart';
import '../../domain/usecases/get_mock_exam_paper.dart';
import '../../domain/usecases/submit_mock_exam.dart';
import '../state/mock_exam_state.dart';

class MockExamProvider extends ChangeNotifier {
  final GetAvailableMockExams _getAvailableMockExams;
  final GetMockExamPaper _getMockExamPaper;
  final SubmitMockExam _submitMockExam;
  final GetExamHistoryUseCase _getExamHistory;

  MockExamState _state = const MockExamState();
  Timer? _timer;

  MockExamProvider({
    MockExamRepository? repository,
    GetAvailableMockExams? getAvailableMockExams,
    GetMockExamPaper? getMockExamPaper,
    SubmitMockExam? submitMockExam,
    GetExamHistoryUseCase? getExamHistory,
  })  : _getAvailableMockExams = getAvailableMockExams ?? GetAvailableMockExams(repository ?? MockExamRepositoryImpl()),
        _getMockExamPaper = getMockExamPaper ?? GetMockExamPaper(repository ?? MockExamRepositoryImpl()),
        _submitMockExam = submitMockExam ?? SubmitMockExam(repository ?? MockExamRepositoryImpl()),
        _getExamHistory = getExamHistory ?? GetExamHistoryUseCase(repository ?? MockExamRepositoryImpl());

  MockExamState get state => _state;
  ExamType get selectedExamType => _state.selectedExamType;
  String get selectedCategory => _state.selectedCategory;
  List<MockExamPaper> get availablePapers => _state.availablePapers;
  MockExamPaper? get currentPaper => _state.currentPaper;
  Map<String, String> get userAnswers => _state.userAnswers;
  bool get isLoading => _state.isLoading;
  bool get isSubmitting => _state.isSubmitting;
  String? get errorMessage => _state.errorMessage;
  MockExamResult? get lastResult => _state.lastResult;
  List<MockExamResult> get examHistory => _state.examHistory;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void selectCategory(String category) {
    if (_state.selectedCategory != category) {
      _state = _state.copyWith(selectedCategory: category);
      notifyListeners();
      loadAvailableExams();
    }
  }

  void selectExamType(ExamType type) {
    if (_state.selectedExamType != type) {
      _state = _state.copyWith(selectedExamType: type);
      notifyListeners();
      loadAvailableExams();
    }
  }

  Future<void> loadAvailableExams() async {
    _state = _state.copyWith(isLoading: true, clearError: true);
    notifyListeners();

    try {
      final typeFilter = _state.selectedCategory == 'all' ? null : _state.selectedCategory;
      final papers = await _getAvailableMockExams(type: typeFilter, examType: _state.selectedExamType);
      _state = _state.copyWith(isLoading: false, availablePapers: papers);
    } catch (e) {
      _state = _state.copyWith(isLoading: false, errorMessage: e.toString().replaceAll('Exception: ', ''));
    }
    notifyListeners();
  }

  Future<MockExamPaper?> fetchPaper(String paperId) async {
    _state = _state.copyWith(isLoading: true, clearError: true);
    notifyListeners();
    try {
      final paper = await _getMockExamPaper(paperId);
      _state = _state.copyWith(isLoading: false, currentPaper: paper, userAnswers: {}, timeSpentSeconds: 0, remainingSeconds: (paper.durationMinutes * 60));
      startExamTimer();
      notifyListeners();
      return paper;
    } catch (e) {
      _state = _state.copyWith(isLoading: false, errorMessage: e.toString().replaceAll('Exception: ', ''));
      notifyListeners();
      return null;
    }
  }

  void recordAnswer(String questionId, String answer) {
    final updated = Map<String, String>.from(_state.userAnswers)..[questionId] = answer;
    _state = _state.copyWith(userAnswers: updated);
    notifyListeners();
  }

  void startExamTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      final elapsed = _state.timeSpentSeconds + 1;
      final remaining = _state.remainingSeconds > 0 ? _state.remainingSeconds - 1 : 0;
      _state = _state.copyWith(timeSpentSeconds: elapsed, remainingSeconds: remaining);
      notifyListeners();
    });
  }

  Future<MockExamResult?> submitExam({String? paperId}) async {
    _timer?.cancel();
    _state = _state.copyWith(isSubmitting: true, clearError: true);
    notifyListeners();

    final targetPaperId = paperId ?? _state.currentPaper?.id ?? '';
    try {
      final result = await _submitMockExam.submitAnswers(
        paperId: targetPaperId,
        userAnswers: _state.userAnswers,
        timeSpentSeconds: _state.timeSpentSeconds,
      );
      _state = _state.copyWith(isSubmitting: false, lastResult: result);
      notifyListeners();
      return result;
    } catch (e) {
      _state = _state.copyWith(isSubmitting: false, errorMessage: e.toString().replaceAll('Exception: ', ''));
      notifyListeners();
      return null;
    }
  }

  Future<MockExamResult?> submitResult(MockExamResult result) async {
    _timer?.cancel();
    _state = _state.copyWith(isSubmitting: true, clearError: true);
    notifyListeners();
    try {
      final submitted = await _submitMockExam(result);
      _state = _state.copyWith(isSubmitting: false, lastResult: submitted);
      notifyListeners();
      return submitted;
    } catch (e) {
      _state = _state.copyWith(isSubmitting: false, errorMessage: e.toString().replaceAll('Exception: ', ''));
      notifyListeners();
      return null;
    }
  }

  Future<void> loadExamHistory({String? userId}) async {
    try {
      final history = await _getExamHistory(userId: userId);
      _state = _state.copyWith(examHistory: history);
      notifyListeners();
    } catch (e) {
      debugPrint('History load error: $e');
    }
  }
}
