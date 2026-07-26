# Enterprise Flutter Architecture Blueprint
**Project:** easy_ielts (Android & iOS Enterprise App)  
**Target Scale:** 500+ Screens | 10,000+ Dart Files | Millions of Users | AI-First Maintenance  

---

## 1. Complete Directory Tree

```
lib/
├── main.dart
├── app/
│   ├── app.dart
│   ├── app_bootstrapper.dart
│   ├── app_environment.dart
│   ├── app_observer.dart
│   └── README.md
├── core/
│   ├── README.md
│   ├── ai/
│   │   ├── README.md
│   │   ├── models/
│   │   │   ├── ai_prompt_request.dart
│   │   │   ├── ai_completion_response.dart
│   │   │   └── ai_stream_chunk.dart
│   │   ├── parsers/
│   │   │   └── ai_json_parser.dart
│   │   ├── prompts/
│   │   │   └── prompt_template_engine.dart
│   │   ├── providers/
│   │   │   ├── claude/
│   │   │   │   └── claude_ai_provider.dart
│   │   │   ├── gemini/
│   │   │   │   └── gemini_ai_provider.dart
│   │   │   ├── ollama/
│   │   │   │   └── ollama_ai_provider.dart
│   │   │   └── openai/
│   │   │       └── openai_provider.dart
│   │   ├── repository/
│   │   │   ├── ai_repository.dart
│   │   │   └── ai_repository_impl.dart
│   │   ├── services/
│   │   │   └── ai_token_counter_service.dart
│   │   └── streaming/
│   │       └── ai_stream_handler.dart
│   ├── analytics/
│   ├── api/
│   ├── cache/
│   ├── config/
│   ├── constants/
│   ├── database/
│   ├── errors/
│   │   ├── failure.dart
│   │   └── result.dart
│   ├── extensions/
│   ├── localization/
│   ├── logging/
│   ├── navigation/
│   ├── network/
│   ├── notifications/
│   ├── permissions/
│   ├── security/
│   ├── services/
│   ├── storage/
│   └── theme/
├── design_system/
│   ├── README.md
│   ├── animations/
│   ├── appbars/
│   ├── avatars/
│   ├── badges/
│   ├── bottom_sheets/
│   ├── buttons/
│   ├── cards/
│   ├── chips/
│   ├── dialogs/
│   ├── empty_states/
│   ├── error_states/
│   ├── forms/
│   ├── icons/
│   ├── inputs/
│   ├── loading/
│   ├── modals/
│   ├── progress/
│   ├── snackbars/
│   ├── spacing/
│   └── typography/
├── shared/
│   ├── README.md
│   ├── auth/
│   ├── common_models/
│   ├── shared_providers/
│   ├── shared_repositories/
│   ├── shared_services/
│   ├── shared_widgets/
│   ├── user/
│   └── validators/
└── features/
    ├── README.md
    ├── ai_chat/
    ├── ai_feedback/
    ├── analytics/
    ├── auth/
    ├── home/
    ├── leaderboard/
    ├── listening/
    ├── notifications/
    ├── payments/
    ├── profile/
    ├── reading/
    ├── settings/
    ├── speaking/
    │   ├── README.md
    │   ├── data/
    │   │   ├── datasources/
    │   │   ├── dto/
    │   │   ├── mappers/
    │   │   ├── models/
    │   │   └── repositories/
    │   ├── di/
    │   │   └── speaking_providers.dart
    │   ├── domain/
    │   │   ├── entities/
    │   │   ├── repositories/
    │   │   └── usecases/
    │   ├── presentation/
    │   │   ├── controllers/
    │   │   ├── effects/
    │   │   ├── pages/
    │   │   ├── providers/
    │   │   ├── state/
    │   │   └── widgets/
    │   └── routes/
    │       └── speaking_routes.dart
    ├── subscription/
    ├── vocabulary/
    └── writing/
```

---

## 2. Folder Purpose & Responsibilities

| Folder | Purpose & Responsibility |
| :--- | :--- |
| **`lib/app/`** | Root application initialization, entry bindings, app-level observers, environment loading, and top-level MaterialApp / ProviderScope configuration. |
| **`lib/core/`** | Pure infrastructural primitives (Networking, AI Engine, Storage, Database, Logging, Security, Navigation, Localization, Theme). Never imports `features/` or `shared/`. |
| **`lib/core/ai/`** | Centralized multi-provider AI abstraction engine (OpenAI, Gemini, Claude, Ollama) handling streaming, prompt templating, token counting, and JSON parsing. |
| **`lib/design_system/`** | Atomic design UI components (Buttons, Inputs, Cards, Dialogs, Typography, Spacing, Animations). Contains NO business logic or API calls. |
| **`lib/shared/`** | Cross-feature domain entities and services (User entity, Session state, Global Validators). |
| **`lib/features/`** | Independent domain vertical modules structured with Clean Architecture (`data/`, `domain/`, `presentation/`, `routes/`, `di/`). |

---

## 3. Strict Import & Dependency Matrix

```
┌─────────────────────────────────────────────────────────────┐
│                       features/[feature]                   │
└───────┬──────────────────────┬──────────────────────┬───────┘
        │                      │                      │
        ▼                      ▼                      ▼
┌───────────────┐      ┌───────────────┐      ┌───────────────┐
│     core/     │      │ design_system │      │    shared/    │
└───────────────┘      └───────────────┘      └───────────────┘
```

### Direct Rules:
1. **Feature-to-Feature Isolation**: `features/speaking` MUST NEVER import `features/writing` directly.
2. **Core Independence**: `core/` MUST NEVER import `features/` or `shared/`.
3. **Design System Isolation**: `design_system/` imports ONLY Flutter SDK and `core/theme/` or `core/extensions/`.
4. **Domain Layer Purity**: `domain/` contains pure Dart code only. NO `package:flutter` imports.
5. **Presentation Layer Isolation**: `presentation/` contains UI & Controllers only. NO network or database dependencies.

---

## 4. State Management Flow (Riverpod 2.x/3.x)

```
[ UI Widget ]  ─── user action ───►  [ Controller / Notifier ]
     ▲                                           │
     │                                      calls usecase
     │                                           ▼
[ UI Rebuild ]  ◄── state update ───  [ Domain UseCase / Entity ]
                                                 │
                                           calls repository
                                                 ▼
                                      [ Data Repository / Remote ]
```

- **State Representation**: Immutable state classes created via `@freezed` or `copyWith`.
- **Side Effects**: Single-shot UI side effects (snackbars, navigation triggers) are emitted as discrete `Effect` events or handled via `ref.listen`.
- **Dependency Injection**: Riverpod `Provider` and `AsyncNotifierProvider` instances serve as the sole DI mechanism.

---

## 5. Centralized AI Platform Architecture (`core/ai/`)

All AI operations flow through the unified `AIRepository` interface:

```
[ Feature: AI Feedback ] ──► [ AIRepository Interface ]
                                    │
                         ┌──────────┴──────────┐
                         ▼                     ▼
               [ OpenAIProvider ]    [ GeminiProvider ]
```

### Key Responsibilities of `core/ai/`:
- Multi-LLM provider fallback and routing.
- Real-time token streaming via `Stream<AiStreamChunk>`.
- Structured prompt template hydration (`PromptTemplateEngine`).
- Token usage tracking and rate limit protection.

---

## 6. Testing Strategy & Directory Structure

Tests strictly mirror the `lib/` layout to ensure 1:1 test coverage tracking:

```
test/
├── core/
│   ├── ai/
│   └── network/
├── design_system/
├── features/
│   └── speaking/
│       ├── data/
│       ├── domain/
│       └── presentation/
└── shared/
```

- **Unit Tests**: Mock external boundaries (datasources/HTTP) using `mocktail`.
- **Widget Tests**: Test `design_system/` and `presentation/widgets/` in isolation.
- **Integration Tests**: Feature flows end-to-end with mock API responses.

---

## 7. Naming & File Size Rules

1. **Max File Size**: 200 lines maximum (Strictly enforced via linter). Target size: 50-150 lines.
2. **One Symbol Per File**: 1 public class, 1 widget, 1 enum, 1 mixin, or 1 extension per file.
3. **Forbidden Files**: No `utils.dart`, `helpers.dart`, `common.dart`, `misc.dart`.
4. **Explicit Naming Rules**:
   - `speaking_practice_page.dart`
   - `speaking_controller.dart`
   - `speaking_state.dart`
   - `speaking_repository_impl.dart`
