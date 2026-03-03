# Contract: Capture Workflow

## Menu Actions
- Trigger: user clicks menu bar icon.
- Required options:
  - `Quick Note`
  - `Task`
- Additional required option:
  - `Settings` (for destination folder selection/update)

## Quick Note Submission Contract
- Required input:
  - `text` (string, non-empty after trimming)
- Behavior:
  - Reject empty text with explicit error message.
  - On success, append formatted entry to current daily file.

## Task Submission Contract
- Required input:
  - `title` (string, non-empty after trimming)
- Optional input:
  - `dueDate` (local date)
- Behavior:
  - Reject empty title with explicit error message.
  - Format output according to markdown output contract.

## Error Contract
- For inaccessible destination/file lock/permission loss:
  - Show user-facing error explaining failure cause.
  - Keep user input available for retry (no data loss).
