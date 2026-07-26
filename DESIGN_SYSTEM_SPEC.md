  ### Step 1: Create DESIGN_SYSTEM_SPEC.md

  Create a file named DESIGN_SYSTEM_SPEC.md in your project root. This serves as the master contract for your design system tokens and components:

    # Design System Specification

    ## 1. Design Tokens & Styling Foundation (`src/styles/tokens.css`)
    - **Color Palette**: HSL-tailored dark/light mode variables (Primary Accent, Surface, Glassmorphism backdrop, Text, Borders).
    - **Typography**: Google Font (Inter / Outfit), responsive scaling (`--text-sm`, `--text-md`, `--text-lg`, `--text-xl`).
    - **Spacing & Shadows**: Standard spacing scale (4px, 8px, 16px, 24px, 32px) and subtle depth shadows (`--shadow-sm`, `--shadow-md`, `--shadow-lg`).
    - **Transitions**: Smooth micro-animations (`--transition-fast: 150ms ease`, `--transition-smooth: 300ms cubic-bezier(...)`).

    ## 2. Core UI Components (`src/components/`)
    ### 2.1 Button (`src/components/Button/`)
    - **Variants**: `primary`, `secondary`, `outline`, `ghost`, `danger`.
    - **Sizes**: `sm`, `md`, `lg`.
    - **States**: Default, Hover (subtle lift + glow), Active, Disabled, Loading (spinner).
    - **Props/Attributes**: `variant`, `size`, `isLoading`, `disabled`, `leftIcon`, `rightIcon`.

    ### 2.2 Input & Form Fields (`src/components/Input/`)
    - **Types**: Text, Password, Email, Search.
    - **States**: Default, Focus (glowing border), Error (red highlight + helper text), Disabled.
    - **Features**: Icon support (left/right), clear button, error message label.

    ### 2.3 Card Component (`src/components/Card/`)
    - **Variants**: `elevated`, `outlined`, `glass`.
    - **Sub-components**: `Card.Header`, `Card.Body`, `Card.Footer`.
    - **Interactivity**: Optional hover zoom/glow effect for clickable cards.

    ## 3. Component Showcase Page (`src/App.jsx` or `index.html`)
    - Interactive preview gallery displaying all components, variants, sizes, and states side-by-side.
    ──────
  ### Step 2: Initialize TODO.md

  Create a TODO.md file to track modular progress:

    # Design System Implementation Todo List

    - [ ] **Phase 1: Design System Foundation**
      - [ ] 1.1 Create CSS design tokens (colors, typography, shadows, micro-animations)
      - [ ] 1.2 Set up base layout container and reset styles

    - [ ] **Phase 2: Core Components**
      - [ ] 2.1 Implement `Button` component (all variants, sizes, states, and ripple/glow hover effects)
      - [ ] 2.2 Implement `Input` component (focus states, icons, helper text, error handling)
      - [ ] 2.3 Implement `Card` component (elevated, outlined, glassmorphism)

    - [ ] **Phase 3: Interactive Showcase**
      - [ ] 3.1 Build interactive component preview gallery page
      - [ ] 3.2 Add dark/light mode toggle to verify design token reactivity
    ──────
  ### Step 3: Kick off the Agent (Copy-Paste Prompt)

  Give the following prompt to the AI agent to start Phase 1 & 2:

  │ "Read DESIGN_SYSTEM_SPEC.md and TODO.md. Start with Task 1.1 and 1.2 to build the CSS design system tokens. Then implement Task 2.1 (the Button component
  │ with all variants, sizes, states, and micro-animations). Use subagents to keep context clean, test the component, update TODO.md with [x], and commit your
  │ work to git."
  ──────
  ### Step 4: How the Agent Will Execute

  1. Design Tokens (src/styles/tokens.css):
  The agent creates modern CSS custom properties with HSL colors, smooth transitions, and glassmorphism defaults.
  2. Button Component (src/components/Button/):
  The agent builds a clean, reusable Button component with rich hover animations and states.
  3. Showcase Gallery:
  The agent mounts the Button on a live showcase page so you can immediately see and test the design interactively.
  4. State Update:
  The agent marks Task 1.1, 1.2, and 2.1 as [x] in TODO.md, commits to Git, and reports the completed progress to you.
    ──────
### Work Summary

  • Provided DESIGN_SYSTEM_SPEC.md specification template for design tokens, buttons, inputs, and cards.
  • Created TODO.md state machine file for phase-by-phase execution tracking.
  • Shared copy-paste execution prompt to kick off the design system build.
