# Shared Module (`lib/shared`)

## Purpose
Reusable cross-feature business abstractions (User Entity, Session Provider, Common Validators, Common Data Models).

## Allowed Imports
- `easy_ielts/core/...`
- `easy_ielts/design_system/...`

## Forbidden Imports
- `easy_ielts/features/...` (Features import Shared, never vice versa)
