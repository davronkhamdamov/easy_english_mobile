# Centralized AI Platform (`lib/core/ai`)

## Purpose
Unified abstraction layer for all LLM and Generative AI interactions. Provides pluggable AI providers (OpenAI, Gemini, Claude, Ollama), streaming chunk handlers, prompt template hydrators, token estimation, and JSON schema parsing.

## Key Rules
1. Features MUST NEVER call OpenAI, Gemini, or Claude directly.
2. All feature communication passes through `AIRepository`.
3. Provider swap must require ZERO changes in feature code.
