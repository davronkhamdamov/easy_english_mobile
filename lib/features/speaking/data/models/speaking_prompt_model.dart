import '../../domain/entities/speaking_prompt.dart';

class SpeakingPromptModel {
  final String id;
  final int part;
  final String topic;
  final String promptText;
  final List<String> bulletPoints;
  final int prepTimeSeconds;
  final int speakingTimeSeconds;

  const SpeakingPromptModel({
    required this.id,
    required this.part,
    required this.topic,
    required this.promptText,
    this.bulletPoints = const [],
    this.prepTimeSeconds = 0,
    this.speakingTimeSeconds = 120,
  });

  factory SpeakingPromptModel.fromJson(Map<String, dynamic> json) {
    return SpeakingPromptModel(
      id: json['id'] as String? ?? '',
      part: (json['part'] as num?)?.toInt() ?? 1,
      topic: json['topic'] as String? ?? '',
      promptText:
          json['promptText'] as String? ?? json['prompt_text'] as String? ?? '',
      bulletPoints:
          (json['bulletPoints'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          (json['bullet_points'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      prepTimeSeconds:
          (json['prepTimeSeconds'] as num?)?.toInt() ??
          (json['prep_time_seconds'] as num?)?.toInt() ??
          0,
      speakingTimeSeconds:
          (json['speakingTimeSeconds'] as num?)?.toInt() ??
          (json['speaking_time_seconds'] as num?)?.toInt() ??
          120,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'part': part,
      'topic': topic,
      'promptText': promptText,
      'bulletPoints': bulletPoints,
      'prepTimeSeconds': prepTimeSeconds,
      'speakingTimeSeconds': speakingTimeSeconds,
    };
  }

  SpeakingPrompt toEntity() {
    return SpeakingPrompt(
      id: id,
      part: part,
      topic: topic,
      promptText: promptText,
      bulletPoints: bulletPoints,
      prepTimeSeconds: prepTimeSeconds,
      speakingTimeSeconds: speakingTimeSeconds,
    );
  }

  factory SpeakingPromptModel.fromEntity(SpeakingPrompt entity) {
    return SpeakingPromptModel(
      id: entity.id,
      part: entity.part,
      topic: entity.topic,
      promptText: entity.promptText,
      bulletPoints: entity.bulletPoints,
      prepTimeSeconds: entity.prepTimeSeconds,
      speakingTimeSeconds: entity.speakingTimeSeconds,
    );
  }
}
