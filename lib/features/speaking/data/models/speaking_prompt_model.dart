import '../../domain/entities/speaking_prompt.dart';

class SpeakingPromptModel {
  final String id;
  final int part;
  final String topic;
  final String title;
  final List<String> cueCardPoints;
  final int prepTimeSeconds;
  final int speakTimeSeconds;

  const SpeakingPromptModel({
    required this.id,
    required this.part,
    required this.topic,
    required this.title,
    this.cueCardPoints = const [],
    this.prepTimeSeconds = 0,
    this.speakTimeSeconds = 120,
  });

  factory SpeakingPromptModel.fromJson(Map<String, dynamic> json) {
    final rawCuePoints = json['cue_card_points'] ??
        json['bulletPoints'] ??
        json['bullet_points'];
    final cuePoints = (rawCuePoints is List)
        ? rawCuePoints.map((e) => e.toString()).toList()
        : <String>[];

    return SpeakingPromptModel(
      id: json['id'] as String? ?? '',
      part: (json['part'] as num?)?.toInt() ?? 1,
      topic: json['topic'] as String? ?? '',
      title: json['title'] as String? ??
          json['promptText'] as String? ??
          json['prompt_text'] as String? ??
          '',
      cueCardPoints: cuePoints,
      prepTimeSeconds: (json['prep_time_seconds'] as num?)?.toInt() ??
          (json['prepTimeSeconds'] as num?)?.toInt() ??
          0,
      speakTimeSeconds: (json['speak_time_seconds'] as num?)?.toInt() ??
          (json['speaking_time_seconds'] as num?)?.toInt() ??
          (json['speakingTimeSeconds'] as num?)?.toInt() ??
          120,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'part': part,
      'topic': topic,
      'title': title,
      'cue_card_points': cueCardPoints,
      'prep_time_seconds': prepTimeSeconds,
      'speak_time_seconds': speakTimeSeconds,
    };
  }

  SpeakingPrompt toEntity() {
    return SpeakingPrompt(
      id: id,
      part: part,
      topic: topic,
      title: title,
      cueCardPoints: cueCardPoints,
      prepTimeSeconds: prepTimeSeconds,
      speakTimeSeconds: speakTimeSeconds,
    );
  }
}
