# Exemplar Feature Specification: Speaking (`lib/features/speaking`)

## Overview
The `speaking` feature handles IELTS Speaking test simulation, real-time voice recording, AI evaluation processing, and detailed band score breakdown reports.

## Layer Structure & Data Flow

```
[ SpeakingPracticePage ] ── user taps record ──► [ SpeakingController ]
           ▲                                             │
           │                                      calls EvaluateSpeakingAudioUseCase
   rebuilds on state change                              ▼
           │                                    [ SpeakingRepository ]
           │                                             │
 [ SpeakingState (Band score) ] ◄── maps Entity ── [ SpeakingRepositoryImpl ]
                                                         │
                                                calls RemoteDataSource / AIRepository
```

## Module Directory Map
- `data/`
  - `datasources/speaking_remote_datasource.dart`: Remote HTTP client handling speech evaluation, Whisper audio transcription, and prompt requests.
  - `models/`: JSON DTO models (`speaking_evaluation_model.dart`, `speaking_prompt_model.dart`, `audio_submission_model.dart`).
  - `repositories/speaking_repository_impl.dart`: Repository implementation coordinating datasource and mapping DTOs to entities.
- `domain/`
  - `entities/`: Pure Dart business entities (`speaking_evaluation.dart`, `speaking_prompt.dart`, `audio_submission.dart`).
  - `repositories/speaking_repository.dart`: Pure domain repository interface.
  - `usecases/`: Application operation use cases (`evaluate_speaking.dart`, `transcribe_speaking_audio.dart`, `fetch_speaking_prompts.dart`).
- `presentation/`
  - `providers/speaking_provider.dart`: Presentation state provider coordinating domain use cases.
  - `screens/speaking_screen.dart`: Main IELTS Speaking practice screen.
  - `widgets/`: Extracted presentation widgets (`cue_card_prompt_widget.dart`, `audio_transcript_widget.dart`, `ai_evaluation_widget.dart`).

## Reference Standards for AI Agents
When generating or refactoring features, use `lib/features/speaking/` as the architectural reference template.
