import '../../domain/entities/grammar_evaluation.dart';
import '../../domain/entities/grammar_mistake_record.dart';
import '../../domain/entities/grammar_topic.dart';

class GrammarState {
  final String selectedCefrLevel; // 'All', 'A1', 'A2', 'B1', 'B2', 'C1'
  final List<GrammarTopic> topics;
  final List<GrammarMistakeRecord> mistakes;
  final GrammarEvaluation? currentEvaluation;
  final bool isLoading;
  final bool isEvaluating;
  final String? errorMessage;

  const GrammarState({
    this.selectedCefrLevel = 'All',
    this.topics = const [],
    this.mistakes = const [],
    this.currentEvaluation,
    this.isLoading = false,
    this.isEvaluating = false,
    this.errorMessage,
  });

  GrammarState copyWith({
    String? selectedCefrLevel,
    List<GrammarTopic>? topics,
    List<GrammarMistakeRecord>? mistakes,
    GrammarEvaluation? currentEvaluation,
    bool clearEvaluation = false,
    bool? isLoading,
    bool? isEvaluating,
    String? errorMessage,
    bool clearError = false,
  }) {
    return GrammarState(
      selectedCefrLevel: selectedCefrLevel ?? this.selectedCefrLevel,
      topics: topics ?? this.topics,
      mistakes: mistakes ?? this.mistakes,
      currentEvaluation: clearEvaluation ? null : (currentEvaluation ?? this.currentEvaluation),
      isLoading: isLoading ?? this.isLoading,
      isEvaluating: isEvaluating ?? this.isEvaluating,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
