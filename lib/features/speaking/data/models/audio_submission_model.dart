import '../../domain/entities/audio_submission.dart';

class AudioSubmissionModel {
  final String id;
  final String promptId;
  final String? audioPath;
  final int durationSeconds;
  final DateTime recordedAt;

  const AudioSubmissionModel({
    required this.id,
    required this.promptId,
    this.audioPath,
    required this.durationSeconds,
    required this.recordedAt,
  });

  factory AudioSubmissionModel.fromJson(Map<String, dynamic> json) {
    return AudioSubmissionModel(
      id: json['id'] as String? ?? '',
      promptId:
          json['promptId'] as String? ?? json['prompt_id'] as String? ?? '',
      audioPath: json['audioPath'] as String? ?? json['audio_path'] as String?,
      durationSeconds:
          (json['durationSeconds'] as num?)?.toInt() ??
          (json['duration_seconds'] as num?)?.toInt() ??
          0,
      recordedAt: json['recordedAt'] != null
          ? DateTime.parse(json['recordedAt'] as String)
          : (json['recorded_at'] != null
                ? DateTime.parse(json['recorded_at'] as String)
                : DateTime.now()),
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

  AudioSubmission toEntity() {
    return AudioSubmission(
      id: id,
      promptId: promptId,
      audioPath: audioPath,
      durationSeconds: durationSeconds,
      recordedAt: recordedAt,
    );
  }

  factory AudioSubmissionModel.fromEntity(AudioSubmission entity) {
    return AudioSubmissionModel(
      id: entity.id,
      promptId: entity.promptId,
      audioPath: entity.audioPath,
      durationSeconds: entity.durationSeconds,
      recordedAt: entity.recordedAt,
    );
  }
}
