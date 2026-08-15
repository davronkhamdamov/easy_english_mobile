import '../entities/mock_exam_result.dart';
import '../repositories/mock_exam_repository.dart';

class GetExamHistoryUseCase {
  final MockExamRepository repository;

  GetExamHistoryUseCase(this.repository);

  Future<List<MockExamResult>> call({String? userId}) {
    return repository.getExamResultsHistory(userId: userId);
  }
}
