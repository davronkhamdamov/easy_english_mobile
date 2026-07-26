# App Module (`lib/app`)

## Purpose
Entry point bootstrapping for the enterprise application. Sets up global environment configuration, telemetry observers, dependency initialization, and root MaterialApp/ProviderScope setup.

## Allowed Imports
- `package:flutter/...`
- `package:flutter_riverpod/...`
- `easy_ielts/core/...`
- `easy_ielts/design_system/...`
- `easy_ielts/shared/...`
- `easy_ielts/features/...` (Only via feature route registration)

## Forbidden Imports
- Direct domain or presentation internals of specific features.
