import '../entities/writing_evaluation.dart';
import '../repositories/writing_repository.dart';
import '../../data/repositories/writing_repository_impl.dart';

class EvaluateEssayUseCase {
  final WritingRepository _repository;

  EvaluateEssayUseCase({WritingRepository? repository})
      : _repository = repository ?? WritingRepositoryImpl();

  Future<WritingEvaluation> call({
    required String essayText,
    required String prompt,
    String taskType = 'task2',
  }) async {
    final trimmed = essayText.trim();
    final words = trimmed.isEmpty ? 0 : trimmed.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;

    if (words < 50) {
      throw Exception('Essay must be at least 50 words for evaluation. (Current: $words words)');
    }

    return _repository.evaluateWriting(
      essayText: trimmed,
      prompt: prompt,
      taskType: taskType,
    );
  }
}
