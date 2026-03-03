# Data Model: UX Productivity Flow

## Configuration State
- Purpose: represent readiness of the app to accept capture actions.
- Values:
  - `unconfigured`: no destination stored.
  - `configuredValid`: destination exists and is writable.
  - `configuredInvalid`: destination stored but inaccessible/invalid.
- Validation rules:
  - transitions to `configuredValid` only after successful destination check.
  - any failed validation/readability check forces `configuredInvalid`.

## Capture Action Availability
- Purpose: express whether each capture action is currently executable.
- Fields:
  - `quickNoteEnabled`: boolean.
  - `taskEnabled`: boolean.
  - `disabledReason`: optional user-facing reason when false.
- Rules:
  - both actions disabled for `unconfigured` and `configuredInvalid`.
  - both actions enabled only for `configuredValid`.

## Capture Feedback
- Purpose: provide immediate UX response after user action.
- Fields:
  - `status`: `success | blocked | error`.
  - `title`: short message.
  - `detail`: actionable description.
  - `preservedDraft`: optional user input retained after failures.
- Rules:
  - `blocked` must provide setup guidance.
  - `error` must explain issue and keep draft recoverable.

## Relationships
- `Configuration State` determines `Capture Action Availability`.
- Submission attempt emits one `Capture Feedback`.
- `Capture Feedback.preservedDraft` links back to user capture input when failure occurs.

## State Transitions
- `unconfigured` -> `configuredValid`: user selects valid destination.
- `configuredValid` -> `configuredInvalid`: destination becomes inaccessible.
- `configuredInvalid` -> `configuredValid`: user reconfigures or restores access.
- Any non-valid state keeps capture actions blocked.
