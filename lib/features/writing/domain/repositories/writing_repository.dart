import '../entities/writing_evaluation.dart';
import '../entities/writing_prompt.dart';

abstract class WritingRepository {
  Future<WritingEvaluation> evaluateWriting({
    required String essayText,
    required String prompt,
    String taskType = 'task2',
  });

  Future<List<WritingPrompt>> fetchWritingPrompts();
}
