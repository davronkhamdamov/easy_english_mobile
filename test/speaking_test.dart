import 'package:easy_english/features/speaking/data/models/speaking_evaluation_model.dart';
import 'package:easy_english/features/speaking/data/models/speaking_prompt_model.dart';
import 'package:easy_english/features/speaking/domain/entities/speaking_evaluation.dart';
import 'package:easy_english/features/speaking/domain/entities/speaking_prompt.dart';
import 'package:easy_english/features/speaking/domain/repositories/speaking_repository.dart';
import 'package:easy_english/features/speaking/domain/usecases/evaluate_speaking.dart';
import 'package:easy_english/features/speaking/domain/usecases/fetch_speaking_prompts.dart';
import 'package:easy_english/features/speaking/domain/usecases/transcribe_speaking_audio.dart';
import 'package:easy_english/features/speaking/presentation/providers/speaking_provider.dart';
import 'package:easy_english/features/speaking/presentation/screens/speaking_screen.dart';
import 'package:easy_english/features/speaking/presentation/widgets/ai_evaluation_card.dart';
import 'package:easy_english/features/speaking/presentation/widgets/speaking_error_widget.dart';
import 'package:easy_english/features/speaking/presentation/widgets/speaking_prompt_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:record/record.dart';

class FakeAudioRecorder extends AudioRecorder {
  @override
  Future<bool> hasPermission({bool request = true}) async => true;
  @override
  Future<void> start(RecordConfig config, {required String path}) async {}
  @override
  Future<String?> stop() async => '/tmp/test.m4a';
  @override
  Future<bool> isRecording() async => false;
  @override
  Future<void> dispose() async {}
}

class FakeSpeakingRepository implements SpeakingRepository {
  final bool shouldFail;
  FakeSpeakingRepository({this.shouldFail = false});

  @override
  Future<List<SpeakingPrompt>> fetchSpeakingPrompts({int? part}) async {
    if (shouldFail) {
      throw Exception('Server unreachable (500)');
    }
    final prompts = [
      const SpeakingPrompt(
        id: 'speak_prompt_201',
        part: 2,
        topic: 'Hometown',
        title: 'Describe a place you love visiting',
        cueCardPoints: [
          'Where this place is located',
          'How often you visit it',
        ],
        prepTimeSeconds: 60,
        speakTimeSeconds: 120,
      ),
      const SpeakingPrompt(
        id: 'speak_prompt_101',
        part: 1,
        topic: 'Daily Routine',
        title: 'Tell me about your morning routine.',
        prepTimeSeconds: 0,
        speakTimeSeconds: 60,
      ),
    ];
    if (part != null) {
      return prompts.where((p) => p.part == part).toList();
    }
    return prompts;
  }

  @override
  Future<String> transcribeSpeakingAudio(String audioFilePath) async {
    return 'I would like to talk about a small park near my house...';
  }

  @override
  Future<SpeakingAIEvaluation> evaluateSpeaking({
    String? audioFilePath,
    String? transcript,
    int part = 1,
    String? prompt,
  }) async {
    return SpeakingEvaluationModel.fromJson({
      'id': 'speak_eval_991',
      'overall_band_score': 7.0,
      'criteria': {
        'fluency_coherence': {'score': 7.5, 'feedback': 'Speaks smoothly'},
        'pronunciation': {'score': 6.5, 'feedback': 'Clear pronunciation'},
        'lexical_resource': {'score': 7.0, 'feedback': 'Good range'},
        'grammatical_range': {'score': 7.0, 'feedback': 'Mixed structures'},
      },
      'transcription': transcript ?? 'Sample answer',
      'pronunciation_tips': [
        {
          'word': 'frequently',
          'phonetic': '/ˈfriː.kwənt.li/',
          'tip': 'Emphasize first syllable',
        }
      ],
      'fluency_pauses_count': 3,
      'band_9_sample_answer': 'One of my absolute favorite retreats...',
    }).toEntity();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('com.llfbandit.record/messages'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'create' || methodCall.method == 'dispose') {
          return null;
        }
        if (methodCall.method == 'hasPermission') {
          return true;
        }
        return null;
      },
    );
  });

  group('Speaking Feature Model JSON Contract Tests', () {
    test('SpeakingPromptModel parses backend endpoint schema', () {
      final json = {
        'id': 'speak_prompt_201',
        'part': 2,
        'topic': 'Hometown',
        'title': 'Describe a place you love visiting',
        'cue_card_points': [
          'Where this place is located',
          'How often you visit it',
          'What you do when you are there',
          'And explain why you love visiting this place',
        ],
        'prep_time_seconds': 60,
        'speak_time_seconds': 120,
      };

      final model = SpeakingPromptModel.fromJson(json);
      expect(model.id, equals('speak_prompt_201'));
      expect(model.part, equals(2));
      expect(model.topic, equals('Hometown'));
      expect(model.title, equals('Describe a place you love visiting'));
      expect(model.cueCardPoints.length, equals(4));

      final entity = model.toEntity();
      expect(entity.title, equals('Describe a place you love visiting'));
      expect(entity.cueCardPoints.first, equals('Where this place is located'));
      expect(entity.speakTimeSeconds, equals(120));
    });

    test('SpeakingEvaluationModel parses AI evaluation endpoint schema', () {
      final json = {
        'id': 'speak_eval_991',
        'overall_band_score': 7.0,
        'criteria': {
          'fluency_coherence': {
            'score': 7.5,
            'feedback': 'Speaks at length without effort.',
          },
          'pronunciation': {
            'score': 6.5,
            'feedback': 'Generally clear pronunciation.',
          },
          'lexical_resource': {
            'score': 7.0,
            'feedback': 'Flexible vocabulary.',
          },
          'grammatical_range': {
            'score': 7.0,
            'feedback': 'Mix of simple & complex sentences.',
          },
        },
        'transcription': 'I would like to talk about...',
        'pronunciation_tips': [
          {
            'word': 'frequently',
            'phonetic': '/ˈfriː.kwənt.li/',
            'tip': 'Emphasize the first syllable',
          }
        ],
        'fluency_pauses_count': 3,
        'band_9_sample_answer': 'One of my absolute favorite retreats...',
      };

      final model = SpeakingEvaluationModel.fromJson(json);
      expect(model.overallScore, equals(7.0));
      expect(model.fluencyScore, equals(7.5));
      expect(model.pronunciationScore, equals(6.5));

      final entity = model.toEntity();
      expect(entity.overallScore, equals(7.0));
      expect(entity.pronunciationTips.length, equals(1));
      expect(entity.pronunciationTips.first.word, equals('frequently'));
      expect(entity.pauseCount, equals(3));
      expect(entity.sampleAnswer, contains('absolute favorite retreats'));
    });
  });

  group('Speaking Provider & State Unit Tests', () {
    test('Provider loads prompts and handles part switching', () async {
      final repo = FakeSpeakingRepository();
      final provider = SpeakingProvider(
        fetchSpeakingPrompts: FetchSpeakingPrompts(repo),
        transcribeSpeakingAudio: TranscribeSpeakingAudio(repo),
        evaluateSpeaking: EvaluateSpeaking(repo),
        audioRecorder: FakeAudioRecorder(),
      );

      await provider.loadPrompts();
      expect(provider.prompts.isNotEmpty, isTrue);

      await provider.switchPart(2);
      expect(provider.state.selectedPart, equals(2));
      expect(provider.state.currentPrompt?.topic, equals('Hometown'));
    });

    test('Provider sets error state on network failure with zero mock fallback', () async {
      final repo = FakeSpeakingRepository(shouldFail: true);
      final provider = SpeakingProvider(
        fetchSpeakingPrompts: FetchSpeakingPrompts(repo),
        transcribeSpeakingAudio: TranscribeSpeakingAudio(repo),
        evaluateSpeaking: EvaluateSpeaking(repo),
        audioRecorder: FakeAudioRecorder(),
      );

      await provider.loadPrompts();
      expect(provider.prompts.isEmpty, isTrue);
      expect(provider.errorMessage, contains('Server unreachable'));
    });
  });

  group('Speaking UI Presentation Widget Tests', () {
    testWidgets('SpeakingScreen renders header, prompt card, and controls', (
      WidgetTester tester,
    ) async {
      final repo = FakeSpeakingRepository();
      final provider = SpeakingProvider(
        fetchSpeakingPrompts: FetchSpeakingPrompts(repo),
        transcribeSpeakingAudio: TranscribeSpeakingAudio(repo),
        evaluateSpeaking: EvaluateSpeaking(repo),
        audioRecorder: FakeAudioRecorder(),
      );

      await tester.pumpWidget(
        MaterialApp(home: SpeakingScreen(provider: provider)),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('IELTS Speaking Practice'), findsOneWidget);
      expect(find.text('Part 1'), findsOneWidget);
      expect(find.text('Part 2 (Cue Card)'), findsOneWidget);
      expect(find.text('Part 3'), findsOneWidget);
      expect(find.byType(SpeakingPromptCard), findsOneWidget);
    });

    testWidgets('SpeakingScreen renders error widget on API error', (
      WidgetTester tester,
    ) async {
      final repo = FakeSpeakingRepository(shouldFail: true);
      final provider = SpeakingProvider(
        fetchSpeakingPrompts: FetchSpeakingPrompts(repo),
        transcribeSpeakingAudio: TranscribeSpeakingAudio(repo),
        evaluateSpeaking: EvaluateSpeaking(repo),
        audioRecorder: FakeAudioRecorder(),
      );

      await tester.pumpWidget(
        MaterialApp(home: SpeakingScreen(provider: provider)),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(SpeakingErrorWidget), findsOneWidget);
      expect(find.text('Retry Request'), findsOneWidget);
    });

    testWidgets('AIEvaluationCard renders criteria progress and accordions', (
      WidgetTester tester,
    ) async {
      final repo = FakeSpeakingRepository();
      final eval = await repo.evaluateSpeaking(transcript: 'Test speech');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AIEvaluationCard(evaluation: eval),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('AI Band Score Evaluation'), findsOneWidget);
      expect(find.text('Band 7.0'), findsWidgets);
      expect(find.text('Fluency & Coherence'), findsOneWidget);
      expect(find.text('Pronunciation Tips (1)'), findsOneWidget);
      expect(find.text('Pause Count Analysis (3 pauses detected)'), findsOneWidget);
      expect(find.text('Band 9 Model Answer'), findsOneWidget);
    });
  });
}
