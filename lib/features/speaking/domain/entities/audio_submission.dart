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
}
