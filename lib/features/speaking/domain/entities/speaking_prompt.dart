/// Represents an IELTS Speaking prompt (Part 1 Q&A, Part 2 Cue Card, or Part 3 Discussion).
class SpeakingPrompt {
  final String id;
  final int part; // 1, 2, or 3
  final String topic;
  final String title;
  final List<String> cueCardPoints;
  final int prepTimeSeconds;
  final int speakTimeSeconds;

  String get promptText => title;
  List<String> get bulletPoints => cueCardPoints;
  int get speakingTimeSeconds => speakTimeSeconds;

  const SpeakingPrompt({
    required this.id,
    required this.part,
    required this.topic,
    required this.title,
    this.cueCardPoints = const [],
    this.prepTimeSeconds = 0,
    this.speakTimeSeconds = 120,
  });

  SpeakingPrompt copyWith({
    String? id,
    int? part,
    String? topic,
    String? title,
    List<String>? cueCardPoints,
    int? prepTimeSeconds,
    int? speakTimeSeconds,
  }) {
    return SpeakingPrompt(
      id: id ?? this.id,
      part: part ?? this.part,
      topic: topic ?? this.topic,
      title: title ?? this.title,
      cueCardPoints: cueCardPoints ?? this.cueCardPoints,
      prepTimeSeconds: prepTimeSeconds ?? this.prepTimeSeconds,
      speakTimeSeconds: speakTimeSeconds ?? this.speakTimeSeconds,
    );
  }
}
