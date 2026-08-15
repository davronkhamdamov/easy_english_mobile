import '../entities/exam_enums.dart';
import '../entities/mock_exam_paper.dart';
import '../repositories/mock_exam_repository.dart';

class GetAvailableMockExams {
  final MockExamRepository repository;

  GetAvailableMockExams(this.repository);

  Future<List<MockExamPaper>> call({ExamType? examType, String? type}) {
    return repository.getAvailableExams(examType: examType, type: type);
  }
}

typedef GetAvailableExamsUseCase = GetAvailableMockExams;
