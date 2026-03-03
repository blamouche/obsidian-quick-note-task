# Research: UX Productivity Flow

## Decision 1: Enforce configuration-first gating in menu actions
- Decision: disable `Quick Note` and `Task` actions both visually and functionally
  until a valid destination is configured and accessible.
- Rationale: fail-closed behavior prevents noisy errors and clarifies first action.
- Alternatives considered:
  - Keep actions enabled and show errors on submit: higher friction and repeated failures.
  - Hide actions entirely: lowers discoverability of feature capabilities.

## Decision 2: Promote a single clear setup action for first run
- Decision: when unconfigured, show a prominent setup path from the main menu and
  direct guidance to select destination.
- Rationale: reduces decision load and time-to-first-success for new users.
- Alternatives considered:
  - Passive warning text only: users still need to infer next action.
  - Separate onboarding window: unnecessary workflow complexity.

## Decision 3: Preserve low-click capture flow for repeat use
- Decision: once configured, keep direct access to note/task capture with short
  confirmation feedback and no extra pre-check dialogs.
- Rationale: productivity-focused UX prioritizes minimal interruption.
- Alternatives considered:
  - Add confirmation step before each write: increases clicks and slows routine use.
  - Route all actions through settings panel: unnecessary for frequent captures.

## Decision 4: Keep robust error feedback with draft preservation
- Decision: on submit failure, show actionable error message and preserve entered
  content for retry.
- Rationale: avoids data loss and reduces user frustration during transient issues.
- Alternatives considered:
  - Generic error without context: slower recovery.
  - Clear inputs on error: forces re-entry and harms productivity.

## Decision 5: Constrain scope to UX orchestration, not data format
- Decision: do not alter markdown serialization contracts for quick notes/tasks.
- Rationale: isolates UX improvements and avoids compatibility regressions.
- Alternatives considered:
  - Redesign output format simultaneously: larger risk and out-of-scope change.

## Implementation Notes (2026-03-03)
- Configuration readiness is now resolved through explicit states:
  `notConfigured`, `configuredValid`, `configuredInvalid`.
- Menu availability and settings action titles are now derived from readiness state.
- Disabled capture actions are blocked both in menu UI and in action handlers.
- Capture failure logging now uses redacted payload metadata rather than raw note/task content.
