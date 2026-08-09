import '../entities/mock_exam_result.dart';
import '../repositories/mock_exam_repository.dart';

class SubmitMockExam {
  final MockExamRepository repository;

  SubmitMockExam(this.repository);

  Future<MockExamResult> call(MockExamResult result) {
    return repository.submitExamResult(result);
  }
}
