# Research: Task Date Picker

## Decision 1: Replace manual due-date text with date picker control
- Decision: Use a native date picker in the Task capture modal as the primary input for due date.
- Rationale: avoids format errors and reduces user friction while matching macOS UI patterns.
- Alternatives considered:
  - Keep free-text date field with helper text: still error-prone.
  - Hybrid text + picker: unnecessary complexity for this scope.

## Decision 2: Keep due date optional with explicit empty-state behavior
- Decision: user can submit task with no selected date; output remains a task line without due date marker.
- Rationale: preserves existing workflow and compatibility expectations.
- Alternatives considered:
  - Force due date selection: changes feature semantics and user flow.

## Decision 3: Preserve output serialization contract
- Decision: when selected, due date is serialized exactly as `YYYY-MM-DD` in the existing markdown format.
- Rationale: ensures backward compatibility with Tasks and Dataview queries.
- Alternatives considered:
  - Locale-formatted date output: breaks deterministic parsing.

## Decision 4: Limit implementation scope to task UI and submit pipeline
- Decision: no changes to destination storage or daily note write mechanics except consuming date picker value.
- Rationale: keeps risk low and avoids unrelated regressions.
- Alternatives considered:
  - Refactor full capture UI stack: unnecessary for requested enhancement.
