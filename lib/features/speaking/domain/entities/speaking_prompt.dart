/// Represents an IELTS Speaking prompt (Part 1, Part 2 cue card, or Part 3 discussion).
class SpeakingPrompt {
  final String id;
  final int part; // 1, 2, or 3
  final String topic;
  final String promptText;
  final List<String> bulletPoints;
  final int prepTimeSeconds;
  final int speakingTimeSeconds;

  String get title => topic;

  const SpeakingPrompt({
    required this.id,
    required this.part,
    required this.topic,
    required this.promptText,
    this.bulletPoints = const [],
    this.prepTimeSeconds = 0,
    this.speakingTimeSeconds = 120,
  });

  SpeakingPrompt copyWith({
    String? id,
    int? part,
    String? topic,
    String? promptText,
    List<String>? bulletPoints,
    int? prepTimeSeconds,
    int? speakingTimeSeconds,
  }) {
    return SpeakingPrompt(
      id: id ?? this.id,
      part: part ?? this.part,
      topic: topic ?? this.topic,
      promptText: promptText ?? this.promptText,
      bulletPoints: bulletPoints ?? this.bulletPoints,
      prepTimeSeconds: prepTimeSeconds ?? this.prepTimeSeconds,
      speakingTimeSeconds: speakingTimeSeconds ?? this.speakingTimeSeconds,
    );
  }

  static const List<SpeakingPrompt> samplePrompts = [
    SpeakingPrompt(
      id: 'sp_p1_01',
      part: 1,
      topic: 'Hometown & Living Environment',
      promptText:
          'Describe your hometown and what you like most about living there. How has it changed in recent years?',
      bulletPoints: [
        'Where your hometown is located and its general geography',
        'What facilities, landmarks, or parks it features',
        'What activities or places you enjoy most when staying there',
      ],
      prepTimeSeconds: 0,
      speakingTimeSeconds: 60,
    ),
    SpeakingPrompt(
      id: 'sp_p2_01',
      part: 2,
      topic: 'A Memorable Journey (Cue Card)',
      promptText:
          'Describe a memorable journey you took by car, train, or airplane.',
      bulletPoints: [
        'Where you went and who you traveled with',
        'What memorable events or sights occurred during the trip',
        'Why this particular journey remains special in your memory',
        'And explain what insights or skills you gained from this experience',
      ],
      prepTimeSeconds: 60,
      speakingTimeSeconds: 120,
    ),
    SpeakingPrompt(
      id: 'sp_p3_01',
      part: 3,
      topic: 'Transportation & Urban Mobility',
      promptText:
          'How do you think urban public transportation systems will evolve over the next two decades?',
      bulletPoints: [
        'Environmental tradeoffs between private vehicles and high-speed rail',
        'The impact of autonomous electric fleets on traffic congestion',
        'Government subsidies and eco-friendly urban infrastructure investments',
      ],
      prepTimeSeconds: 0,
      speakingTimeSeconds: 180,
    ),
  ];
}
