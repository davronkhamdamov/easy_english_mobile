import '../../data/repositories/writing_repository_impl.dart';
import '../entities/writing_evaluation.dart';
import '../repositories/writing_repository.dart';

class EvaluateWriting {
  final WritingRepository _repository;

  EvaluateWriting({WritingRepository? repository})
    : _repository = repository ?? WritingRepositoryImpl();

  Future<WritingEvaluation> call({
    required String essayText,
    required String prompt,
    String taskType = 'task2',
  }) {
    return _repository.evaluateWriting(
      essayText: essayText,
      prompt: prompt,
      taskType: taskType,
    );
  }
}
