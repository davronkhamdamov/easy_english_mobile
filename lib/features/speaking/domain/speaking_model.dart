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

  factory SpeakingPrompt.fromJson(Map<String, dynamic> json) {
    return SpeakingPrompt(
      id: json['id'] as String? ?? '',
      part: (json['part'] as num?)?.toInt() ?? 1,
      topic: json['topic'] as String? ?? '',
      promptText: json['promptText'] as String? ?? json['prompt_text'] as String? ?? '',
      bulletPoints: (json['bulletPoints'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          (json['bullet_points'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      prepTimeSeconds: (json['prepTimeSeconds'] as num?)?.toInt() ??
          (json['prep_time_seconds'] as num?)?.toInt() ??
          0,
      speakingTimeSeconds: (json['speakingTimeSeconds'] as num?)?.toInt() ??
          (json['speaking_time_seconds'] as num?)?.toInt() ??
          120,
    );
  }

  static const List<SpeakingPrompt> samplePrompts = [
    SpeakingPrompt(
      id: 'sp_p1_01',
      part: 1,
      topic: 'Hometown & Living Environment',
      promptText: 'Describe your hometown and what you like most about living there. How has it changed in recent years?',
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
      promptText: 'Describe a memorable journey you took by car, train, or airplane.',
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
      promptText: 'How do you think urban public transportation systems will evolve over the next two decades?',
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

/// Models a recorded audio submission for an IELTS Speaking prompt.
class AudioSubmission {
  final String id;
  final String promptId;
  final String? audioPath;
  final int durationSeconds;
  final DateTime recordedAt;

  const AudioSubmission({
    required this.id,
    required this.promptId,
    this.audioPath,
    required this.durationSeconds,
    required this.recordedAt,
  });

  AudioSubmission copyWith({
    String? id,
    String? promptId,
    String? audioPath,
    int? durationSeconds,
    DateTime? recordedAt,
  }) {
    return AudioSubmission(
      id: id ?? this.id,
      promptId: promptId ?? this.promptId,
      audioPath: audioPath ?? this.audioPath,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      recordedAt: recordedAt ?? this.recordedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'promptId': promptId,
      'audioPath': audioPath,
      'durationSeconds': durationSeconds,
      'recordedAt': recordedAt.toIso8601String(),
    };
  }

  factory AudioSubmission.fromJson(Map<String, dynamic> json) {
    return AudioSubmission(
      id: json['id'] as String? ?? '',
      promptId: json['promptId'] as String? ?? json['prompt_id'] as String? ?? '',
      audioPath: json['audioPath'] as String? ?? json['audio_path'] as String?,
      durationSeconds: (json['durationSeconds'] as num?)?.toInt() ??
          (json['duration_seconds'] as num?)?.toInt() ??
          0,
      recordedAt: json['recordedAt'] != null
          ? DateTime.parse(json['recordedAt'] as String)
          : (json['recorded_at'] != null
              ? DateTime.parse(json['recorded_at'] as String)
              : DateTime.now()),
    );
  }
}

/// Represents an AI evaluation for an IELTS Speaking response.
class SpeakingAIEvaluation {
  final String id;
  final String submissionId;
  final double overallBand;
  final double fluencyCoherenceBand;
  final double lexicalResourceBand;
  final double grammarRangeBand;
  final double pronunciationBand;
  final String transcript;
  final List<String> grammarErrors;
  final List<String> vocabularyTips;
  final List<String> strengths;
  final List<String> areasForImprovement;
  final DateTime evaluatedAt;

  const SpeakingAIEvaluation({
    required this.id,
    required this.submissionId,
    required this.overallBand,
    required this.fluencyCoherenceBand,
    required this.lexicalResourceBand,
    required this.grammarRangeBand,
    required this.pronunciationBand,
    required this.transcript,
    this.grammarErrors = const [],
    this.vocabularyTips = const [],
    this.strengths = const [],
    this.areasForImprovement = const [],
    required this.evaluatedAt,
  });

  SpeakingAIEvaluation copyWith({
    String? id,
    String? submissionId,
    double? overallBand,
    double? fluencyCoherenceBand,
    double? lexicalResourceBand,
    double? grammarRangeBand,
    double? pronunciationBand,
    String? transcript,
    List<String>? grammarErrors,
    List<String>? vocabularyTips,
    List<String>? strengths,
    List<String>? areasForImprovement,
    DateTime? evaluatedAt,
  }) {
    return SpeakingAIEvaluation(
      id: id ?? this.id,
      submissionId: submissionId ?? this.submissionId,
      overallBand: overallBand ?? this.overallBand,
      fluencyCoherenceBand: fluencyCoherenceBand ?? this.fluencyCoherenceBand,
      lexicalResourceBand: lexicalResourceBand ?? this.lexicalResourceBand,
      grammarRangeBand: grammarRangeBand ?? this.grammarRangeBand,
      pronunciationBand: pronunciationBand ?? this.pronunciationBand,
      transcript: transcript ?? this.transcript,
      grammarErrors: grammarErrors ?? this.grammarErrors,
      vocabularyTips: vocabularyTips ?? this.vocabularyTips,
      strengths: strengths ?? this.strengths,
      areasForImprovement: areasForImprovement ?? this.areasForImprovement,
      evaluatedAt: evaluatedAt ?? this.evaluatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'submissionId': submissionId,
      'overall_band': overallBand,
      'fluency_coherence_band': fluencyCoherenceBand,
      'lexical_resource_band': lexicalResourceBand,
      'grammar_range_band': grammarRangeBand,
      'pronunciation_band': pronunciationBand,
      'transcript': transcript,
      'grammar_errors': grammarErrors,
      'vocabulary_tips': vocabularyTips,
      'strengths': strengths,
      'areas_for_improvement': areasForImprovement,
      'evaluated_at': evaluatedAt.toIso8601String(),
    };
  }

  factory SpeakingAIEvaluation.fromJson(Map<String, dynamic> json) {
    return SpeakingAIEvaluation(
      id: json['id'] as String? ?? '',
      submissionId: json['submissionId'] as String? ?? json['submission_id'] as String? ?? '',
      overallBand: (json['overall_band'] as num?)?.toDouble() ??
          (json['overallBand'] as num?)?.toDouble() ??
          0.0,
      fluencyCoherenceBand: (json['fluency_coherence_band'] as num?)?.toDouble() ??
          (json['fluencyCoherenceBand'] as num?)?.toDouble() ??
          0.0,
      lexicalResourceBand: (json['lexical_resource_band'] as num?)?.toDouble() ??
          (json['lexicalResourceBand'] as num?)?.toDouble() ??
          0.0,
      grammarRangeBand: (json['grammar_range_band'] as num?)?.toDouble() ??
          (json['grammarRangeBand'] as num?)?.toDouble() ??
          0.0,
      pronunciationBand: (json['pronunciation_band'] as num?)?.toDouble() ??
          (json['pronunciationBand'] as num?)?.toDouble() ??
          0.0,
      transcript: json['transcript'] as String? ?? '',
      grammarErrors: (json['grammar_errors'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          (json['grammarErrors'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      vocabularyTips: (json['vocabulary_tips'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          (json['vocabularyTips'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      strengths: (json['strengths'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      areasForImprovement: (json['areas_for_improvement'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          (json['areasForImprovement'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      evaluatedAt: json['evaluated_at'] != null
          ? DateTime.parse(json['evaluated_at'] as String)
          : (json['evaluatedAt'] != null
              ? DateTime.parse(json['evaluatedAt'] as String)
              : DateTime.now()),
    );
  }
}
