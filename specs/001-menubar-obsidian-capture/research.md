# Research: Obsidian Menu Bar Capture

## Decision 1: Native macOS status bar architecture
- Decision: Use a status item with two capture actions (`Quick Note`, `Task`) and a settings action.
- Rationale: Directly matches the required interaction model and minimizes app surface.
- Alternatives considered:
  - Full-window app only: slower for quick capture.
  - Global hotkey only: less discoverable and not explicitly requested.

## Decision 2: Task markdown compatibility format
- Decision: Write tasks as markdown checkboxes using `- [ ] {title}` and add optional due date as `📅 YYYY-MM-DD`.
- Rationale: This format is recognized by the Tasks plugin and remains queryable via Dataview.
- Alternatives considered:
  - Inline metadata without checkbox: weak Tasks compatibility.
  - Frontmatter tasks: overkill for quick capture flow.

## Decision 3: Daily note path and append strategy
- Decision: Resolve target file as `{destination}/YYYY-MM-DD - Note.md`, create file if absent, append new content at file end with separator `\n\n---\n\n`.
- Rationale: Deterministic and human-readable behavior aligned with feature rules.
- Alternatives considered:
  - One file per entry: breaks requested daily aggregation.
  - Replace file content: violates append-only requirement.

## Decision 4: Destination persistence and access safety
- Decision: Persist selected folder using a security-scoped bookmark and validate access on each write.
- Rationale: Supports macOS permission model and robust handling after restart.
- Alternatives considered:
  - Store plain path only: brittle when permissions change.
  - Prompt folder every capture: poor UX.

## Decision 5: Test strategy
- Decision: Use unit tests for formatting/validation/path rules and integration tests for actual file creation + append + error handling.
- Rationale: Critical flows are filesystem and formatting heavy; both are regression-prone.
- Alternatives considered:
  - Manual testing only: insufficient for merge gates.
  - UI tests only: too slow and weak for markdown contract validation.
