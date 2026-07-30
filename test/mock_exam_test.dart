import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_english/features/mock_exam/domain/mock_exam_model.dart';
import 'package:easy_english/features/mock_exam/presentation/mock_exam_selection_screen.dart';
import 'package:easy_english/features/mock_exam/presentation/reading_practice_screen.dart';
import 'package:easy_english/features/mock_exam/presentation/listening_practice_screen.dart';
import 'package:easy_english/features/mock_exam/presentation/mock_result_screen.dart';

void main() {
  group('IELTS Raw Score to Band Converter Algorithm Tests', () {
    test('Academic Reading Raw Score to Band Conversion', () {
      expect(IeltsBandConverter.academicReadingRawToBand(40), 9.0);
      expect(IeltsBandConverter.academicReadingRawToBand(39), 9.0);
      expect(IeltsBandConverter.academicReadingRawToBand(37), 8.5);
      expect(IeltsBandConverter.academicReadingRawToBand(35), 8.0);
      expect(IeltsBandConverter.academicReadingRawToBand(33), 7.5);
      expect(IeltsBandConverter.academicReadingRawToBand(30), 7.0);
      expect(IeltsBandConverter.academicReadingRawToBand(27), 6.5);
      expect(IeltsBandConverter.academicReadingRawToBand(23), 6.0);
      expect(IeltsBandConverter.academicReadingRawToBand(19), 5.5);
      expect(IeltsBandConverter.academicReadingRawToBand(15), 5.0);
      expect(IeltsBandConverter.academicReadingRawToBand(10), 4.0);
      expect(IeltsBandConverter.academicReadingRawToBand(0), 1.0);
    });

    test('General Training Reading Raw Score to Band Conversion', () {
      expect(IeltsBandConverter.generalReadingRawToBand(40), 9.0);
      expect(IeltsBandConverter.generalReadingRawToBand(39), 8.5);
      expect(IeltsBandConverter.generalReadingRawToBand(37), 8.0);
      expect(IeltsBandConverter.generalReadingRawToBand(36), 7.5);
      expect(IeltsBandConverter.generalReadingRawToBand(34), 7.0);
      expect(IeltsBandConverter.generalReadingRawToBand(32), 6.5);
      expect(IeltsBandConverter.generalReadingRawToBand(30), 6.0);
      expect(IeltsBandConverter.generalReadingRawToBand(23), 5.0);
      expect(IeltsBandConverter.generalReadingRawToBand(0), 1.0);
    });

    test('Listening Raw Score to Band Conversion', () {
      expect(IeltsBandConverter.listeningRawToBand(40), 9.0);
      expect(IeltsBandConverter.listeningRawToBand(37), 8.5);
      expect(IeltsBandConverter.listeningRawToBand(35), 8.0);
      expect(IeltsBandConverter.listeningRawToBand(32), 7.5);
      expect(IeltsBandConverter.listeningRawToBand(30), 7.0);
      expect(IeltsBandConverter.listeningRawToBand(26), 6.5);
      expect(IeltsBandConverter.listeningRawToBand(23), 6.0);
      expect(IeltsBandConverter.listeningRawToBand(18), 5.5);
      expect(IeltsBandConverter.listeningRawToBand(10), 4.0);
      expect(IeltsBandConverter.listeningRawToBand(0), 1.0);
    });

    test('Official IELTS Overall Band Rounding Rules', () {
      // 6.25 -> 6.5
      expect(IeltsBandConverter.calculateOverallBand([6.0, 6.5, 6.0, 6.5]), 6.5);
      // 6.75 -> 7.0
      expect(IeltsBandConverter.calculateOverallBand([7.0, 6.5, 7.0, 6.5]), 7.0);
      // 6.125 -> 6.0
      expect(IeltsBandConverter.calculateOverallBand([6.0, 6.0, 6.0, 6.5]), 6.0);
      // 6.875 -> 7.0
      expect(IeltsBandConverter.calculateOverallBand([7.0, 7.0, 7.0, 6.5]), 7.0);
    });
  });

  group('Mock Exam Domain Models JSON Serialization Tests', () {
    test('MockQuestion JSON roundtrip', () {
      final q = MockQuestion(
        id: 'q_test_1',
        orderIndex: 1,
        questionType: QuestionType.multipleChoice,
        prompt: 'Sample Prompt Text',
        options: ['Opt A', 'Opt B'],
        correctAnswer: 'Opt A',
        explanation: 'Sample Explanation',
        sectionNumber: 1,
      );

      final jsonMap = q.toJson();
      final decoded = MockQuestion.fromJson(jsonMap);

      expect(decoded.id, q.id);
      expect(decoded.orderIndex, q.orderIndex);
      expect(decoded.questionType, q.questionType);
      expect(decoded.prompt, q.prompt);
      expect(decoded.options, q.options);
      expect(decoded.correctAnswer, q.correctAnswer);
      expect(decoded.explanation, q.explanation);
    });

    test('SampleMockExamData loads valid sample academic paper', () {
      final paper = SampleMockExamData.getSampleAcademicPaper();

      expect(paper.id, 'paper_academic_01');
      expect(paper.examType, ExamType.academic);
      expect(paper.sections.length, 2);
      expect(paper.sections[0].skill, MockSkill.reading);
      expect(paper.sections[1].skill, MockSkill.listening);
      expect(paper.sections[0].passages.isNotEmpty, true);
      expect(paper.sections[1].allQuestions.length, 10);
    });
  });

  group('Mock Exam Flutter UI Widget Tests', () {
    testWidgets('MockExamSelectionScreen renders dashboard elements cleanly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MockExamSelectionScreen(),
        ),
      );

      expect(find.text('IELTS Mock Exam Center'), findsOneWidget);
      expect(find.text('Academic (AC)'), findsOneWidget);
      expect(find.text('General Training (GT)'), findsOneWidget);
      expect(find.text('Reading'), findsOneWidget);
      expect(find.text('Listening'), findsOneWidget);
      expect(find.text('Writing'), findsOneWidget);
      expect(find.text('Speaking'), findsOneWidget);
      expect(find.text('Start Full Mock Exam (2h 45m)'), findsOneWidget);
    });

    testWidgets('ReadingPracticeScreen renders passage viewer and question panel', (WidgetTester tester) async {
      final samplePaper = SampleMockExamData.getSampleAcademicPaper();
      final readingSec = samplePaper.sections.first;

      await tester.pumpWidget(
        MaterialApp(
          home: ReadingPracticeScreen(
            section: readingSec,
            examType: ExamType.academic,
            paperTitle: samplePaper.title,
          ),
        ),
      );

      expect(find.text('Cambridge Official Practice Test 1 (Academic)'), findsOneWidget);
      expect(find.text('Submit Section'), findsOneWidget);
      expect(find.textContaining('Passage 1:'), findsOneWidget);
    });

    testWidgets('ListeningPracticeScreen renders audio player controls and 10-question form', (WidgetTester tester) async {
      final samplePaper = SampleMockExamData.getSampleAcademicPaper();
      final listeningSec = samplePaper.sections[1];

      await tester.pumpWidget(
        MaterialApp(
          home: ListeningPracticeScreen(
            section: listeningSec,
            examType: ExamType.academic,
            paperTitle: samplePaper.title,
          ),
        ),
      );

      expect(find.text('Official Audio Track'), findsOneWidget);
      expect(find.text('Audio Transcript'), findsOneWidget);
      expect(find.text('Submit Listening Answers'), findsOneWidget);
    });

    testWidgets('MockResultScreen renders Overall Band badge and detailed answer key', (WidgetTester tester) async {
      final samplePaper = SampleMockExamData.getSampleAcademicPaper();
      final readingSec = samplePaper.sections.first;

      final mockResult = MockExamResult(
        id: 'res_test_01',
        userId: 'user_1',
        examPaperId: readingSec.id,
        examTitle: 'Academic Practice Test 1',
        examType: ExamType.academic,
        overallBand: 7.5,
        readingBand: 7.5,
        listeningBand: 7.0,
        writingBand: 7.0,
        speakingBand: 7.5,
        readingRawScore: 34,
        listeningRawScore: 31,
        totalReadingQuestions: 40,
        totalListeningQuestions: 40,
        timeTakenSeconds: 3200,
        userAnswers: {'q1': 'C) Over 70%'},
        allQuestions: readingSec.allQuestions,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: MockResultScreen(result: mockResult),
        ),
      );

      expect(find.text('Mock Exam Performance Report'), findsOneWidget);
      expect(find.text('7.5'), findsOneWidget);
      expect(find.text('CEFR Equivalent: C1 Advanced'), findsOneWidget);
      expect(find.text('Detailed Answer Key'), findsOneWidget);
      expect(find.text('Back to Dashboard'), findsOneWidget);
    });
  });
}
