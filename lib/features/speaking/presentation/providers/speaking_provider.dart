import 'package:flutter/foundation.dart';
import '../../domain/entities/speaking_evaluation.dart';
import '../../domain/entities/speaking_prompt.dart';
import '../../domain/usecases/evaluate_speaking.dart';
import '../../domain/usecases/fetch_speaking_prompts.dart';
import '../../domain/usecases/transcribe_speaking_audio.dart';

class SpeakingProvider extends ChangeNotifier {
  final EvaluateSpeaking _evaluateSpeaking;
  final TranscribeSpeakingAudio _transcribeSpeakingAudio;
  final FetchSpeakingPrompts _fetchSpeakingPrompts;

  List<SpeakingPrompt> _prompts = SpeakingPrompt.samplePrompts;
  bool _isLoading = false;
  String? _errorMessage;

  SpeakingProvider({
    EvaluateSpeaking? evaluateSpeaking,
    TranscribeSpeakingAudio? transcribeSpeakingAudio,
    FetchSpeakingPrompts? fetchSpeakingPrompts,
  }) : _evaluateSpeaking = evaluateSpeaking ?? EvaluateSpeaking(),
       _transcribeSpeakingAudio =
           transcribeSpeakingAudio ?? TranscribeSpeakingAudio(),
       _fetchSpeakingPrompts = fetchSpeakingPrompts ?? FetchSpeakingPrompts();

  List<SpeakingPrompt> get prompts => _prompts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadPrompts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fetched = await _fetchSpeakingPrompts();
      if (fetched.isNotEmpty) {
        _prompts = fetched;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<SpeakingAIEvaluation> evaluate({
    String? audioFilePath,
    String? transcript,
    int part = 1,
    String? prompt,
  }) {
    return _evaluateSpeaking(
      audioFilePath: audioFilePath,
      transcript: transcript,
      part: part,
      prompt: prompt,
    );
  }

  Future<String> transcribe(String audioFilePath) {
    return _transcribeSpeakingAudio(audioFilePath);
  }
}
