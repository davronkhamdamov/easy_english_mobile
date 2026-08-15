import '../../domain/entities/placement_question.dart';
import '../../domain/entities/placement_result.dart';

/// Immutable presentation state model for Diagnostic Placement Test.
class PlacementTestState {
  final bool isLoading;
  final List<PlacementQuestion> questions;
  final int currentIndex;
  final Map<String, int> userAnswers;
  final bool isSubmitting;
  final PlacementResult? result;
  final String? errorMessage;
  final int elapsedSeconds;

  const PlacementTestState({
    this.isLoading = false,
    this.questions = const [],
    this.currentIndex = 0,
    this.userAnswers = const {},
    this.isSubmitting = false,
    this.result,
    this.errorMessage,
    this.elapsedSeconds = 0,
  });

  PlacementTestState copyWith({
    bool? isLoading,
    List<PlacementQuestion>? questions,
    int? currentIndex,
    Map<String, int>? userAnswers,
    bool? isSubmitting,
    PlacementResult? result,
    String? errorMessage,
    bool clearError = false,
    int? elapsedSeconds,
  }) {
    return PlacementTestState(
      isLoading: isLoading ?? this.isLoading,
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      userAnswers: userAnswers ?? this.userAnswers,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      result: result ?? this.result,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
    );
  }

  bool get isCompleted => result != null;
  int get answeredCount => userAnswers.length;
  int get totalQuestions => questions.length;
  double get progressPercentage =>
      totalQuestions > 0 ? (currentIndex + 1) / totalQuestions : 0.0;
  PlacementQuestion? get currentQuestion =>
      questions.isNotEmpty && currentIndex < questions.length
          ? questions[currentIndex]
          : null;
}
