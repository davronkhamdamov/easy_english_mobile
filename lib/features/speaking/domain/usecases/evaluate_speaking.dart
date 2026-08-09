import '../../data/repositories/speaking_repository_impl.dart';
import '../entities/speaking_evaluation.dart';
import '../repositories/speaking_repository.dart';

class EvaluateSpeaking {
  final SpeakingRepository _repository;

  EvaluateSpeaking({SpeakingRepository? repository})
    : _repository = repository ?? SpeakingRepositoryImpl();

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
