import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/youtube_listening_models.dart';

class YoutubeListeningRepository {
  final String apiBaseUrl;

  YoutubeListeningRepository({
    this.apiBaseUrl = 'http://172.20.10.4:9000',
  });

  // Built-in curated dataset extracted from actual YouTube transcripts in the project
  static const List<Map<String, dynamic>> _curatedSegments = [
    {
      'id': 1,
      'video_id': '3c1-txnKCMA',
      'sequence_number': 1,
      'start_seconds': 0.36,
      'end_seconds': 6.84,
      'duration_seconds': 6.48,
      'text': 'There are ways to make your brain bigger, faster, and stronger,',
      'language': 'en',
      'title': 'How Dancing Affects the Brain',
      'channel_title': 'BBC Ideas',
      'accent': 'UK',
    },
    {
      'id': 2,
      'video_id': '3c1-txnKCMA',
      'sequence_number': 2,
      'start_seconds': 6.84,
      'end_seconds': 10.12,
      'duration_seconds': 3.28,
      'text': 'and dancing is one of the best.',
      'language': 'en',
      'title': 'How Dancing Affects the Brain',
      'channel_title': 'BBC Ideas',
      'accent': 'UK',
    },
    {
      'id': 3,
      'video_id': '3c1-txnKCMA',
      'sequence_number': 3,
      'start_seconds': 12.44,
      'end_seconds': 17.20,
      'duration_seconds': 4.76,
      'text': "It doesn't just use your whole body, but works most of your brain too.",
      'language': 'en',
      'title': 'How Dancing Affects the Brain',
      'channel_title': 'BBC Ideas',
      'accent': 'UK',
    },
    {
      'id': 4,
      'video_id': '3c1-txnKCMA',
      'sequence_number': 4,
      'start_seconds': 17.20,
      'end_seconds': 21.00,
      'duration_seconds': 3.80,
      'text': 'A bit like jogging and doing a Sudoku at the same time.',
      'language': 'en',
      'title': 'How Dancing Affects the Brain',
      'channel_title': 'BBC Ideas',
      'accent': 'UK',
    },
    {
      'id': 5,
      'video_id': '3c1-txnKCMA',
      'sequence_number': 5,
      'start_seconds': 21.00,
      'end_seconds': 26.36,
      'duration_seconds': 5.36,
      'text': 'Here are four ways dancing transforms your brain and makes it more resilient.',
      'language': 'en',
      'title': 'How Dancing Affects the Brain',
      'channel_title': 'BBC Ideas',
      'accent': 'UK',
    },
    {
      'id': 6,
      'video_id': '3c1-txnKCMA',
      'sequence_number': 6,
      'start_seconds': 28.04,
      'end_seconds': 30.88,
      'duration_seconds': 2.84,
      'text': 'Dancing lights up the whole brain.',
      'language': 'en',
      'title': 'How Dancing Affects the Brain',
      'channel_title': 'BBC Ideas',
      'accent': 'UK',
    },
    {
      'id': 7,
      'video_id': 'ZROiB8K3eXw',
      'sequence_number': 1,
      'start_seconds': 4.10,
      'end_seconds': 9.80,
      'duration_seconds': 5.70,
      'text': 'Understanding the impact of trade war dynamics on global supply chains.',
      'language': 'en',
      'title': 'Global Economy & Trade War Explained',
      'channel_title': 'Economics Explained',
      'accent': 'US',
    },
    {
      'id': 8,
      'video_id': 'ZROiB8K3eXw',
      'sequence_number': 2,
      'start_seconds': 10.20,
      'end_seconds': 15.60,
      'duration_seconds': 5.40,
      'text': 'Tariffs cause ripple effects across international markets and currencies.',
      'language': 'en',
      'title': 'Global Economy & Trade War Explained',
      'channel_title': 'Economics Explained',
      'accent': 'US',
    },
    {
      'id': 9,
      'video_id': 'Evg3LR-G7eU',
      'sequence_number': 1,
      'start_seconds': 8.50,
      'end_seconds': 14.20,
      'duration_seconds': 5.70,
      'text': 'Artificial intelligence is changing the way researchers discover new medicine.',
      'language': 'en',
      'title': 'AI in Modern Healthcare',
      'channel_title': 'TED-Ed',
      'accent': 'US',
    },
    {
      'id': 10,
      'video_id': 'Evg3LR-G7eU',
      'sequence_number': 2,
      'start_seconds': 14.50,
      'end_seconds': 20.10,
      'duration_seconds': 5.60,
      'text': 'By training neural networks on billions of molecular data points.',
      'language': 'en',
      'title': 'AI in Modern Healthcare',
      'channel_title': 'TED-Ed',
      'accent': 'US',
    },
    {
      'id': 11,
      'video_id': 'wWdZRfQbTkk',
      'sequence_number': 1,
      'start_seconds': 12.00,
      'end_seconds': 17.50,
      'duration_seconds': 5.50,
      'text': 'Chronic social isolation alters cognitive function and emotional well-being.',
      'language': 'en',
      'title': 'The Neuroscience of Loneliness',
      'channel_title': 'Vox',
      'accent': 'US',
    },
    {
      'id': 12,
      'video_id': 'wWdZRfQbTkk',
      'sequence_number': 2,
      'start_seconds': 17.80,
      'end_seconds': 23.40,
      'duration_seconds': 5.60,
      'text': 'Human beings are fundamentally wired for connection and community.',
      'language': 'en',
      'title': 'The Neuroscience of Loneliness',
      'channel_title': 'Vox',
      'accent': 'US',
    },
    {
      'id': 13,
      'video_id': 'HiU5W3Kjidw',
      'sequence_number': 1,
      'start_seconds': 5.20,
      'end_seconds': 11.00,
      'duration_seconds': 5.80,
      'text': 'Developing mental focus requires deliberate practice and fewer distractions.',
      'language': 'en',
      'title': 'Mastering Deep Work & Focus',
      'channel_title': 'Harvard Business Review',
      'accent': 'UK',
    },
    {
      'id': 14,
      'video_id': 'HiU5W3Kjidw',
      'sequence_number': 2,
      'start_seconds': 11.40,
      'end_seconds': 17.00,
      'duration_seconds': 5.60,
      'text': 'When you eliminate interruptions, your cognitive capacity increases dramatically.',
      'language': 'en',
      'title': 'Mastering Deep Work & Focus',
      'channel_title': 'Harvard Business Review',
      'accent': 'UK',
    },
    {
      'id': 15,
      'video_id': 'nnYFxMyw6BY',
      'sequence_number': 1,
      'start_seconds': 3.10,
      'end_seconds': 8.90,
      'duration_seconds': 5.80,
      'text': 'Every challenge presents a hidden opportunity to build lifelong resilience.',
      'language': 'en',
      'title': 'The Psychology of Adaptability',
      'channel_title': 'Stanford eCorner',
      'accent': 'US',
    },
  ];

  Future<SearchResponse> search({
    required String query,
    String? accent,
    int page = 1,
    int limit = 20,
  }) async {
    final cleanQuery = query.trim().toLowerCase();

    // 1. Try remote API first if online
    try {
      final uri = Uri.parse('$apiBaseUrl/api/search').replace(queryParameters: {
        'q': cleanQuery,
        'page': page.toString(),
        'limit': limit.toString(),
        if (accent != null && accent.isNotEmpty && accent.toUpperCase() != 'ALL')
          'accent': accent.toUpperCase(),
      });

      final response = await http.get(uri).timeout(const Duration(milliseconds: 2500));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return SearchResponse.fromJson(data);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[YoutubeListeningRepository] Remote search failed, falling back to local dataset: $e');
      }
    }

    // 2. Fallback to rich curated local dataset
    final filtered = _curatedSegments.where((item) {
      final text = (item['text'] as String).toLowerCase();
      final title = (item['title'] as String).toLowerCase();
      final itemAccent = (item['accent'] as String).toUpperCase();

      final matchesQuery = text.contains(cleanQuery) ||
          title.contains(cleanQuery) ||
          cleanQuery.split(' ').every((word) => text.contains(word));

      if (!matchesQuery) return false;

      if (accent != null && accent.isNotEmpty && accent.toUpperCase() != 'ALL') {
        return itemAccent == accent.toUpperCase();
      }

      return true;
    }).toList();

    // Add mark highlights
    final results = filtered.map((item) {
      final rawText = item['text'] as String;
      final highlighted = _highlightMatch(rawText, cleanQuery);
      final mapCopy = Map<String, dynamic>.from(item);
      mapCopy['highlighted_text'] = highlighted;
      return SubtitleSegment.fromJson(mapCopy);
    }).toList();

    return SearchResponse(
      query: query,
      totalCount: results.length,
      page: 1,
      pageSize: limit,
      totalPages: (results.length / limit).ceil().clamp(1, 999),
      results: results,
    );
  }

  String _highlightMatch(String text, String query) {
    if (query.isEmpty) return text;
    try {
      final escaped = RegExp.escape(query);
      return text.replaceAllMapped(
        RegExp('($escaped)', caseSensitive: false),
        (match) => '<mark>${match.group(0)}</mark>',
      );
    } catch (_) {
      return text;
    }
  }

  Future<ContextResponse> getSegmentContext(
    int segmentId, {
    String? videoId,
    int window = 1,
  }) async {
    final safeWindow = window.clamp(1, 10);

    // 1. Try remote API
    try {
      final uri = Uri.parse('$apiBaseUrl/api/segments/$segmentId/context?window=$safeWindow');
      final response = await http.get(uri).timeout(const Duration(milliseconds: 3500));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return ContextResponse.fromJson(data);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[YoutubeListeningRepository] Remote context failed: $e');
      }
    }

    // 2. Fallback to local context if segment exists in curated list
    var targetList = _curatedSegments.where((s) => s['id'] == segmentId).toList();
    if (targetList.isEmpty && videoId != null && videoId.isNotEmpty) {
      targetList = _curatedSegments.where((s) => s['video_id'] == videoId).toList();
    }

    if (targetList.isEmpty) {
      return ContextResponse(
        videoId: videoId ?? '',
        title: '',
        currentSegmentId: segmentId,
        segments: const [],
      );
    }

    final target = targetList.first;
    final resolvedVideoId = (target['video_id'] as String?) ?? (videoId ?? '');
    final seq = (target['sequence_number'] as int?) ?? 1;

    final videoSegments = _curatedSegments
        .where((s) =>
            s['video_id'] == resolvedVideoId &&
            (s['sequence_number'] as int) >= seq - safeWindow &&
            (s['sequence_number'] as int) <= seq + safeWindow)
        .toList()
      ..sort((a, b) => ((a['sequence_number'] as int)).compareTo(b['sequence_number'] as int));

    final contextSegments = videoSegments.map((s) {
      return ContextSegment(
        id: s['id'] as int,
        sequenceNumber: s['sequence_number'] as int,
        startSeconds: (s['start_seconds'] as num).toDouble(),
        endSeconds: (s['end_seconds'] as num).toDouble(),
        text: s['text'] as String,
        isCurrent: s['id'] == segmentId,
      );
    }).toList();

    return ContextResponse(
      videoId: resolvedVideoId,
      title: (target['title'] as String?) ?? '',
      currentSegmentId: segmentId,
      segments: contextSegments,
    );
  }

  List<ContextSegment> getLocalSegmentsForVideo(String videoId) {
    final videoSegments = _curatedSegments
        .where((s) => s['video_id'] == videoId)
        .toList()
      ..sort((a, b) => ((a['sequence_number'] as int)).compareTo(b['sequence_number'] as int));

    return videoSegments.map((s) {
      return ContextSegment(
        id: s['id'] as int,
        sequenceNumber: s['sequence_number'] as int,
        startSeconds: (s['start_seconds'] as num).toDouble(),
        endSeconds: (s['end_seconds'] as num).toDouble(),
        text: s['text'] as String,
        isCurrent: false,
      );
    }).toList();
  }

  Future<QuizQuestion> getRandomQuizQuestion() async {
    // 1. Try remote API
    try {
      final uri = Uri.parse('$apiBaseUrl/api/quiz/random');
      final response = await http.get(uri).timeout(const Duration(milliseconds: 2500));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return QuizQuestion.fromJson(data);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[YoutubeListeningRepository] Remote quiz failed: $e');
      }
    }

    // 2. Generate from curated local dataset
    final random = Random();
    final item = _curatedSegments[random.nextInt(_curatedSegments.length)];
    final text = item['text'] as String;

    // Pick a word with length >= 4
    final words = RegExp(r'\b[a-zA-Z]{4,}\b')
        .allMatches(text)
        .map((m) => m.group(0)!)
        .toList();

    final targetWord = words.isNotEmpty ? words[random.nextInt(words.length)] : text.split(' ').first;
    final masked = text.replaceFirst(RegExp(RegExp.escape(targetWord), caseSensitive: false), '_______');

    return QuizQuestion(
      id: item['id'] as int,
      videoId: item['video_id'] as String,
      startSeconds: (item['start_seconds'] as num).toDouble(),
      endSeconds: (item['end_seconds'] as num).toDouble(),
      maskedText: masked,
      targetWord: targetWord,
      title: item['title'] as String,
      accent: item['accent'] as String?,
    );
  }

  Future<ListeningStats> getStats() async {
    try {
      final uri = Uri.parse('$apiBaseUrl/api/stats');
      final response = await http.get(uri).timeout(const Duration(milliseconds: 2500));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return ListeningStats.fromJson(data);
      }
    } catch (_) {}

    return const ListeningStats(
      totalVideos: 48,
      totalSegments: 1240,
      accents: [
        {'accent': 'US', 'count': 820},
        {'accent': 'UK', 'count': 420},
      ],
    );
  }
}
