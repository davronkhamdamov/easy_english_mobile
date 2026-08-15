import 'package:flutter/material.dart';
import '../domain/entities/flashcard_item.dart';
import '../presentation/screens/flashcard_review_screen.dart';
import '../presentation/screens/word_bank_screen.dart';

class WordBankRoutes {
  static const String wordBank = '/word_bank';
  static const String flashcardReview = '/word_bank/review';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case wordBank:
        return MaterialPageRoute(builder: (_) => const WordBankScreen());
      case flashcardReview:
        final args = settings.arguments as Map<String, dynamic>?;
        final items = args?['items'] as List<FlashcardItem>?;
        return MaterialPageRoute(
          builder: (_) => FlashcardReviewScreen(initialItems: items),
        );
      default:
        return null;
    }
  }
}
