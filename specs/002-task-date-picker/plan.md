# Implementation Plan: Task Date Picker

**Branch**: `002-task-date-picker` | **Date**: 2026-03-03 | **Spec**: [/Users/benoitlamouche/Documents/github/obsidian-quick-note-task/specs/002-task-date-picker/spec.md](/Users/benoitlamouche/Documents/github/obsidian-quick-note-task/specs/002-task-date-picker/spec.md)
**Input**: Feature specification from `/specs/002-task-date-picker/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

Add an explicit date picker to the existing Task capture flow in the macOS menu bar
app, replacing manual due-date text entry while preserving optional due-date behavior
and markdown compatibility for Tasks/Dataview output.

## Technical Context

**Language/Version**: Swift 6.2
**Primary Dependencies**: AppKit (menu bar UI, date picker control), Foundation (date serialization)
**Storage**: Existing local markdown write flow in selected Obsidian directory (no data model storage change)
**Testing**: Existing unit/integration/contract test structure in `tests/` with new UI integration and formatter assertions
**Target Platform**: macOS 14+
**Project Type**: desktop-app
**Performance Goals**: date selection interaction under 1 second and no regression in task submission latency
**Constraints**: keep due date optional, keep output format unchanged, preserve existing error handling and destination validation
**Scale/Scope**: targeted UX enhancement to the Task modal only; no new user roles or sync behaviors

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- Security by default: PASS
  No new privilege scope; existing validation and fail-closed write path remain mandatory.
- macOS reliability: PASS
  Uses native AppKit date picker and keeps current menu bar interaction model.
- Test discipline: PASS
  Plan includes coverage for task submission with and without selected date.
- Data handling: PASS
  No extra data persisted beyond existing task content and optional due date.
- Complexity control: PASS
  Incremental UI change within current architecture; no additional subsystem.

### Post-Design Constitution Re-Check

- Security by default: PASS
- macOS reliability: PASS
- Test discipline: PASS
- Data handling: PASS
- Complexity control: PASS

## Project Structure

### Documentation (this feature)

```text
specs/002-task-date-picker/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   ├── task-input-ui.md
│   └── task-markdown-output.md
└── tasks.md
```

### Source Code (repository root)

```text
src/
├── app/
│   ├── StatusBarController.swift
│   ├── CaptureWindowController.swift
│   └── SettingsController.swift
├── services/
│   └── MarkdownFormatter.swift
└── domain/
    └── Validation.swift

tests/
├── unit/
│   └── MarkdownFormatterTests.swift
├── integration/
│   └── DailyNoteWriterIntegrationTests.swift
└── contract/
    └── MarkdownOutputContractTests.swift
```

**Structure Decision**: reuse existing structure and modify only task-related UI and
submission logic to minimize regression risk.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| None | N/A | N/A |
