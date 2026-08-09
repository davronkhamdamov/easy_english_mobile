import '../entities/flashcard_item.dart';
import '../services/spaced_repetition.dart';

/// Contract interface for Word Bank domain operations.
abstract class WordBankRepository {
  /// Fetch all vocabulary items in the Word Bank.
  Future<List<FlashcardItem>> getWordBankItems();

  /// Fetch vocabulary items that are due for spaced repetition review.
  Future<List<FlashcardItem>> getDueFlashcards();

  /// Submit review rating for a card and return updated item.
  Future<FlashcardItem> submitReview({
    required String id,
    required ReviewRating rating,
  });

  /// Add a new word to the user's Word Bank.
  Future<FlashcardItem> addWord(FlashcardItem item);

  /// Remove a word from the Word Bank.
  Future<bool> removeWord(String id);
}
