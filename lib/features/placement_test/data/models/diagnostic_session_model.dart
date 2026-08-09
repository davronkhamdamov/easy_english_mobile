import '../../domain/entities/diagnostic_session.dart';
import 'placement_question_model.dart';

class DiagnosticSessionModel {
  final String id;
  final DateTime startTime;
  final int durationSeconds;
  final List<PlacementQuestionModel> questions;
  final Map<String, int> userAnswers;
  final int currentQuestionIndex;
  final bool isCompleted;
  final int remainingSeconds;

  DiagnosticSessionModel({
    required this.id,
    required this.startTime,
    required this.durationSeconds,
    required this.questions,
    required this.userAnswers,
    this.currentQuestionIndex = 0,
    this.isCompleted = false,
    required this.remainingSeconds,
  });

  factory DiagnosticSessionModel.fromJson(Map<String, dynamic> json) {
    return DiagnosticSessionModel(
      id:
          json['id'] as String? ??
          'session_${DateTime.now().millisecondsSinceEpoch}',
      startTime: json['start_time'] != null
          ? DateTime.parse(json['start_time'] as String)
          : DateTime.now(),
      durationSeconds: (json['duration_seconds'] ?? 600) as int,
      questions:
          (json['questions'] as List<dynamic>?)
              ?.map(
                (q) =>
                    PlacementQuestionModel.fromJson(q as Map<String, dynamic>),
              )
              .toList() ??
          [],
      userAnswers:
          (json['user_answers'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, (v as num).toInt()),
          ) ??
          {},
      currentQuestionIndex: (json['current_question_index'] ?? 0) as int,
      isCompleted: (json['is_completed'] ?? false) as bool,
      remainingSeconds:
          (json['remaining_seconds'] ?? json['duration_seconds'] ?? 600) as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'start_time': startTime.toIso8601String(),
      'duration_seconds': durationSeconds,
      'questions': questions.map((q) => q.toJson()).toList(),
      'user_answers': userAnswers,
      'current_question_index': currentQuestionIndex,
      'is_completed': isCompleted,
      'remaining_seconds': remainingSeconds,
    };
  }

  DiagnosticSession toEntity() {
    return DiagnosticSession(
      id: id,
      startTime: startTime,
      durationSeconds: durationSeconds,
      questions: questions.map((q) => q.toEntity()).toList(),
      userAnswers: Map.from(userAnswers),
      currentQuestionIndex: currentQuestionIndex,
      isCompleted: isCompleted,
      remainingSeconds: remainingSeconds,
    );
  }

  factory DiagnosticSessionModel.fromEntity(DiagnosticSession entity) {
    return DiagnosticSessionModel(
      id: entity.id,
      startTime: entity.startTime,
      durationSeconds: entity.durationSeconds,
      questions: entity.questions
          .map((q) => PlacementQuestionModel.fromEntity(q))
          .toList(),
      userAnswers: Map.from(entity.userAnswers),
      currentQuestionIndex: entity.currentQuestionIndex,
      isCompleted: entity.isCompleted,
      remainingSeconds: entity.remainingSeconds,
    );
  }
}
