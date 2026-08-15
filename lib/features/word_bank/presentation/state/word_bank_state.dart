import '../../domain/entities/flashcard_item.dart';

class WordBankState {
  final bool isLoading;
  final bool isSubmitting;
  final List<FlashcardItem> wordItems;
  final List<FlashcardItem> dueFlashcards;
  final String searchQuery;
  final String selectedCefrFilter;
  final String? errorMessage;
  final String? successMessage;
  final int currentReviewIndex;
  final bool isFlipped;

  const WordBankState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.wordItems = const [],
    this.dueFlashcards = const [],
    this.searchQuery = '',
    this.selectedCefrFilter = 'All',
    this.errorMessage,
    this.successMessage,
    this.currentReviewIndex = 0,
    this.isFlipped = false,
  });

  List<FlashcardItem> get filteredWordItems {
    return wordItems.where((item) {
      final matchesSearch = searchQuery.isEmpty ||
          item.word.toLowerCase().contains(searchQuery.toLowerCase()) ||
          item.definition.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesCefr = selectedCefrFilter == 'All' ||
          item.cefrLevel.toUpperCase() == selectedCefrFilter.toUpperCase();
      return matchesSearch && matchesCefr;
    }).toList();
  }

  int get totalWordsCount => wordItems.length;
  int get dueTodayCount => dueFlashcards.length;
  int get masteredCount =>
      wordItems.where((item) => item.masteryLevel >= 4).toList().length;

  WordBankState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    List<FlashcardItem>? wordItems,
    List<FlashcardItem>? dueFlashcards,
    String? searchQuery,
    String? selectedCefrFilter,
    String? errorMessage,
    String? successMessage,
    int? currentReviewIndex,
    bool? isFlipped,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return WordBankState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      wordItems: wordItems ?? this.wordItems,
      dueFlashcards: dueFlashcards ?? this.dueFlashcards,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCefrFilter: selectedCefrFilter ?? this.selectedCefrFilter,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
      currentReviewIndex: currentReviewIndex ?? this.currentReviewIndex,
      isFlipped: isFlipped ?? this.isFlipped,
    );
  }
}
