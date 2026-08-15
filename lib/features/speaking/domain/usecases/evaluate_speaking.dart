import '../entities/speaking_evaluation.dart';
import '../repositories/speaking_repository.dart';

class EvaluateSpeaking {
  final SpeakingRepository _repository;

  EvaluateSpeaking(this._repository);

  Future<SpeakingAIEvaluation> call({
    String? audioFilePath,
    String? transcript,
    int part = 1,
    String? prompt,
  }) {
    return _repository.evaluateSpeaking(
      audioFilePath: audioFilePath,
      transcript: transcript,
      part: part,
      prompt: prompt,
    );
  }
}
