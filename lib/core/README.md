# Core Module (`lib/core`)

## Purpose
Global infrastructure and technical foundation of the enterprise application. Contains low-level primitives: Network, AI Platform, Key-Value & Database Storage, Security, Navigation, Localization, Logging, and Error handling.

## Allowed Imports
- `package:flutter/...`
- Third-party packages (Dio, Isar, Flutter Secure Storage, etc.)

## Forbidden Imports
- `easy_ielts/features/...` (NEVER import features into core)
- `easy_ielts/shared/...` (Core is completely self-contained)
- `easy_ielts/design_system/...`
