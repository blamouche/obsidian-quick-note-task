# Contract: Task Toggle and Recurrence

## Trigger
- User checks a task checkbox in dropdown list.

## Preconditions
- Task item has a valid source reference in configured vault.
- Source file is writable.

## Completion Behavior
- System marks selected source task as completed in markdown.
- On successful write, toggled task is removed from dropdown on next refresh.

## Failure Behavior
- If source update fails, system:
  - shows explicit failure feedback,
  - keeps task in uncompleted state in dropdown,
  - does not create recurrence occurrence.

## Recurrence Behavior
- If task has valid recurrence rule and completion succeeds:
  - system creates next occurrence according to rule.
- If recurrence rule is invalid and completion succeeds:
  - completion remains applied,
  - no new occurrence is created,
  - user receives explicit recurrence warning.

## Consistency Guarantees
- Toggle operation targets the intended task occurrence even when identical text exists in other files.
- No markdown change is allowed outside configured vault scope.
