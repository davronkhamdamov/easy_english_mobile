import 'placement_question.dart';

/// Domain entity representing an active or finished Placement Test Diagnostic Session.
class DiagnosticSession {
  final String id;
  final DateTime startTime;
  final int durationSeconds;
  final List<PlacementQuestion> questions;
  final Map<String, int> userAnswers; // questionID -> selectedOptionIndex
  int currentQuestionIndex;
  bool isCompleted;
  int remainingSeconds;

  DiagnosticSession({
    required this.id,
    required this.startTime,
    required this.durationSeconds,
    required this.questions,
    Map<String, int>? userAnswers,
    this.currentQuestionIndex = 0,
    this.isCompleted = false,
    int? remainingSeconds,
  }) : userAnswers = userAnswers ?? {},
       remainingSeconds = remainingSeconds ?? durationSeconds;

  PlacementQuestion get currentQuestion => questions[currentQuestionIndex];

  double get progressPercentage => questions.isEmpty
      ? 0.0
      : (userAnswers.length / questions.length).clamp(0.0, 1.0);

  int get answeredCount => userAnswers.length;
  int get totalQuestions => questions.length;
}
