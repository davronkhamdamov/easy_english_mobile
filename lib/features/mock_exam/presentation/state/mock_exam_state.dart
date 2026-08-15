import '../../domain/entities/exam_enums.dart';
import '../../domain/entities/mock_exam_paper.dart';
import '../../domain/entities/mock_exam_result.dart';

class MockExamState {
  final String selectedCategory; // 'all', 'reading', 'listening', 'full'
  final ExamType selectedExamType;
  final List<MockExamPaper> availablePapers;
  final MockExamPaper? currentPaper;
  final Map<String, String> userAnswers;
  final int timeSpentSeconds;
  final int remainingSeconds;
  final bool isLoading;
  final bool isSubmitting;
  final String? errorMessage;
  final MockExamResult? lastResult;
  final List<MockExamResult> examHistory;

  const MockExamState({
    this.selectedCategory = 'all',
    this.selectedExamType = ExamType.academic,
    this.availablePapers = const [],
    this.currentPaper,
    this.userAnswers = const {},
    this.timeSpentSeconds = 0,
    this.remainingSeconds = 3600,
    this.isLoading = false,
    this.isSubmitting = false,
    this.errorMessage,
    this.lastResult,
    this.examHistory = const [],
  });

  MockExamState copyWith({
    String? selectedCategory,
    ExamType? selectedExamType,
    List<MockExamPaper>? availablePapers,
    MockExamPaper? currentPaper,
    Map<String, String>? userAnswers,
    int? timeSpentSeconds,
    int? remainingSeconds,
    bool? isLoading,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
    MockExamResult? lastResult,
    List<MockExamResult>? examHistory,
  }) {
    return MockExamState(
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedExamType: selectedExamType ?? this.selectedExamType,
      availablePapers: availablePapers ?? this.availablePapers,
      currentPaper: currentPaper ?? this.currentPaper,
      userAnswers: userAnswers ?? this.userAnswers,
      timeSpentSeconds: timeSpentSeconds ?? this.timeSpentSeconds,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lastResult: lastResult ?? this.lastResult,
      examHistory: examHistory ?? this.examHistory,
    );
  }
}
