# App Module Architecture (`lib/app`)

## Responsibilities & Purpose
The `app/` module is the top-level orchestrator of the Flutter application. It is responsible for application initialization, dependency bootstrapping, environment setup, global telemetry observers, and constructing the root `MaterialApp` / `ProviderScope`.

## Directory Structure
- `app.dart`: Root widget declaring `MaterialApp.router`, global themes, and localization delegates.
- `app_bootstrapper.dart`: Async initialization sequence (enabling Flutter bindings, loading env config, initializing database, register providers).
- `app_environment.dart`: Environment configuration parser (`dev`, `staging`, `prod`).
- `app_observer.dart`: Global Riverpod state observer and navigation telemetry logger.

## Import Rules for AI Agents
- **Allowed**:
  - `package:flutter/...`
  - `package:flutter_riverpod/...`
  - `easy_ielts/core/...`
  - `easy_ielts/design_system/...`
  - `easy_ielts/shared/...`
  - `easy_ielts/features/*/routes/...` (For router registration)
- **Forbidden**:
  - Direct feature domain, presentation, or data implementations. Features register themselves via GoRouter route declarations.
