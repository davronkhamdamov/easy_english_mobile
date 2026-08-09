import 'package:flutter/foundation.dart';
import '../../domain/entities/exam_enums.dart';
import '../../domain/entities/mock_exam_paper.dart';
import '../../domain/entities/mock_exam_result.dart';
import '../../domain/repositories/mock_exam_repository.dart';
import '../../data/repositories/mock_exam_repository_impl.dart';
import '../../domain/usecases/get_available_mock_exams.dart';
import '../../domain/usecases/get_mock_exam_paper.dart';
import '../../domain/usecases/submit_mock_exam.dart';

class MockExamProvider extends ChangeNotifier {
  final GetAvailableMockExams _getAvailableMockExams;
  final GetMockExamPaper _getMockExamPaper;
  final SubmitMockExam _submitMockExam;

  ExamType _selectedExamType = ExamType.academic;
  List<MockExamPaper> _availablePapers = [];
  bool _isLoading = false;
  String? _errorMessage;
  MockExamResult? _lastResult;

  MockExamProvider({
    MockExamRepository? repository,
    GetAvailableMockExams? getAvailableMockExams,
    GetMockExamPaper? getMockExamPaper,
    SubmitMockExam? submitMockExam,
  }) : _getAvailableMockExams =
           getAvailableMockExams ??
           GetAvailableMockExams(repository ?? MockExamRepositoryImpl()),
       _getMockExamPaper =
           getMockExamPaper ??
           GetMockExamPaper(repository ?? MockExamRepositoryImpl()),
       _submitMockExam =
           submitMockExam ??
           SubmitMockExam(repository ?? MockExamRepositoryImpl());

  ExamType get selectedExamType => _selectedExamType;
  List<MockExamPaper> get availablePapers => _availablePapers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  MockExamResult? get lastResult => _lastResult;

  void selectExamType(ExamType type) {
    if (_selectedExamType != type) {
      _selectedExamType = type;
      notifyListeners();
      loadAvailableExams();
    }
  }

  Future<void> loadAvailableExams() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _availablePapers = await _getAvailableMockExams(
        examType: _selectedExamType,
      );
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<MockExamPaper?> fetchPaper(String paperId) async {
    try {
      return await _getMockExamPaper(paperId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<MockExamResult?> submitResult(MockExamResult result) async {
    _isLoading = true;
    notifyListeners();

    try {
      final submitted = await _submitMockExam(result);
      _lastResult = submitted;
      return submitted;
    } catch (e) {
      _errorMessage = e.toString();
      return result;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
