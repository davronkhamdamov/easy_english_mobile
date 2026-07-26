# Centralized AI Platform (`lib/core/ai`)

## Purpose & Architecture
`core/ai/` is the single centralized engine managing all Generative AI operations across the application (speaking evaluations, essay scoring, interactive chat, feedback generation).

## Architecture Blueprint
```
[ Features: speaking, writing, ai_chat ]
                   │
                   ▼
         [ AIRepository Interface ]
                   │
  ┌────────────────┼────────────────┬────────────────┐
  ▼                ▼                ▼                ▼
[ OpenAIProvider ] [ GeminiProvider ] [ ClaudeProvider ] [ OllamaProvider ]
```

## Internal Component Structure
- `models/`: Unified prompt requests (`AiPromptRequest`), responses (`AiCompletionResponse`), and streaming chunks (`AiStreamChunk`).
- `parsers/`: Robust JSON / structured output parsers for extractable LLM outputs.
- `prompts/`: `PromptTemplateEngine` for dynamically injecting variables into prompt templates stored in assets.
- `providers/`: Pluggable LLM provider implementations (`OpenAiProvider`, `GeminiAiProvider`, `ClaudeAiProvider`, `OllamaAiProvider`).
- `repository/`: `AIRepository` interface and `AIRepositoryImpl` implementation with fallback provider routing.
- `services/`: Token counting, rate-limiting, and cost estimation services.
- `streaming/`: SSE / WebSockets stream handler for real-time token rendering.

## Mandates for AI Agents
1. **Never Call LLMs Directly in Features**: Feature code MUST NOT instantiate or call OpenAI, Gemini, or Claude APIs directly.
2. **Depend on AIRepository**: Features inject `AIRepository` via Riverpod.
3. **Seamless Provider Switching**: Switching default provider or fallback provider must require ZERO code changes in feature modules.
