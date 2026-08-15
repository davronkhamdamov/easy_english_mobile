import 'package:flutter/material.dart';
import '../domain/entities/mock_exam_paper.dart';
import '../domain/entities/mock_exam_result.dart';
import '../domain/entities/mock_exam_section.dart';
import '../presentation/screens/listening_practice_screen.dart';
import '../presentation/screens/mock_exam_selection_screen.dart';
import '../presentation/screens/mock_result_screen.dart';
import '../presentation/screens/reading_practice_screen.dart';

class MockExamRoutes {
  static const String selection = '/mock-exam';
  static const String reading = '/mock-exam/reading';
  static const String listening = '/mock-exam/listening';
  static const String result = '/mock-exam/result';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      selection: (context) => const MockExamSelectionScreen(),
      reading: (context) {
        final args = ModalRoute.of(context)?.settings.arguments;
        if (args is MockExamPaper) return ReadingPracticeScreen(paper: args);
        if (args is MockExamSection) return ReadingPracticeScreen(section: args);
        return const ReadingPracticeScreen();
      },
      listening: (context) {
        final args = ModalRoute.of(context)?.settings.arguments;
        if (args is MockExamPaper) return ListeningPracticeScreen(paper: args);
        if (args is MockExamSection) return ListeningPracticeScreen(section: args);
        return const ListeningPracticeScreen();
      },
      result: (context) {
        final args = ModalRoute.of(context)?.settings.arguments as MockExamResult?;
        if (args != null) return MockResultScreen(result: args);
        throw ArgumentError('MockExamResult is required for result route');
      },
    };
  }
}
