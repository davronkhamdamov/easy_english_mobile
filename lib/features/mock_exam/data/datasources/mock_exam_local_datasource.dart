import '../../domain/entities/exam_enums.dart';
import '../../domain/entities/mock_exam_paper.dart';
import '../../domain/entities/mock_exam_passage.dart';
import '../../domain/entities/mock_exam_section.dart';
import '../../domain/entities/mock_question.dart';

/// Test helper providing mock paper structures for unit tests only.
class SampleMockExamData {
  SampleMockExamData._();

  static MockExamPaper getSampleAcademicPaper() {
    final passage1 = MockExamPassage(
      id: 'pass_ac_01',
      title: 'Passage 1: The History of Glassmaking',
      content:
          'Glassmaking can be traced back to 3500 BC in Mesopotamia. '
          'Early glass objects were mostly beads, created accidentally during metalworking.',
      sectionNumber: 1,
      questions: [
        MockQuestion(
          id: 'q1',
          orderIndex: 1,
          questionType: QuestionType.trueFalseNotGiven,
          prompt: 'Glass was first produced in Ancient Egypt.',
          options: const ['TRUE', 'FALSE', 'NOT GIVEN'],
          correctAnswer: 'FALSE',
          explanation: 'Paragraph 1 states it originated in Mesopotamia.',
          passageId: 'pass_ac_01',
          sectionNumber: 1,
        ),
      ],
    );

    final section1 = MockExamSection(
      id: 'sec_ac_reading',
      skill: MockSkill.reading,
      title: 'Reading Test 1',
      timeLimitMinutes: 60,
      passages: [passage1],
    );

    final listeningQuestions = List.generate(
      10,
      (i) => MockQuestion(
        id: 'q_list_${i + 1}',
        orderIndex: i + 1,
        questionType: QuestionType.multipleChoice,
        prompt: 'Question ${i + 1} regarding listening text',
        options: const ['Option A', 'Option B', 'Option C', 'Option D'],
        correctAnswer: 'Option A',
        explanation: 'Audio segment confirms Option A.',
        sectionNumber: 2,
      ),
    );

    final section2 = MockExamSection(
      id: 'sec_ac_listening',
      skill: MockSkill.listening,
      title: 'Listening Test 1',
      timeLimitMinutes: 40,
      audioUrl: 'https://example.com/audio1.mp3',
      transcript: 'Welcome to the listening comprehension test...',
      questions: listeningQuestions,
    );

    return MockExamPaper(
      id: 'paper_academic_01',
      title: 'Cambridge Official Practice Test 1 (Academic)',
      examType: ExamType.academic,
      description: 'Full 4-skill mock examination with standard IELTS timer.',
      difficulty: 'Hard',
      durationMinutes: 160,
      totalQuestions: 80,
      audioUrl: 'https://example.com/audio1.mp3',
      passageText: passage1.content,
      questions: passage1.questions,
      sections: [section1, section2],
    );
  }
}
