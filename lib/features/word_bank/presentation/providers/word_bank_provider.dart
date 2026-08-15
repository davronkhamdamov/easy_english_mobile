import 'package:flutter/foundation.dart';
import '../../data/repositories/word_bank_repository_impl.dart';
import '../../domain/entities/flashcard_item.dart';
import '../../domain/repositories/word_bank_repository.dart';
import '../../domain/services/spaced_repetition.dart';
import '../state/word_bank_state.dart';

class WordBankProvider extends ChangeNotifier {
  final WordBankRepository _repository;

  WordBankState _state = const WordBankState();

  WordBankProvider({WordBankRepository? repository})
      : _repository = repository ?? WordBankRepositoryImpl();

  WordBankState get state => _state;

  Future<void> loadWordBank() async {
    _state = _state.copyWith(isLoading: true, clearError: true);
    notifyListeners();

    try {
      final items = await _repository.getWordBankItems();
      List<FlashcardItem> due = [];
      try {
        due = await _repository.getDueFlashcards();
      } catch (_) {
        due = items.where((i) => i.intervalDays <= 1).toList();
      }
      _state = _state.copyWith(
        isLoading: false,
        wordItems: items,
        dueFlashcards: due,
      );
    } catch (e) {
      _state = _state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    } finally {
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _state = _state.copyWith(searchQuery: query);
    notifyListeners();
  }

  void setCefrFilter(String filter) {
    _state = _state.copyWith(selectedCefrFilter: filter);
    notifyListeners();
  }

  void toggleFlip() {
    _state = _state.copyWith(isFlipped: !_state.isFlipped);
    notifyListeners();
  }

  void resetFlip() {
    _state = _state.copyWith(isFlipped: false);
    notifyListeners();
  }

  Future<bool> addWord(FlashcardItem item) async {
    _state = _state.copyWith(isSubmitting: true, clearError: true);
    notifyListeners();

    try {
      final saved = await _repository.addWord(item);
      final updatedList = List<FlashcardItem>.from(_state.wordItems)..add(saved);
      _state = _state.copyWith(
        isSubmitting: false,
        wordItems: updatedList,
        successMessage: 'Added "${saved.word}" to Word Bank',
      );
      notifyListeners();
      return true;
    } catch (e) {
      _state = _state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteWord(String id) async {
    _state = _state.copyWith(isSubmitting: true, clearError: true);
    notifyListeners();

    try {
      final success = await _repository.removeWord(id);
      if (success) {
        final updatedList =
            _state.wordItems.where((element) => element.id != id).toList();
        _state = _state.copyWith(
          isSubmitting: false,
          wordItems: updatedList,
          successMessage: 'Word deleted successfully',
        );
      }
      notifyListeners();
      return success;
    } catch (e) {
      _state = _state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      notifyListeners();
      return false;
    }
  }

  Future<void> submitReview(String id, ReviewRating rating) async {
    try {
      final updated = await _repository.submitReview(id: id, rating: rating);
      final updatedList = _state.wordItems.map((item) {
        return item.id == id ? updated : item;
      }).toList();

      _state = _state.copyWith(
        wordItems: updatedList,
        isFlipped: false,
      );
      notifyListeners();
    } catch (e) {
      _state = _state.copyWith(
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      notifyListeners();
    }
  }
}
