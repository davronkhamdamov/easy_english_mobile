import 'diagnostic_skill.dart';

/// Domain entity representing a diagnostic placement test question.
class PlacementQuestion {
  final String id;
  final String section;
  final String questionText;
  final List<String> options;
  final int correctOptionIndex;
  final String? difficultyLevel;
  final String? audioUrl;
  final String? passage;
  final String explanation;

  const PlacementQuestion({
    required this.id,
    required this.section,
    required this.questionText,
    required this.options,
    required this.correctOptionIndex,
    this.difficultyLevel,
    this.audioUrl,
    this.passage,
    this.explanation = '',
  });

  /// Mapping helpers for backwards compatibility across existing UI/callers
  DiagnosticSkill get skill => DiagnosticSkill.fromString(section);
  String get prompt => questionText;
  String get cefrLevel => difficultyLevel ?? 'Intermediate';

  PlacementQuestion copyWith({
    String? id,
    String? section,
    String? questionText,
    List<String>? options,
    int? correctOptionIndex,
    String? difficultyLevel,
    String? audioUrl,
    String? passage,
    String? explanation,
  }) {
    return PlacementQuestion(
      id: id ?? this.id,
      section: section ?? this.section,
      questionText: questionText ?? this.questionText,
      options: options ?? this.options,
      correctOptionIndex: correctOptionIndex ?? this.correctOptionIndex,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      audioUrl: audioUrl ?? this.audioUrl,
      passage: passage ?? this.passage,
      explanation: explanation ?? this.explanation,
    );
  }
}
