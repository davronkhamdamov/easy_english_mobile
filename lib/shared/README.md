# Shared Module Architecture (`lib/shared`)

## Purpose & Scope
The `shared/` directory bridges core infrastructure with business domain models. It contains reusable domain entities, common data models, global validators, and application-wide providers that are shared across multiple features.

## Sub-Modules
- `auth/`: Shared authentication session provider (`SessionProvider`).
- `user/`: `UserEntity` core user representation.
- `validators/`: Standalone input validators (`email_validator.dart`, `password_validator.dart`).
- `common_models/`: Universal value objects (e.g. `PaginationMeta`, `BandScore`).
- `shared_providers/`: App-wide Riverpod providers (`currentUserProvider`).
- `shared_repositories/`: Shared data contracts (`UserRepository`).
- `shared_services/`: Reusable domain services (`ConnectivityService`).
- `shared_widgets/`: Business-aware reusable widgets (e.g., `UserAvatarWithStatus`).

## Guidelines for AI Agents
- Put items here **only** if they are required by 2 or more distinct feature modules.
- If an entity or validator is used by only 1 feature, keep it inside `features/[feature_name]/`.
- `shared/` MUST NEVER import from `features/`.
