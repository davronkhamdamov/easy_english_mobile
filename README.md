# Easy IELTS - Enterprise Flutter Application

> **Notice for AI Coding Assistants & Engineering Teams**: This repository follows a strict **Feature-First + Clean Architecture** design paradigm engineered for 500+ screens, 10,000+ files, and long-term multi-agent maintainability.

---

## 🏛️ Architecture Overview

```
lib/
├── app/             # Application initialization, environment & global observers
├── core/            # Infrastructure primitives (Network, Storage, AI Platform, Security, Errors)
├── design_system/   # Atomic UI component library (Buttons, Cards, Dialogs, Inputs, Theme)
├── shared/          # Reusable cross-feature domain entities, validators, and user state
└── features/        # Independent, isolated business capability modules
```

---

## ⚠️ Core Architectural Constraints for AI Agents

Any AI assistant reading this codebase MUST strictly adhere to the following rules:

### 1. File & Class Boundaries
- **Maximum File Length**: **200 lines max**. Target size: **50–150 lines**.
- **Single Responsibility**: Exactly **1 public class, widget, enum, mixin, or extension per file**.
- **No Junk Drawers**: `utils.dart`, `helpers.dart`, `common.dart`, `misc.dart` are **strictly forbidden**. Use explicit filenames like `email_validator.dart` or `date_formatter.dart`.
- **Extracted Widgets**: Large `build()` methods are forbidden. Extract sub-widgets immediately into `presentation/widgets/`.

### 2. Import Isolation Matrix
- **Feature Isolation**: `features/feature_a` MUST NEVER import `features/feature_b`.
- **Core Isolation**: `core/` MUST NEVER import `features/` or `shared/`.
- **Design System Isolation**: `design_system/` imports ONLY Flutter SDK and `core/theme/` / `core/extensions/`. Never import features or network APIs.
- **Domain Purity**: `domain/` contains **pure Dart code only**. No `package:flutter` imports.

### 3. State Management & Data Handling
- **Riverpod**: State management uses Riverpod `Notifier` / `AsyncNotifier` providers located in `presentation/controllers/` and `di/`.
- **Functional Error Handling**: Never throw unhandled exceptions. All domain operations return `Result<T>` containing a explicit `Failure`.
- **Entities vs DTOs vs Models**: Keep `Entity` (domain), `DTO` (remote JSON), `Model` (local DB), and `Mapper` completely separated.

### 4. Centralized AI Platform
- Features MUST NOT call OpenAI, Gemini, Claude, or Ollama directly.
- All AI operations MUST pass through `AIRepository` in `lib/core/ai/`.

---

## 📁 Detailed Folder Documentation

For detailed guidelines on specific modules, refer to their internal READMEs:
- [App Setup](file:///root/easy/easy_ielts/lib/app/README.md)
- [Core Infrastructure](file:///root/easy/easy_ielts/lib/core/README.md)
- [Centralized AI Platform](file:///root/easy/easy_ielts/lib/core/ai/README.md)
- [Design System](file:///root/easy/easy_ielts/lib/design_system/README.md)
- [Shared Domain & Logic](file:///root/easy/easy_ielts/lib/shared/README.md)
- [Feature Module Blueprint](file:///root/easy/easy_ielts/lib/features/README.md)
- [Exemplar Feature: Speaking](file:///root/easy/easy_ielts/lib/features/speaking/README.md)
