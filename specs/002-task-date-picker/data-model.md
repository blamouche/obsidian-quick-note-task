# Data Model: Task Date Picker

## Task Input State
- Purpose: represent in-memory task form state before submission.
- Fields:
  - `title`: required text input.
  - `dueDateEnabled`: boolean indicating whether due date should be included.
  - `selectedDueDate`: optional date value from date picker.
- Validation:
  - `title` must be non-empty after trimming.
  - if `dueDateEnabled` is false, `selectedDueDate` is ignored.

## Due Date Selection
- Purpose: normalized due date value from UI control.
- Fields:
  - `date`: optional calendar date.
- Rules:
  - serialize as `YYYY-MM-DD` when present.
  - absence produces task output without date token.

## Task Markdown Entry
- Purpose: markdown line appended to daily note.
- Fields:
  - `taskLine`: `- [ ] {title}` with optional `📅 YYYY-MM-DD` suffix.
- Rules:
  - compatibility with existing Tasks/Dataview parsing must be preserved.

## Relationships
- `Task Input State` maps to one `Task Markdown Entry` per submission.
- `Due Date Selection` enriches `Task Markdown Entry` only when enabled.
