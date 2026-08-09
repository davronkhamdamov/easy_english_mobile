import '../entities/speaking_evaluation.dart';
import '../entities/speaking_prompt.dart';

abstract class SpeakingRepository {
  Future<SpeakingAIEvaluation> evaluateSpeaking({
    String? audioFilePath,
    String? transcript,
    int part = 1,
    String? prompt,
  });

  Future<String> transcribeSpeakingAudio(String audioFilePath);

  Future<List<SpeakingPrompt>> fetchSpeakingPrompts();
}
