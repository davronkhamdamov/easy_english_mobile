import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import '../../domain/entities/speaking_evaluation.dart';
import '../../domain/entities/speaking_prompt.dart';
import '../../domain/usecases/evaluate_speaking.dart';
import '../../domain/usecases/fetch_speaking_prompts.dart';
import '../../domain/usecases/transcribe_speaking_audio.dart';
import '../state/speaking_state.dart';

class SpeakingProvider extends ChangeNotifier {
  final FetchSpeakingPrompts _fetchSpeakingPrompts;
  final TranscribeSpeakingAudio _transcribeSpeakingAudio;
  final EvaluateSpeaking _evaluateSpeaking;
  final AudioRecorder _audioRecorder;
  SpeakingState _state = const SpeakingState();
  Timer? _timer;

  SpeakingProvider({
    required FetchSpeakingPrompts fetchSpeakingPrompts,
    required TranscribeSpeakingAudio transcribeSpeakingAudio,
    required EvaluateSpeaking evaluateSpeaking,
    AudioRecorder? audioRecorder,
  })  : _fetchSpeakingPrompts = fetchSpeakingPrompts,
        _transcribeSpeakingAudio = transcribeSpeakingAudio,
        _evaluateSpeaking = evaluateSpeaking,
        _audioRecorder = audioRecorder ?? AudioRecorder();

  SpeakingState get state => _state;
  List<SpeakingPrompt> get prompts => _state.prompts;
  bool get isLoading => _state.isLoading;
  String? get errorMessage => _state.errorMessage;

  @override
  void dispose() {
    _timer?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> loadPrompts({int? part}) async {
    _state = _state.copyWith(isLoading: true, clearError: true);
    notifyListeners();
    try {
      final fetched = await _fetchSpeakingPrompts(part: part);
      final targetPart = part ?? _state.selectedPart;
      final current = fetched.cast<SpeakingPrompt?>().firstWhere(
            (p) => p?.part == targetPart,
            orElse: () => fetched.isNotEmpty ? fetched.first : null,
          );
      _state = _state.copyWith(isLoading: false, prompts: fetched, currentPrompt: current, clearError: true);
    } catch (e) {
      _state = _state.copyWith(isLoading: false, errorMessage: e.toString().replaceAll('Exception: ', ''));
    }
    notifyListeners();
  }

  Future<void> switchPart(int part) async {
    _timer?.cancel();
    final prompt = _state.prompts.cast<SpeakingPrompt?>().firstWhere((p) => p?.part == part, orElse: () => null);
    _state = _state.copyWith(selectedPart: part, currentPrompt: prompt, practiceState: PracticeState.idle, recordingDuration: 0, prepDuration: 0, clearAudio: true, clearEvaluation: true, transcript: '');
    notifyListeners();
    if (prompt == null) await loadPrompts(part: part);
  }

  void startPreparation() {
    final prepSecs = _state.currentPrompt?.prepTimeSeconds ?? 60;
    _state = _state.copyWith(practiceState: PracticeState.preparing, prepDuration: prepSecs > 0 ? prepSecs : 60);
    notifyListeners();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_state.prepDuration <= 1) {
        t.cancel();
        startRecording();
      } else {
        _state = _state.copyWith(prepDuration: _state.prepDuration - 1);
        notifyListeners();
      }
    });
  }

  Future<void> startRecording() async {
    _timer?.cancel();
    _state = _state.copyWith(practiceState: PracticeState.recording, recordingDuration: 0, clearAudio: true, clearEvaluation: true, transcript: '');
    notifyListeners();
    try {
      if (await _audioRecorder.hasPermission()) {
        final tempDir = await getTemporaryDirectory();
        final path = '${tempDir.path}/speak_${DateTime.now().millisecondsSinceEpoch}.m4a';
        await _audioRecorder.start(const RecordConfig(encoder: AudioEncoder.aacLc, numChannels: 1), path: path);
        _state = _state.copyWith(audioPath: path);
      }
    } catch (e) {
      debugPrint('Recording start error: $e');
    }
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      final maxSecs = _state.currentPrompt?.speakTimeSeconds ?? 120;
      final nextSec = _state.recordingDuration + 1;
      _state = _state.copyWith(recordingDuration: nextSec);
      notifyListeners();
      if (nextSec >= maxSecs) stopRecording();
    });
  }

  Future<void> stopRecording() async {
    _timer?.cancel();
    String? finalPath = _state.audioPath;
    try {
      if (await _audioRecorder.isRecording()) {
        finalPath = await _audioRecorder.stop() ?? finalPath;
      }
    } catch (e) {
      debugPrint('Recording stop error: $e');
    }
    _state = _state.copyWith(practiceState: PracticeState.recorded, audioPath: finalPath, isTranscribing: true);
    notifyListeners();
    if (finalPath != null && File(finalPath).existsSync()) {
      try {
        final text = await _transcribeSpeakingAudio(finalPath);
        _state = _state.copyWith(transcript: text, isTranscribing: false);
      } catch (e) {
        _state = _state.copyWith(isTranscribing: false);
      }
    } else {
      _state = _state.copyWith(isTranscribing: false);
    }
    notifyListeners();
  }

  Future<SpeakingAIEvaluation?> evaluate({String? overrideTranscript}) async {
    final textToEval = overrideTranscript ?? _state.transcript;
    if (textToEval.trim().isEmpty) return null;
    _state = _state.copyWith(practiceState: PracticeState.evaluating, isEvaluating: true, clearError: true);
    notifyListeners();
    try {
      final eval = await _evaluateSpeaking(
        audioFilePath: _state.audioPath,
        transcript: textToEval,
        part: _state.selectedPart,
        prompt: _state.currentPrompt?.title ?? '',
      );
      _state = _state.copyWith(practiceState: PracticeState.evaluated, isEvaluating: false, evaluationResult: eval);
      notifyListeners();
      return eval;
    } catch (e) {
      _state = _state.copyWith(practiceState: PracticeState.recorded, isEvaluating: false, errorMessage: 'Evaluation failed: ${e.toString().replaceAll('Exception: ', '')}');
      notifyListeners();
      return null;
    }
  }

  void updateTranscript(String newText) {
    _state = _state.copyWith(transcript: newText);
    notifyListeners();
  }

  void resetPractice() {
    _timer?.cancel();
    _state = _state.copyWith(practiceState: PracticeState.idle, recordingDuration: 0, prepDuration: 0, clearAudio: true, clearEvaluation: true, transcript: '', clearError: true);
    notifyListeners();
  }
}
