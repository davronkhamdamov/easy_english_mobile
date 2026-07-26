# Design System Architecture (`lib/design_system`)

## Purpose & Responsibility
The `design_system/` directory contains the complete atomic UI component library for the application. Every screen across all 500+ features MUST compose screens exclusively using components from this design system.

## Category Breakdown
- `animations/`: Reusable transition & implicit animation wrappers (`FadeInScale`, `SlideFadeTransition`).
- `appbars/`: Primary, secondary, and transparent app bars.
- `avatars/`: User profile & bot avatar widgets.
- `badges/`: Status chips, band score badges, tags.
- `bottom_sheets/`: Modular modal bottom sheets.
- `buttons/`: `PrimaryButton`, `SecondaryButton`, `OutlineButton`, `GhostButton`.
- `cards/`: Elevated, outlined, and interactive card containers.
- `chips/`: Filter chips, choice chips, input chips.
- `dialogs/`: Alert dialogs, confirmation dialogs, prompt dialogs.
- `empty_states/`: Standard empty content placeholder views.
- `error_states/`: Reusable error views with retry triggers.
- `forms/`: Form section headers, field wrappers.
- `icons/`: Custom icon set wrappers and vector renderers.
- `inputs/`: `TextInputField`, `SearchInputField`, `OtpInputField`.
- `loading/`: Shimmer loading skeletons, activity indicators.
- `modals/`: Fullscreen and dialog modal wrappers.
- `progress/`: Band score progress bars, radial indicators.
- `snackbars/`: Custom toast & snackbar feedback popups.
- `spacing/`: Insets, gaps, padding tokens (`AppSpacing`).
- `typography/`: Text style scales (`AppTypography`).

## Strict Rules for AI Agents
1. **Zero Business Logic**: No network calls, state persistence, or feature-specific logic.
2. **Reusability First**: If a component is created for a feature screen and can be reused, move it to `design_system/`.
3. **Strict Theming**: Always use `Theme.of(context)` and `ThemeExtension`. Never hardcode colors (`Color(0xFF...)`), font sizes, or pixel padding inside screens.
