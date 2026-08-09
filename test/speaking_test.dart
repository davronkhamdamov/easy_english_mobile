import 'package:easy_english/features/speaking/data/models/audio_submission_model.dart';
import 'package:easy_english/features/speaking/data/models/speaking_evaluation_model.dart';
import 'package:easy_english/features/speaking/data/models/speaking_prompt_model.dart';
import 'package:easy_english/features/speaking/domain/entities/speaking_prompt.dart';
import 'package:easy_english/features/speaking/domain/usecases/evaluate_speaking.dart';
import 'package:easy_english/features/speaking/domain/usecases/fetch_speaking_prompts.dart';
import 'package:easy_english/features/speaking/domain/usecases/transcribe_speaking_audio.dart';
import 'package:easy_english/features/speaking/presentation/screens/speaking_screen.dart';
import 'package:easy_english/features/speaking/presentation/widgets/ai_evaluation_widget.dart';
import 'package:easy_english/features/speaking/presentation/widgets/cue_card_prompt_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Speaking Feature Domain & Data Unit Tests', () {
    test('SpeakingPrompt entity samplePrompts and copyWith', () {
      final prompts = SpeakingPrompt.samplePrompts;
      expect(prompts.length, equals(3));
      expect(prompts[0].part, equals(1));
      expect(prompts[1].part, equals(2));
      expect(prompts[2].part, equals(3));

      final p = prompts[0];
      final copy = p.copyWith(topic: 'Updated Topic');
      expect(copy.topic, equals('Updated Topic'));
      expect(copy.id, equals(p.id));
    });

    test('SpeakingPromptModel JSON roundtrip and toEntity', () {
      final json = {
        'id': 'sp_test_1',
        'part': 2,
        'topic': 'Test Cue Card',
        'prompt_text': 'Describe a book you read.',
        'bullet_points': ['What book it was', 'Who wrote it'],
        'prep_time_seconds': 60,
        'speaking_time_seconds': 120,
      };

      final model = SpeakingPromptModel.fromJson(json);
      expect(model.id, equals('sp_test_1'));
      expect(model.part, equals(2));
      expect(model.topic, equals('Test Cue Card'));

      final entity = model.toEntity();
      expect(entity.id, equals('sp_test_1'));
      expect(entity.part, equals(2));
      expect(entity.bulletPoints.length, equals(2));
    });

    test('SpeakingEvaluationModel JSON deserialization and toEntity', () {
      final json = {
        'transcript': 'I live in a beautiful city.',
        'overall_band': 7.5,
        'fluency_coherence_band': 7.5,
        'pronunciation_band': 8.0,
        'lexical_resource_band': 7.0,
        'grammar_range_band': 7.5,
        'grammar_errors': ['Missing article'],
        'vocabulary_tips': ['Use more cohesive devices'],
        'strengths': ['Clear pronunciation'],
        'areas_for_improvement': ['Expand complex sentences'],
      };

      final model = SpeakingEvaluationModel.fromJson(json);
      expect(model.overallBandScore, equals(7.5));
      expect(model.pronunciationScore, equals(8.0));

      final entity = model.toEntity();
      expect(entity.overallBand, equals(7.5));
      expect(entity.pronunciationBand, equals(8.0));
      expect(entity.transcript, equals('I live in a beautiful city.'));
      expect(entity.strengths.first, equals('Clear pronunciation'));
    });

    test('AudioSubmissionModel JSON roundtrip and toEntity', () {
      final json = {
        'id': 'sub_001',
        'promptId': 'sp_p1_01',
        'audioPath': '/tmp/test.m4a',
        'durationSeconds': 45,
        'recordedAt': '2026-08-09T12:00:00.000Z',
      };

      final model = AudioSubmissionModel.fromJson(json);
      expect(model.id, equals('sub_001'));
      expect(model.durationSeconds, equals(45));

      final entity = model.toEntity();
      expect(entity.id, equals('sub_001'));
      expect(entity.audioPath, equals('/tmp/test.m4a'));
    });
  });

  group('Speaking Feature Use Cases Unit Tests', () {
    test(
      'EvaluateSpeaking, TranscribeSpeakingAudio, and FetchSpeakingPrompts instantiate cleanly',
      () async {
        final evalUseCase = EvaluateSpeaking();
        final transcribeUseCase = TranscribeSpeakingAudio();
        final fetchPromptsUseCase = FetchSpeakingPrompts();

        expect(evalUseCase, isNotNull);
        expect(transcribeUseCase, isNotNull);
        expect(fetchPromptsUseCase, isNotNull);
      },
    );
  });

  group('Speaking Feature UI Presentation Widget Tests', () {
    testWidgets(
      'SpeakingScreen renders header, part switcher, cue card prompt, and record button',
      (WidgetTester tester) async {
        await tester.pumpWidget(const MaterialApp(home: SpeakingScreen()));
        await tester.pump();

        expect(find.text('IELTS Speaking Practice'), findsOneWidget);
        expect(find.text('Part 1'), findsOneWidget);
        expect(find.text('Part 2 (Cue Card)'), findsOneWidget);
        expect(find.text('Part 3'), findsOneWidget);
        expect(find.byType(CueCardPromptWidget), findsOneWidget);
        expect(find.byIcon(Icons.mic_rounded), findsOneWidget);
      },
    );

    testWidgets('AIEvaluationWidget renders band score evaluation breakdown', (
      WidgetTester tester,
    ) async {
      final sampleEval = SpeakingEvaluationModel.fromJson({
        'transcript': 'My hometown is famous for ancient architecture.',
        'overall_band': 8.0,
        'fluency_coherence_band': 8.0,
        'pronunciation_band': 8.0,
        'lexical_resource_band': 8.0,
        'grammar_range_band': 8.0,
        'strengths': ['Excellent vocabulary range'],
        'grammar_errors': [],
        'vocabulary_tips': ['Use advanced idioms'],
      }).toEntity();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: AIEvaluationWidget(evaluation: sampleEval)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('AI Band Score Evaluation'), findsOneWidget);
      expect(find.text('Key Strengths'), findsOneWidget);
      expect(find.text('Lexical & Vocabulary Tips'), findsOneWidget);
      expect(find.text('Excellent vocabulary range'), findsOneWidget);
    });
  });
}
