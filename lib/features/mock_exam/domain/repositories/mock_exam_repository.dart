import '../entities/exam_enums.dart';
import '../entities/mock_exam_paper.dart';
import '../entities/mock_exam_result.dart';

abstract class MockExamRepository {
  Future<List<MockExamPaper>> getAvailableExams({ExamType? examType});
  Future<MockExamPaper> getExamPaperById(String paperId);
  Future<MockExamResult> submitExamResult(MockExamResult result);
  Future<List<MockExamResult>> getExamResultsHistory({String? userId});
}
