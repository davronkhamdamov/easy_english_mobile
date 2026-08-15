# Diagnostic Placement Test Feature Module (`lib/features/placement_test`)

## Architectural Scope
This feature module implements the Diagnostic Placement Test for `easy_english_mobile`.
It assesses student proficiency across Grammar, Vocabulary, Reading, and Listening.

## Clean Architecture Layers
- `data/`: Remote datasources (`GET /api/v1/placement/questions/`, `POST /api/v1/placement/submit/`), models, repositories. Zero sample data fallbacks.
- `domain/`: Business logic entities (`PlacementQuestion`, `PlacementResult`), repository interfaces, and use cases.
- `presentation/`: UI screens, providers (`PlacementTestProvider`), state (`PlacementTestState`), widgets (stepper, question cards, result breakdown, error UI).
- `routes/`: GoRouter / route helpers.
- `di/`: Dependency injection registrations.
