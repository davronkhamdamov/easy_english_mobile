class PronunciationTip {
  final String word;
  final String phonetic;
  final String tip;

  const PronunciationTip({
    required this.word,
    required this.phonetic,
    required this.tip,
  });

  factory PronunciationTip.fromJson(Map<String, dynamic> json) {
    return PronunciationTip(
      word: json['word'] as String? ?? '',
      phonetic: json['phonetic'] as String? ?? '',
      tip: json['tip'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'word': word,
      'phonetic': phonetic,
      'tip': tip,
    };
  }
}
