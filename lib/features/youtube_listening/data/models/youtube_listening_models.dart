class SubtitleSegment {
  final int id;
  final String videoId;
  final int sequenceNumber;
  final double startSeconds;
  final double endSeconds;
  final double durationSeconds;
  final String text;
  final String? highlightedText;
  final String language;
  final String title;
  final String? channelTitle;
  final String? accent;

  const SubtitleSegment({
    required this.id,
    required this.videoId,
    required this.sequenceNumber,
    required this.startSeconds,
    required this.endSeconds,
    required this.durationSeconds,
    required this.text,
    this.highlightedText,
    required this.language,
    required this.title,
    this.channelTitle,
    this.accent,
  });

  factory SubtitleSegment.fromJson(Map<String, dynamic> json) {
    return SubtitleSegment(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      videoId: json['video_id']?.toString() ?? '',
      sequenceNumber: json['sequence_number'] is int
          ? json['sequence_number']
          : int.tryParse(json['sequence_number'].toString()) ?? 0,
      startSeconds: (json['start_seconds'] is num)
          ? (json['start_seconds'] as num).toDouble()
          : double.tryParse(json['start_seconds'].toString()) ?? 0.0,
      endSeconds: (json['end_seconds'] is num)
          ? (json['end_seconds'] as num).toDouble()
          : double.tryParse(json['end_seconds'].toString()) ?? 0.0,
      durationSeconds: (json['duration_seconds'] is num)
          ? (json['duration_seconds'] as num).toDouble()
          : double.tryParse(json['duration_seconds']?.toString() ?? '0') ?? 0.0,
      text: json['text']?.toString() ?? '',
      highlightedText: json['highlighted_text']?.toString(),
      language: json['language']?.toString() ?? 'en',
      title: json['title']?.toString() ?? 'YouTube Clip',
      channelTitle: json['channel_title']?.toString() ?? 'English Audio',
      accent: json['accent']?.toString() ?? 'US',
    );
  }
}

class SearchResponse {
  final String query;
  final int totalCount;
  final int page;
  final int pageSize;
  final int totalPages;
  final List<SubtitleSegment> results;

  const SearchResponse({
    required this.query,
    required this.totalCount,
    required this.page,
    required this.pageSize,
    required this.totalPages,
    required this.results,
  });

  factory SearchResponse.fromJson(Map<String, dynamic> json) {
    final rawResults = json['results'] as List? ?? [];
    return SearchResponse(
      query: json['query']?.toString() ?? '',
      totalCount: json['total_count'] is int
          ? json['total_count']
          : int.tryParse(json['total_count'].toString()) ?? 0,
      page: json['page'] is int ? json['page'] : 1,
      pageSize: json['page_size'] is int ? json['page_size'] : 20,
      totalPages: json['total_pages'] is int ? json['total_pages'] : 1,
      results: rawResults
          .map((item) => SubtitleSegment.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ContextSegment {
  final int id;
  final int sequenceNumber;
  final double startSeconds;
  final double endSeconds;
  final String text;
  final bool isCurrent;

  const ContextSegment({
    required this.id,
    required this.sequenceNumber,
    required this.startSeconds,
    required this.endSeconds,
    required this.text,
    required this.isCurrent,
  });

  factory ContextSegment.fromJson(Map<String, dynamic> json) {
    final startRaw = json['start_seconds'] ?? json['startSeconds'] ?? json['start_time'] ?? json['startTime'] ?? json['start'] ?? 0.0;
    final endRaw = json['end_seconds'] ?? json['endSeconds'] ?? json['end_time'] ?? json['endTime'] ?? json['end'] ?? 0.0;

    return ContextSegment(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      sequenceNumber: json['sequence_number'] is int
          ? json['sequence_number']
          : int.tryParse(json['sequence_number']?.toString() ?? json['sequenceNumber']?.toString() ?? '0') ?? 0,
      startSeconds: (startRaw is num)
          ? startRaw.toDouble()
          : double.tryParse(startRaw.toString()) ?? 0.0,
      endSeconds: (endRaw is num)
          ? endRaw.toDouble()
          : double.tryParse(endRaw.toString()) ?? 0.0,
      text: (json['text'] ?? json['subtitle'] ?? json['content'] ?? json['lyrics'] ?? '')?.toString() ?? '',
      isCurrent: json['is_current'] == true || json['isCurrent'] == true,
    );
  }
}

class ContextResponse {
  final String videoId;
  final String title;
  final int currentSegmentId;
  final List<ContextSegment> segments;

  const ContextResponse({
    required this.videoId,
    required this.title,
    required this.currentSegmentId,
    required this.segments,
  });

  factory ContextResponse.fromJson(Map<String, dynamic> json) {
    final dataMap = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;
    final rawSegments = (dataMap['segments'] ??
            dataMap['subtitles'] ??
            dataMap['context'] ??
            dataMap['transcript'] ??
            json['segments'] ??
            json['subtitles'] ??
            json['data'] ??
            []) as List? ??
        [];

    return ContextResponse(
      videoId: (dataMap['video_id'] ?? dataMap['videoId'] ?? json['video_id'] ?? json['videoId'] ?? '')?.toString() ?? '',
      title: (dataMap['title'] ?? json['title'] ?? '')?.toString() ?? '',
      currentSegmentId: dataMap['current_segment_id'] is int
          ? dataMap['current_segment_id']
          : int.tryParse(dataMap['current_segment_id']?.toString() ?? json['current_segment_id']?.toString() ?? '0') ?? 0,
      segments: rawSegments
          .whereType<Map>()
          .map((item) => ContextSegment.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
    );
  }
}

class QuizQuestion {
  final int id;
  final String videoId;
  final double startSeconds;
  final double endSeconds;
  final String maskedText;
  final String targetWord;
  final String title;
  final String? accent;

  const QuizQuestion({
    required this.id,
    required this.videoId,
    required this.startSeconds,
    required this.endSeconds,
    required this.maskedText,
    required this.targetWord,
    required this.title,
    this.accent,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      videoId: json['video_id']?.toString() ?? '',
      startSeconds: (json['start_seconds'] is num)
          ? (json['start_seconds'] as num).toDouble()
          : double.tryParse(json['start_seconds'].toString()) ?? 0.0,
      endSeconds: (json['end_seconds'] is num)
          ? (json['end_seconds'] as num).toDouble()
          : double.tryParse(json['end_seconds'].toString()) ?? 0.0,
      maskedText: json['masked_text']?.toString() ?? '',
      targetWord: json['target_word']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Listening Comprehension',
      accent: json['accent']?.toString() ?? 'US',
    );
  }
}

class ListeningStats {
  final int totalVideos;
  final int totalSegments;
  final List<Map<String, dynamic>> accents;

  const ListeningStats({
    required this.totalVideos,
    required this.totalSegments,
    required this.accents,
  });

  factory ListeningStats.fromJson(Map<String, dynamic> json) {
    return ListeningStats(
      totalVideos: json['total_videos'] is int
          ? json['total_videos']
          : int.tryParse(json['total_videos']?.toString() ?? '0') ?? 120,
      totalSegments: json['total_segments'] is int
          ? json['total_segments']
          : int.tryParse(json['total_segments']?.toString() ?? '0') ?? 4850,
      accents: (json['accents'] as List?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [],
    );
  }
}
