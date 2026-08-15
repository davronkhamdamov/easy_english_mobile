import '../../domain/entities/writing_evaluation.dart';

class VocabularySuggestionModel {
  final String usedWord;
  final List<String> suggestedAlternatives;

  VocabularySuggestionModel({
    required this.usedWord,
    required this.suggestedAlternatives,
  });

  factory VocabularySuggestionModel.fromJson(Map<String, dynamic> json) {
    final rawAlts = json['suggested_alternatives'] ?? json['alternatives'];
    List<String> alts = [];
    if (rawAlts is List) {
      alts = rawAlts.map((e) => e.toString()).toList();
    }
    return VocabularySuggestionModel(
      usedWord: (json['used_word'] ?? json['original'] ?? '').toString(),
      suggestedAlternatives: alts,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'used_word': usedWord,
      'suggested_alternatives': suggestedAlternatives,
    };
  }

  VocabularySuggestion toEntity() {
    return VocabularySuggestion(
      usedWord: usedWord,
      suggestedAlternatives: suggestedAlternatives,
    );
  }
}
