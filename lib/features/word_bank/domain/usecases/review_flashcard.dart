import '../entities/flashcard_item.dart';
import '../repositories/word_bank_repository.dart';
import '../services/spaced_repetition.dart';

class ReviewFlashcard {
  final WordBankRepository _repository;

  ReviewFlashcard(this._repository);

  Future<FlashcardItem> call({
    required String id,
    required ReviewRating rating,
  }) async {
    return await _repository.submitReview(id: id, rating: rating);
  }
}

typedef SubmitFlashcardReviewUseCase = ReviewFlashcard;
