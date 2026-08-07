import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../../core/auth/api_client.dart';

class SpeakingEvaluationResult {
  final String transcription;
  final double overallBandScore;
  final double fluencyScore;
  final double pronunciationScore;
  final double lexicalResourceScore;
  final double grammarScore;
  final List<String> grammarErrors;
  final List<String> vocabularyTips;
  final List<String> strengths;
  final List<String> areasForImprovement;

  SpeakingEvaluationResult({
    required this.transcription,
    required this.overallBandScore,
    required this.fluencyScore,
    required this.pronunciationScore,
    required this.lexicalResourceScore,
    required this.grammarScore,
    required this.grammarErrors,
    required this.vocabularyTips,
    required this.strengths,
    required this.areasForImprovement,
  });

  static List<String> _parseStringList(dynamic raw) {
    if (raw is List) {
      return raw.map((e) => e.toString()).toList();
    }
    return <String>[];
  }

  factory SpeakingEvaluationResult.fromJson(Map<String, dynamic> json) {
    return SpeakingEvaluationResult(
      transcription: (json['transcript'] ?? json['transcription'] ?? '').toString(),
      overallBandScore: (json['overall_band'] ?? json['overall_band_score'] as num?)?.toDouble() ?? 7.0,
      fluencyScore: (json['fluency_coherence_band'] ?? json['fluency_score'] as num?)?.toDouble() ?? 7.0,
      pronunciationScore: (json['pronunciation_band'] ?? json['pronunciation_score'] as num?)?.toDouble() ?? 7.5,
      lexicalResourceScore: (json['lexical_resource_band'] ?? json['lexical_resource_score'] as num?)?.toDouble() ?? 7.0,
      grammarScore: (json['grammar_range_band'] ?? json['grammar_score'] as num?)?.toDouble() ?? 7.0,
      grammarErrors: _parseStringList(json['grammar_errors'] ?? json['grammar_corrections']),
      vocabularyTips: _parseStringList(json['vocabulary_tips']),
      strengths: _parseStringList(json['strengths']),
      areasForImprovement: _parseStringList(json['areas_for_improvement'] ?? json['weaknesses']),
    );
  }
}

class SpeakingEvaluationService {
  final ApiClient _client = ApiClient();

  /// Submits speaking audio / transcript for AI Evaluation via multipart (POST /api/v1/ai/evaluate-speaking)
  Future<SpeakingEvaluationResult> evaluateSpeaking({
    String? audioFilePath,
    String? transcript,
    int part = 1,
    String? prompt,
  }) async {
    final fields = <String, String>{
      'part': part.toString(),
      if (prompt != null && prompt.isNotEmpty) 'prompt': prompt,
      if (transcript != null && transcript.isNotEmpty) 'transcript': transcript,
    };

    final response = await _client.postMultipart(
      '/api/v1/ai/evaluate-speaking',
      fields: fields,
      filePath: audioFilePath,
      fileField: 'file',
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return SpeakingEvaluationResult.fromJson(json);
    } else {
      throw Exception('Failed to evaluate speaking (${response.statusCode}): ${response.body}');
    }
  }

  /// Transcribes an uploaded audio file using OpenAI Whisper (POST /api/v1/ai/transcribe-speaking)
  Future<String> transcribeSpeakingAudio(String audioFilePath) async {
    debugPrint('Sending audio file to Whisper API (https://easy-english.uz/api/v1/ai/transcribe-speaking)...');
    final response = await _client.postMultipart(
      '/api/v1/ai/transcribe-speaking',
      filePath: audioFilePath,
      fileField: 'file',
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final text = (json['transcript'] ?? json['transcription'] ?? '').toString();
      debugPrint('Whisper transcription success: $text');
      return text;
    } else {
      debugPrint('Whisper error response: HTTP ${response.statusCode} - ${response.body}');
      throw Exception('Failed to transcribe speaking audio (${response.statusCode}): ${response.body}');
    }
  }

  /// Fetches IELTS speaking prompts (GET /api/v1/content/speaking-prompts/)
  Future<List<Map<String, dynamic>>> fetchSpeakingPrompts() async {
    try {
      final response = await _client.get('/api/v1/content/speaking-prompts/');
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
    } catch (_) {}
    return [];
  }
}
