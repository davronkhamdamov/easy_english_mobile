# Speaking Feature (`lib/features/speaking`)

## Purpose
Handles IELTS Speaking practice sessions, real-time voice recording, AI evaluation requests, and scoring breakdown displays.

## Clean Architecture Layers
- `domain/`: Pure Dart models (`SpeakingSessionEntity`), contracts (`SpeakingRepository`), and use cases (`EvaluateSpeakingAudioUseCase`).
- `data/`: Remote datasources, DTOs, mappers, and `SpeakingRepositoryImpl`.
- `presentation/`: Riverpod `SpeakingController`, `SpeakingState`, pages, and extracted UI widgets.
- `routes/`: Feature route definitions for GoRouter.
- `di/`: Riverpod provider declarations for this feature.
