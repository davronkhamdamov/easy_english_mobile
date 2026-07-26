# Feature Architecture Blueprint (`lib/features`)

## Purpose
Every business capability in `easy_ielts` is implemented as a self-contained feature module inside `lib/features/`. Features are designed to behave like modular, decoupled mini-applications.

## Canonical Feature Structure
Every feature MUST contain exactly these 5 sub-directories:

```
features/[feature_name]/
├── README.md                 # Feature specification & architectural scope
├── data/                     # Data Access Layer
│   ├── datasources/          # Remote & local API/storage clients
│   ├── dto/                  # Data Transfer Objects (Raw API JSON models)
│   ├── mappers/              # DTO/Model <-> Entity converters
│   ├── models/               # Local DB schemas
│   └── repositories/         # Repository implementations
├── domain/                   # Business Core (Pure Dart, NO Flutter imports)
│   ├── entities/             # Immutable business domain entities
│   ├── repositories/         # Repository interfaces/contracts
│   └── usecases/             # Single-purpose business use cases
├── presentation/             # UI & Controller Layer
│   ├── controllers/          # Riverpod AsyncNotifier controllers
│   ├── effects/              # Single-shot UI side-effect events
│   ├── pages/                # Screen-level entry widgets
│   ├── providers/            # UI state providers
│   ├── state/                # Immutable UI state models (@freezed)
│   └── widgets/              # Extracted feature-specific widgets
├── routes/                   # GoRouter route declarations
└── di/                       # Riverpod provider dependency injection declarations
```

## Mandatory Rules for AI Agents
1. **Zero Cross-Feature Imports**: A feature MUST NEVER import directly from another feature directory.
2. **File Size Limit**: No file in a feature may exceed **200 lines**. Target size: **50-150 lines**.
3. **Widget Extraction**: Extract all sub-components inside `presentation/widgets/`. Do not write inline `build` trees exceeding 40 lines.
4. **Clean Architecture Purity**: `domain/` must contain zero Flutter dependencies.
