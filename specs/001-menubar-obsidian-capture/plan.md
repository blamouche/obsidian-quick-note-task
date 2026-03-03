# Implementation Plan: Obsidian Menu Bar Capture

**Branch**: `001-menubar-obsidian-capture` | **Date**: 2026-03-03 | **Spec**: [/Users/benoitlamouche/Documents/github/obsidian-quick-note-task/specs/001-menubar-obsidian-capture/spec.md](/Users/benoitlamouche/Documents/github/obsidian-quick-note-task/specs/001-menubar-obsidian-capture/spec.md)
**Input**: Feature specification from `/specs/001-menubar-obsidian-capture/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

Build a macOS status bar app that captures either quick notes or tasks and appends
content into the current daily markdown note in an Obsidian vault. The solution uses
strict input validation, deterministic markdown formatting compatible with Tasks and
Dataview, and safe file append behavior with explicit error feedback.

## Technical Context

**Language/Version**: Swift 5.10
**Primary Dependencies**: AppKit (status bar UI), Foundation (filesystem/date), UniformTypeIdentifiers (folder picker)
**Storage**: Local markdown files in user-selected Obsidian folder; persisted destination via user settings with bookmark support
**Testing**: XCTest (unit + integration), formatter snapshot-style assertions, file writer integration tests
**Target Platform**: macOS 14+ (Sonoma and newer)
**Project Type**: desktop-app
**Performance Goals**: open capture action from status item in <300ms; persist valid capture in <1s for 95% of operations
**Constraints**: local-first only; no network dependency; fail-safe writes; must preserve existing file content
**Scale/Scope**: single-user local utility app, expected dozens of captures per day

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- Security by default: PASS
  Input validation blocks empty content; path access restricted to selected folder;
  destination persistence uses system-protected bookmark data.
- macOS reliability: PASS
  Design is native status-bar-first and handles folder permission revocation.
- Test discipline: PASS
  Plan includes automated tests for formatter, file naming, append behavior, and
  failure paths.
- Data handling: PASS
  No network transfer; no raw content logging; only minimum metadata retained.
- Complexity control: PASS
  Single-process architecture and minimal components; no extra services added.

### Post-Design Constitution Re-Check

- Security by default: PASS
- macOS reliability: PASS
- Test discipline: PASS
- Data handling: PASS
- Complexity control: PASS

## Project Structure

### Documentation (this feature)

```text
specs/001-menubar-obsidian-capture/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   ├── capture-workflow.md
│   └── markdown-output.md
└── tasks.md
```

### Source Code (repository root)

```text
src/
├── app/
│   ├── StatusBarController.swift
│   ├── CaptureWindowController.swift
│   └── SettingsController.swift
├── domain/
│   ├── CaptureEntry.swift
│   ├── TaskEntry.swift
│   └── Validation.swift
├── services/
│   ├── DestinationStore.swift
│   ├── DailyNotePathResolver.swift
│   ├── MarkdownFormatter.swift
│   └── DailyNoteWriter.swift
└── support/
    ├── DateProvider.swift
    └── Logger.swift

tests/
├── unit/
│   ├── MarkdownFormatterTests.swift
│   ├── ValidationTests.swift
│   └── DailyNotePathResolverTests.swift
├── integration/
│   ├── DailyNoteWriterIntegrationTests.swift
│   └── DestinationStoreIntegrationTests.swift
└── contract/
    └── MarkdownOutputContractTests.swift
```

**Structure Decision**: single native macOS project with a small domain/services split.
This keeps UI isolated from formatting and file I/O, enabling strict testing and lower
regression risk.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| None | N/A | N/A |
