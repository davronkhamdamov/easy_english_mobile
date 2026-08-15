import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../../../core/network/api_client.dart';
import '../models/speaking_evaluation_model.dart';
import '../models/speaking_prompt_model.dart';

class SpeakingRemoteDatasource {
  final ApiClient _client;

  SpeakingRemoteDatasource({ApiClient? client})
      : _client = client ?? ApiClient();

  /// Fetches IELTS speaking prompts (GET /api/v1/content/speaking-prompts/)
  Future<List<SpeakingPromptModel>> fetchSpeakingPrompts() async {
    final response = await _client.get('/api/v1/content/speaking-prompts/');
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data
          .map((e) => SpeakingPromptModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception(
        'Failed to fetch speaking prompts (${response.statusCode}): ${response.body}',
      );
    }
  }

  /// Transcribes an uploaded audio file using Whisper (POST /api/v1/ai/transcribe-speaking)
  Future<String> transcribeSpeakingAudio(String audioFilePath) async {
    debugPrint('Transcribing audio file via Whisper: $audioFilePath');
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
      throw Exception(
        'Failed to transcribe speaking audio (${response.statusCode}): ${response.body}',
      );
    }
  }

  /// Submits speaking audio / transcript for AI Evaluation (POST /api/v1/ai/evaluate-speaking)
  Future<SpeakingEvaluationModel> evaluateSpeaking({
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
      return SpeakingEvaluationModel.fromJson(json);
    } else {
      throw Exception(
        'Failed to evaluate speaking (${response.statusCode}): ${response.body}',
      );
    }
  }
}
