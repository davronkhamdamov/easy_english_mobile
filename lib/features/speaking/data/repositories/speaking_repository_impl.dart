import '../../domain/entities/speaking_evaluation.dart';
import '../../domain/entities/speaking_prompt.dart';
import '../../domain/repositories/speaking_repository.dart';
import '../datasources/speaking_remote_datasource.dart';

class SpeakingRepositoryImpl implements SpeakingRepository {
  final SpeakingRemoteDatasource _remoteDatasource;

  SpeakingRepositoryImpl({SpeakingRemoteDatasource? remoteDatasource})
    : _remoteDatasource = remoteDatasource ?? SpeakingRemoteDatasource();

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

  @override
  Future<String> transcribeSpeakingAudio(String audioFilePath) {
    return _remoteDatasource.transcribeSpeakingAudio(audioFilePath);
  }

  @override
  Future<List<SpeakingPrompt>> fetchSpeakingPrompts() async {
    final models = await _remoteDatasource.fetchSpeakingPrompts();
    if (models.isEmpty) {
      return SpeakingPrompt.samplePrompts;
    }
    return models.map((m) => m.toEntity()).toList();
  }
}
