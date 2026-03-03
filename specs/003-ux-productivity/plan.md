# Implementation Plan: UX Productivity Flow

**Branch**: `003-ux-productivity` | **Date**: 2026-03-03 | **Spec**: [/Users/benoitlamouche/Documents/github/obsidian-quick-note-task/specs/003-ux-productivity/spec.md](/Users/benoitlamouche/Documents/github/obsidian-quick-note-task/specs/003-ux-productivity/spec.md)
**Input**: Feature specification from `/specs/003-ux-productivity/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

Improve the menu bar UX for productivity by enforcing configuration-first behavior,
disabling unavailable capture actions until destination setup is valid, reducing
interaction steps for repeated captures, and providing immediate, actionable
feedback for ready/error states without changing markdown output semantics.

## Technical Context

**Language/Version**: Swift 6.2  
**Primary Dependencies**: AppKit (menu/status UX), Foundation (filesystem/date), existing domain/services modules  
**Storage**: Local filesystem in user-selected Obsidian vault (existing markdown append flow)  
**Testing**: Existing `tests/unit`, `tests/integration`, `tests/contract` suites with added menu-state and validation coverage  
**Target Platform**: macOS 14+  
**Project Type**: desktop-app  
**Performance Goals**: app readiness state visible at menu open; no noticeable latency regression in note/task submission  
**Constraints**: fail-closed when destination is missing/inaccessible; preserve existing note/task markdown format; keep flows offline and local-only  
**Scale/Scope**: UX-only improvement on setup/status/capture flows; no new sync, storage backend, or account model

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- Security by default: input validation, secret handling, dependency risk review
  explicitly addressed.
- macOS reliability: target macOS version, permissions, filesystem/path
  behavior, and `zsh` compatibility documented.
- Test discipline: automated tests defined for critical flows and
  security-relevant failures.
- Data handling: least-privilege scope and logging redaction plan documented.
- Complexity control: any added complexity justified in "Complexity Tracking".

- Security by default: PASS
  No new secret surface; capture remains blocked when destination is invalid.
- macOS reliability: PASS
  Native menu/app flows retained with dynamic state updates for destination validity.
- Test discipline: PASS
  Plan includes tests for disabled actions, setup gating, and error-path messaging.
- Data handling: PASS
  No additional persisted user data; log output must avoid note content.
- Complexity control: PASS
  Changes remain in existing controllers/services with no extra subsystem.

### Post-Design Constitution Re-Check

- Security by default: PASS
- macOS reliability: PASS
- Test discipline: PASS
- Data handling: PASS
- Complexity control: PASS

## Project Structure

### Documentation (this feature)

```text
specs/003-ux-productivity/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   ├── menu-availability.md
│   └── capture-feedback.md
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
│   ├── Validation.swift
│   ├── CaptureEntry.swift
│   └── TaskEntry.swift
├── services/
│   ├── DestinationStore.swift
│   └── DailyNoteWriter.swift
└── support/
    └── Logger.swift

tests/
├── unit/
│   ├── ValidationTests.swift
│   ├── SettingsControllerTests.swift
│   └── CaptureWindowControllerTests.swift
├── integration/
│   ├── DestinationStoreIntegrationTests.swift
│   ├── DailyNoteWriterIntegrationTests.swift
│   └── StatusBarControllerIntegrationTests.swift
└── contract/
    ├── MarkdownOutputContractTests.swift
    ├── MenuAvailabilityContractTests.swift
    └── CaptureFeedbackContractTests.swift
```

**Structure Decision**: keep the existing single-project Swift package layout and
implement UX state orchestration in current app controllers to minimize risk.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| None | N/A | N/A |
