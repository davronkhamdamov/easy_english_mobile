import '../entities/writing_prompt.dart';
import '../repositories/writing_repository.dart';
import '../../data/repositories/writing_repository_impl.dart';

class GetWritingPromptsUseCase {
  final WritingRepository _repository;

  GetWritingPromptsUseCase({WritingRepository? repository})
      : _repository = repository ?? WritingRepositoryImpl();

  Future<List<WritingPrompt>> call({String? taskType}) async {
    final prompts = await _repository.fetchWritingPrompts();
    if (taskType != null && taskType.isNotEmpty) {
      final normalized = taskType.toLowerCase().contains('1') ? 'task1' : 'task2';
      return prompts.where((p) => p.taskType.toLowerCase() == normalized).toList();
    }
    return prompts;
  }
}
