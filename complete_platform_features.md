# System Features Beyond Auth & Profile

Beyond Authentication and Profile Management, the platform includes a complete **IELTS AI Learning Ecosystem** with AI evaluations, 5-tier recommendation engines, diagnostic testing, and multi-module practice tools.

---

## 🧠 1. Multi-Provider AI Evaluation Engine (`services/ai_engine`)

An AI microservice wrapping **OpenAI GPT-4o**, **Whisper**, **Gemini 1.5 Flash/Pro**, and **Google Antigravity SDK Agent v2.0**:

### Evaluation Services:
1. **Speaking Evaluation & Audio Transcription**:
   * Uses OpenAI Whisper to transcribe audio files in real time.
   * Evaluates Pronunciation, Fluency & Coherence, Lexical Resource, and Grammatical Range on a 0.0 – 9.0 IELTS band scale.
2. **Writing Essay Evaluation**:
   * Analyzes IELTS Academic/General Task 1 & Task 2 essays.
   * Evaluates Task Achievement, Coherence/Cohesion, Lexical Resource, and Grammatical Range.
   * Generates line-by-line grammar feedback, vocabulary enhancements, and model answer suggestions.
3. **Grammar & Sentence Evaluation**:
   * Instant error detection, error taxonomy categorization (e.g., subject-verb agreement, article misuse, tense inconsistency), and explanation.
4. **Google Antigravity SDK Memory Synthesis**:
   * Uses `google.antigravity.Agent` (`antigravity-educational-memory-agent`) to synthesize long-term learning history into an evolving `UserLearningMemory` profile.

---

## 🎯 2. Diagnostic Placement Test & Scoring Engine (`go_backend` & `backend`)

* **Endpoint**: `POST /api/v1/placement/submit/`
* **Diagnostic Scoring**:
  * Evaluates diagnostic reading, listening, and grammar questions.
  * Calculates initial overall IELTS Band Score (e.g., Band 6.5) and target gap.
  * Generates an initial study plan and assigns skill-level focus areas.

---

## 📊 3. 5-Tier Educational Recommendation Engine (`backend`)

* **Endpoint**: `GET /api/v1/content-recommendations/`
* **Algorithm**: Analyzes student performance data, spaced-repetition memory curves, and AI memory synthesis to build a 5-tier prioritized daily study plan:
  * **Tier 1 (Critical Weaknesses)**: Urgent remediation for skills below target band score (e.g., past tense errors in speaking).
  * **Tier 2 (Scheduled Reviews)**: Spaced repetition for vocabulary and grammar rules reaching decay threshold.
  * **Tier 3 (Personalized Learning Roadmap)**: Next sequential lessons tailored to target exam date.
  * **Tier 4 (AI Suggestions)**: Dynamic exercises recommended by Google Antigravity Memory Agent.
  * **Tier 5 (Optional Practice)**: Extra challenge exercises and full-length practice.

---

## 📝 4. IELTS Practice Modules in Flutter Mobile App (`easy_english`)

The Flutter app contains 9 complete practice feature modules:

1. **AI Coach (`lib/features/ai_coach`)**: Interactive AI tutor for 24/7 Q&A and progress insights powered by Google Antigravity Agent.
2. **Speaking Practice (`lib/features/speaking`)**: Audio recording, Whisper transcription, and real-time IELTS speaking band evaluation.
3. **Writing Lab (`lib/features/writing`)**: Essay submissions, real-time rubric feedback, and band score predictions.
4. **Mock Exam (`lib/features/mock_exam`)**: Timed exam simulation for Reading, Listening, Writing, and Speaking under realistic test conditions.
5. **Grammar Master (`lib/features/grammar`)**: Interactive grammar drills, error detection, and explanation cards.
6. **Sentence Builder (`lib/features/sentence_builder`)**: Syntax rearrangement and complex sentence construction practice.
7. **Word Bank (`lib/features/word_bank`)**: Flashcards, spaced-repetition vocabulary trainer, and pronunciation guide.
8. **Placement Test (`lib/features/placement_test`)**: Multi-stage diagnostic test for new students.
9. **Student Dashboard (`lib/features/dashboard`)**: Overall progress charts, weekly activity analytics, and band score trajectory.

---

## 🌐 5. Web Landing & Support Portal (`web_landing`)

* Modern, responsive web landing page (`index.html`) featuring course overviews, interactive feature showcases, pricing tiers, and beta signup.
* Support portal (`support.html`) for subscription synchronization across iOS App Store and Google Play.
