import '../entities/mock_exam_paper.dart';
import '../repositories/mock_exam_repository.dart';

class GetMockExamPaper {
  final MockExamRepository repository;

  GetMockExamPaper(this.repository);

  Future<MockExamPaper> call(String paperId) {
    return repository.getExamPaperById(paperId);
  }
}
