import '../entities/writing_evaluation.dart';
import '../entities/writing_prompt.dart';

abstract class WritingRepository {
  Future<List<WritingPrompt>> fetchWritingPrompts();
  Future<WritingEvaluation> evaluateWriting({
    required String essayText,
    required String prompt,
    String taskType = 'task2',
  });
}
