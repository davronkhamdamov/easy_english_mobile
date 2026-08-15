# Word Bank & Spaced Repetition (SRS) Flashcard Module

## Overview
This feature implements the vocabulary inventory and SuperMemo SM-2 Spaced Repetition System (SRS) flashcard review module for the Easy IELTS application.

## Architecture
This module follows Clean Architecture principles (`data`, `domain`, `presentation`, `routes`, `di`).

- `data/`: Remote datasource (`WordBankRemoteDataSourceImpl`), JSON serializable models (`FlashcardItemModel`), repository implementations (`WordBankRepositoryImpl`). Real API calls only.
- `domain/`: Entities (`FlashcardItem`), Repository interfaces (`WordBankRepository`), SM-2 algorithm services (`SM2Algorithm`, `ReviewRating`, `SpacedRepetitionSession`), Use cases (`GetWordBankItemsUseCase`, `GetDueFlashcardsUseCase`, `SubmitFlashcardReviewUseCase`, `AddWordUseCase`, `DeleteWordUseCase`).
- `presentation/`: State model (`WordBankState`), Controller/Notifier (`WordBankProvider`), Widgets (`WordBankHeaderStats`, `WordBankFilterBar`, `WordBankItemCard`, `Flashcard3DCard`, etc.), Screens (`WordBankScreen`, `FlashcardReviewScreen`).
- `di/`: Dependency injection declarations (`WordBankDI`).
- `routes/`: GoRouter/Material route declarations (`WordBankRoutes`).

## File Size Rule
All files strictly maintain a line count under 200 lines.
