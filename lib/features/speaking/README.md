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
  - `datasources/speaking_remote_datasource.dart`: Dio HTTP & audio payload upload client.
  - `dto/speaking_session_dto.dart`: JSON payload model for speaking API responses.
  - `mappers/speaking_session_mapper.dart`: Converts `SpeakingSessionDto` to `SpeakingSessionEntity`.
  - `repositories/speaking_repository_impl.dart`: Implements domain contract using datasource & `AIRepository`.
- `domain/`
  - `entities/speaking_session_entity.dart`: Pure Dart business entity.
  - `repositories/speaking_repository.dart`: Interface contract.
  - `usecases/evaluate_speaking_audio_usecase.dart`: Executes speaking evaluation logic.
- `presentation/`
  - `controllers/speaking_controller.dart`: Riverpod `AsyncNotifier` managing practice state.
  - `effects/speaking_effect.dart`: UI side-effect events (e.g. show completion dialog, trigger haptic feedback).
  - `pages/speaking_practice_page.dart`: Interactive practice screen.
  - `pages/speaking_results_page.dart`: Band score breakdown screen.
  - `state/speaking_state.dart`: Immutable state holding recording status, timer, and score.
  - `widgets/audio_waveform_visualizer.dart`: Extracted waveform widget.
  - `widgets/prompt_card_widget.dart`: Extracted prompt display widget.
- `routes/speaking_routes.dart`: Feature GoRouter routes (`/speaking/practice`, `/speaking/results`).
- `di/speaking_providers.dart`: Riverpod dependency injection definitions.

## Reference Standards for AI Agents
When generating new features (e.g. `listening`, `reading`, `writing`), use `lib/features/speaking/` as the structural template.
