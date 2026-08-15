import '../../domain/entities/writing_evaluation.dart';
import '../../domain/entities/writing_prompt.dart';
import '../../domain/repositories/writing_repository.dart';
import '../datasources/writing_remote_datasource.dart';

class WritingRepositoryImpl implements WritingRepository {
  final WritingRemoteDatasource _remoteDatasource;

  WritingRepositoryImpl({WritingRemoteDatasource? remoteDatasource})
      : _remoteDatasource = remoteDatasource ?? WritingRemoteDatasource();

  @override
  Future<WritingEvaluation> evaluateWriting({
    required String essayText,
    required String prompt,
    String taskType = 'task2',
  }) async {
    final model = await _remoteDatasource.evaluateEssay(
      essayText: essayText,
      prompt: prompt,
      taskType: taskType,
    );
    return model.toEntity();
  }

  @override
  Future<List<WritingPrompt>> fetchWritingPrompts() async {
    final models = await _remoteDatasource.fetchWritingPrompts();
    return models.map((m) => m.toEntity()).toList();
  }
}
