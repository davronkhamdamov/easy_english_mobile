# Core Infrastructure Module (`lib/core`)

## Responsibilities & Purpose
The `core/` module provides low-level technical infrastructure, reusable utilities, and framework primitives. It represents the foundation upon which all shared logic and business features are built.

## Infrastructure Sub-Domains
- `ai/`: Centralized AI engine (OpenAI, Gemini, Claude, Ollama providers, streaming, prompt hydrator).
- `analytics/`: Unified telemetry tracker.
- `api/`: HTTP client configurations, interceptors, base API endpoints.
- `cache/`: In-memory & LRU cache managers.
- `config/`: Environment configuration (`AppEnvironment`) and feature flags.
- `database/`: Local database engines (Isar / Hive).
- `errors/`: Global `Failure`, `AppException`, and functional `Result<T>` monad types.
- `extensions/`: Pure Dart & Flutter extensions (`BuildContext`, `DateTime`, `String`).
- `logging/`: Structured console & file logging engine.
- `navigation/`: GoRouter setup, deep link routing contracts.
- `network/`: Dio/Http client abstraction, connectivity checking.
- `security/`: Encryption services, secure storage (`FlutterSecureStorage`).
- `theme/`: Theme extensions, color tokens, typography scales.

## Strict Rules for AI Agents
1. **Zero Core-to-Feature Imports**: `core/` MUST NEVER import from `lib/features/` or `lib/shared/`.
2. **Reusability**: Everything in `core/` must be 100% domain-agnostic and reusable across any Flutter enterprise app.
3. **No UI Widgets**: UI widgets belong in `lib/design_system/`, not in `core/`.
