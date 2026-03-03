# Contract: Task Input UI

## Trigger
- User clicks menu bar icon and selects `Task`.

## Required Fields
- `title` (required)

## Optional Fields
- `dueDate` selected via date picker

## Behavior
- User can submit with title only (no due date).
- User can select/change/clear due date before submitting.
- Cancel action closes the flow without writing to file.
- On write failure, error is shown and title input remains recoverable.

## UI State Notes
- Date picker is disabled by default.
- A dedicated toggle enables/disables due-date selection.
- If toggle is disabled at submit time, due date is omitted from output.
