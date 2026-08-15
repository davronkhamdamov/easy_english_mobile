import '../../domain/entities/speaking_evaluation.dart';
import '../../domain/entities/speaking_prompt.dart';
import '../../domain/repositories/speaking_repository.dart';
import '../datasources/speaking_remote_datasource.dart';

class SpeakingRepositoryImpl implements SpeakingRepository {
  final SpeakingRemoteDatasource _remoteDatasource;

  SpeakingRepositoryImpl({SpeakingRemoteDatasource? remoteDatasource})
      : _remoteDatasource = remoteDatasource ?? SpeakingRemoteDatasource();

  @override
  Future<List<SpeakingPrompt>> fetchSpeakingPrompts({int? part}) async {
    final models = await _remoteDatasource.fetchSpeakingPrompts();
    final entities = models.map((m) => m.toEntity()).toList();
    if (part != null) {
      return entities.where((p) => p.part == part).toList();
    }
    return entities;
  }

  @override
  Future<String> transcribeSpeakingAudio(String audioFilePath) {
    return _remoteDatasource.transcribeSpeakingAudio(audioFilePath);
  }

  @override
  Future<SpeakingAIEvaluation> evaluateSpeaking({
    String? audioFilePath,
    String? transcript,
    int part = 1,
    String? prompt,
  }) async {
    final model = await _remoteDatasource.evaluateSpeaking(
      audioFilePath: audioFilePath,
      transcript: transcript,
      part: part,
      prompt: prompt,
    );
    return model.toEntity();
  }
}
