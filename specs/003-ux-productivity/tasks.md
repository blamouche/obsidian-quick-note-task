# Tasks: UX Productivity Flow

**Input**: Design documents from `/specs/003-ux-productivity/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/

**Tests**: Include test tasks by default for critical user flows and security-relevant behavior (disabled actions, invalid destination, input validation, draft preservation).

**Organization**: Tasks are grouped by user story to enable independent implementation and testing.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Align current codebase and test scaffolding for UX-state-driven behavior.

- [X] T001 Review impacted UX contracts and scenarios in specs/003-ux-productivity/contracts/menu-availability.md and specs/003-ux-productivity/contracts/capture-feedback.md
- [X] T002 Create contract test scaffolding for menu availability and feedback rules in tests/contract/MenuAvailabilityContractTests.swift and tests/contract/CaptureFeedbackContractTests.swift
- [X] T003 [P] Add integration test scaffolding for first-run and reconfiguration flows in tests/integration/StatusBarControllerIntegrationTests.swift
- [X] T004 [P] Add unit test scaffolding for configuration state mapping in tests/unit/SettingsControllerTests.swift and tests/unit/CaptureWindowControllerTests.swift

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core readiness and fail-closed foundations required by all user stories.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

- [X] T005 Implement destination readiness evaluation API in src/app/SettingsController.swift
- [X] T006 Implement capture availability state helper (enabled/disabled + reason) in src/app/StatusBarController.swift
- [X] T007 Implement centralized blocked-action feedback helper for missing/invalid destination in src/app/StatusBarController.swift
- [X] T008 Harden empty/whitespace validation messaging for quick note and task titles in src/domain/Validation.swift
- [X] T009 Ensure submit pipeline preserves draft consistently on all write/validation failures in src/app/CaptureWindowController.swift
- [X] T010 [P] Add unit coverage for readiness evaluation and disabled-reason mapping in tests/unit/SettingsControllerTests.swift
- [X] T011 [P] Add unit coverage for validation and preserved-draft behavior in tests/unit/ValidationTests.swift and tests/unit/CaptureWindowControllerTests.swift
- [X] T012 [P] Add contract assertions for blocked behavior when destination is unavailable in tests/contract/MenuAvailabilityContractTests.swift and tests/contract/CaptureFeedbackContractTests.swift

**Checkpoint**: Foundation ready - user story implementation can now begin.

---

## Phase 3: User Story 1 - Capturer immédiatement après configuration (Priority: P1) 🎯 MVP

**Goal**: Enforce configuration-first UX with clear setup path and disabled capture actions until destination is valid.

**Independent Test**: On first run, menu shows capture actions disabled and setup action highlighted; after choosing valid folder, capture actions become enabled without restart.

### Tests for User Story 1 ⚠️

- [X] T013 [P] [US1] Add integration test for first-run disabled menu state in tests/integration/StatusBarControllerIntegrationTests.swift
- [X] T014 [P] [US1] Add integration test for enablement transition immediately after successful settings selection in tests/integration/StatusBarControllerIntegrationTests.swift
- [X] T015 [P] [US1] Add contract test for keyboard shortcut blocking when actions are disabled in tests/contract/MenuAvailabilityContractTests.swift

### Implementation for User Story 1

- [X] T016 [US1] Update menu construction to reflect dynamic enabled/disabled state for `Quick Note` and `Task` in src/app/StatusBarController.swift
- [X] T017 [US1] Add explicit first-run setup guidance message in menu/status flow in src/app/StatusBarController.swift
- [X] T018 [US1] Wire settings success callback to immediate menu state refresh in src/app/StatusBarController.swift
- [X] T019 [US1] Ensure disabled menu actions never call capture submission methods in src/app/StatusBarController.swift

**Checkpoint**: User Story 1 is independently functional and testable.

---

## Phase 4: User Story 2 - Ajouter une note ou une task avec un minimum d'interactions (Priority: P1)

**Goal**: Keep capture flow short and productive once app is configured.

**Independent Test**: With valid destination, user can add quick note and task in short flows; success feedback is concise and write behavior remains unchanged.

### Tests for User Story 2 ⚠️

- [X] T020 [P] [US2] Add integration test for quick note successful submission path with configured destination in tests/integration/DailyNoteWriterIntegrationTests.swift
- [X] T021 [P] [US2] Add integration test for task successful submission path with optional due date in tests/integration/DailyNoteWriterIntegrationTests.swift
- [X] T022 [P] [US2] Add contract test for success feedback payload containing output file context in tests/contract/CaptureFeedbackContractTests.swift

### Implementation for User Story 2

- [X] T023 [US2] Optimize quick note dialog flow to avoid extra pre-submit steps in src/app/StatusBarController.swift
- [X] T024 [US2] Optimize task dialog flow while keeping title required and due date optional in src/app/StatusBarController.swift
- [X] T025 [US2] Standardize concise success feedback messaging for note/task capture in src/app/StatusBarController.swift
- [X] T026 [US2] Preserve existing markdown output behavior while routing through updated UX flow in src/app/CaptureWindowController.swift and src/services/MarkdownFormatter.swift

**Checkpoint**: User Stories 1 and 2 are both independently functional.

---

## Phase 5: User Story 3 - Comprendre l'état de l'application en un coup d'oeil (Priority: P2)

**Goal**: Show clear global app state (ready, setup required, error/recovery) with actionable guidance.

**Independent Test**: User can distinguish not configured, ready, and invalid destination/error states from menu feedback and recover through settings action.

### Tests for User Story 3 ⚠️

- [X] T027 [P] [US3] Add integration test for invalid destination transition after prior valid setup in tests/integration/StatusBarControllerIntegrationTests.swift
- [X] T028 [P] [US3] Add contract test for required message variants (setup required, ready, recovery needed) in tests/contract/MenuAvailabilityContractTests.swift
- [X] T029 [P] [US3] Add integration test for actionable error feedback and retry with preserved draft in tests/integration/StatusBarControllerIntegrationTests.swift

### Implementation for User Story 3

- [X] T030 [US3] Implement explicit status messaging model for ready/setup/error states in src/app/StatusBarController.swift
- [X] T031 [US3] Route write and validation failures to actionable feedback with recovery hints in src/app/StatusBarController.swift
- [X] T032 [US3] Ensure settings/reconfiguration path is available from every blocked/error state in src/app/StatusBarController.swift
- [X] T033 [US3] Redact note/task raw content from operational logs in failure/success paths in src/support/Logger.swift and src/app/CaptureWindowController.swift

**Checkpoint**: All user stories are independently functional and testable.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Final hardening, docs updates, and regression validation.

- [X] T034 [P] Update UX validation scenarios and expected outcomes in specs/003-ux-productivity/quickstart.md
- [X] T035 [P] Update feature documentation references in specs/003-ux-productivity/plan.md and specs/003-ux-productivity/research.md after implementation decisions finalize
- [X] T036 Run full build/test validation and record outcomes in specs/003-ux-productivity/quickstart.md
- [X] T037 [P] Update product-level usage notes for configuration-first UX in README.md

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: no dependencies
- **Phase 2 (Foundational)**: depends on Phase 1 and blocks all stories
- **Phase 3-5 (User Stories)**: depend on Phase 2 completion
- **Phase 6 (Polish)**: depends on stories targeted for release

### User Story Dependencies

- **US1 (P1)**: starts right after Foundational; no dependency on US2/US3
- **US2 (P1)**: depends on US1 menu-gating behavior being in place, then independently testable for fast capture
- **US3 (P2)**: depends on US1 and US2 feedback wiring to present final status model consistently

### Within Each User Story

- Write tests first and ensure they fail before implementation
- Implement state/behavior changes before UI messaging refinements
- Complete story-level regression checks before starting next story

### Parallel Opportunities

- Setup: T003 and T004
- Foundational: T010, T011, T012
- US1 tests: T013, T014, T015
- US2 tests: T020, T021, T022
- US3 tests: T027, T028, T029
- Polish/docs: T034, T035, T037

---

## Parallel Example: User Story 1

```bash
Task: "T013 [US1] Add first-run disabled menu integration test in tests/integration/StatusBarControllerIntegrationTests.swift"
Task: "T015 [US1] Add disabled-shortcut contract test in tests/contract/MenuAvailabilityContractTests.swift"
```

## Parallel Example: User Story 2

```bash
Task: "T020 [US2] Add quick note success integration test in tests/integration/DailyNoteWriterIntegrationTests.swift"
Task: "T022 [US2] Add success feedback contract test in tests/contract/CaptureFeedbackContractTests.swift"
```

## Parallel Example: User Story 3

```bash
Task: "T027 [US3] Add invalid-destination transition integration test in tests/integration/StatusBarControllerIntegrationTests.swift"
Task: "T028 [US3] Add status message contract variants test in tests/contract/MenuAvailabilityContractTests.swift"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1 and Phase 2
2. Complete Phase 3 (US1)
3. Validate first-run setup gating end-to-end
4. Demo/deploy MVP UX safety behavior

### Incremental Delivery

1. Deliver US1 (configuration-first gating)
2. Deliver US2 (fast capture flows)
3. Deliver US3 (global state clarity and recovery messaging)
4. Execute polish tasks and full regression checks

### Parallel Team Strategy

1. Developer A: menu state + setup gating in src/app/StatusBarController.swift
2. Developer B: capture/validation behavior in src/app/CaptureWindowController.swift and src/domain/Validation.swift
3. Developer C: tests across tests/contract/, tests/integration/, and tests/unit/

---

## Notes

- All tasks follow required checklist format with IDs and concrete paths.
- `[P]` tasks are parallel-safe only when no same-file conflict exists.
- Recommended MVP scope: Phase 1 + Phase 2 + Phase 3 (US1 only).
