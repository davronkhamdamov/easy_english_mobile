# Features (`lib/features`)

## Purpose
Independent business capabilities structured as self-contained Clean Architecture modules.

## Standard Feature Folder Structure
Each feature must contain:
- `data/` (`datasources/`, `repositories/`, `models/`, `mappers/`, `dto/`)
- `domain/` (`entities/`, `repositories/`, `usecases/`)
- `presentation/` (`pages/`, `widgets/`, `controllers/`, `providers/`, `state/`, `effects/`)
- `routes/`
- `di/`

## Isolation Rule
A feature MUST NEVER import another feature directly.
If feature A needs data from feature B, use Shared contracts or Riverpod stream/state listeners.
