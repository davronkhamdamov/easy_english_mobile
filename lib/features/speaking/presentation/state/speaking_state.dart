import '../../domain/entities/speaking_evaluation.dart';
import '../../domain/entities/speaking_prompt.dart';

enum PracticeState {
  idle,
  preparing,
  recording,
  recorded,
  evaluating,
  evaluated,
}

class SpeakingState {
  final bool isLoading;
  final int selectedPart; // 1, 2, 3
  final List<SpeakingPrompt> prompts;
  final SpeakingPrompt? currentPrompt;
  final PracticeState practiceState;
  final int recordingDuration;
  final int prepDuration;
  final String? audioPath;
  final String transcript;
  final bool isTranscribing;
  final bool isEvaluating;
  final SpeakingAIEvaluation? evaluationResult;
  final String? errorMessage;

  const SpeakingState({
    this.isLoading = false,
    this.selectedPart = 1,
    this.prompts = const [],
    this.currentPrompt,
    this.practiceState = PracticeState.idle,
    this.recordingDuration = 0,
    this.prepDuration = 0,
    this.audioPath,
    this.transcript = '',
    this.isTranscribing = false,
    this.isEvaluating = false,
    this.evaluationResult,
    this.errorMessage,
  });

  SpeakingState copyWith({
    bool? isLoading,
    int? selectedPart,
    List<SpeakingPrompt>? prompts,
    SpeakingPrompt? currentPrompt,
    PracticeState? practiceState,
    int? recordingDuration,
    int? prepDuration,
    String? audioPath,
    String? transcript,
    bool? isTranscribing,
    bool? isEvaluating,
    SpeakingAIEvaluation? evaluationResult,
    String? errorMessage,
    bool clearError = false,
    bool clearAudio = false,
    bool clearEvaluation = false,
  }) {
    return SpeakingState(
      isLoading: isLoading ?? this.isLoading,
      selectedPart: selectedPart ?? this.selectedPart,
      prompts: prompts ?? this.prompts,
      currentPrompt: currentPrompt ?? this.currentPrompt,
      practiceState: practiceState ?? this.practiceState,
      recordingDuration: recordingDuration ?? this.recordingDuration,
      prepDuration: prepDuration ?? this.prepDuration,
      audioPath: clearAudio ? null : (audioPath ?? this.audioPath),
      transcript: transcript ?? this.transcript,
      isTranscribing: isTranscribing ?? this.isTranscribing,
      isEvaluating: isEvaluating ?? this.isEvaluating,
      evaluationResult: clearEvaluation
          ? null
          : (evaluationResult ?? this.evaluationResult),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
