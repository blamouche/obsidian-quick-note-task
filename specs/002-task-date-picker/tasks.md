# Tasks: Task Date Picker

**Input**: Design documents from `/specs/002-task-date-picker/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/

**Tests**: Include test tasks by default for critical user flows and all
security-relevant behavior.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and baseline alignment for the date picker enhancement

- [X] T001 Review current task capture flow and map impacted files in src/app/StatusBarController.swift and src/app/CaptureWindowController.swift
- [X] T002 Define date-picker interaction notes and expected states in specs/002-task-date-picker/contracts/task-input-ui.md
- [X] T003 [P] Add regression notes for markdown contract expectations in specs/002-task-date-picker/contracts/task-markdown-output.md
- [X] T004 [P] Prepare test case placeholders for date-picker scenarios in tests/unit/MarkdownFormatterTests.swift and tests/integration/DailyNoteWriterIntegrationTests.swift

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core prerequisites for safe date picker integration before user-story execution

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [X] T005 Implement shared task input state helper for optional due-date handling in src/domain/TaskEntry.swift
- [X] T006 Implement/adjust due-date normalization helper for UI-sourced date values in src/domain/Validation.swift
- [X] T007 Add date serialization guard for `YYYY-MM-DD` consistency in src/services/MarkdownFormatter.swift
- [X] T008 Ensure task submit pipeline accepts optional Date source without text parsing dependency in src/app/CaptureWindowController.swift
- [X] T009 [P] Add foundational unit tests for due-date optional/normalized paths in tests/unit/ValidationTests.swift
- [X] T010 [P] Add foundational contract tests for stable markdown output with/without due date in tests/contract/MarkdownOutputContractTests.swift

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - Sélectionner une date d'échéance via date picker (Priority: P1) 🎯 MVP

**Goal**: Provide a date picker in Task UI so users can select due date visually.

**Independent Test**: User enters title, selects date from picker, submits, and sees correctly dated task in the daily note.

### Tests for User Story 1 ⚠️

- [X] T011 [P] [US1] Add UI-flow oriented test case for task creation with selected due date in tests/integration/DailyNoteWriterIntegrationTests.swift
- [X] T012 [P] [US1] Add formatter assertion for task line including selected due date in tests/unit/MarkdownFormatterTests.swift
- [X] T013 [P] [US1] Add contract assertion for date-picker-sourced due date output in tests/contract/MarkdownOutputContractTests.swift

### Implementation for User Story 1

- [X] T014 [US1] Replace manual due-date text input with date picker control in task modal in src/app/StatusBarController.swift
- [X] T015 [US1] Wire selected date-picker value into task submission event in src/app/StatusBarController.swift
- [X] T016 [US1] Update task submit API usage to pass optional Date-derived value in src/app/CaptureWindowController.swift
- [X] T017 [US1] Keep success feedback path unchanged for dated task submissions in src/app/StatusBarController.swift

**Checkpoint**: User Story 1 should be fully functional and independently testable

---

## Phase 4: User Story 2 - Éviter les erreurs de saisie de date (Priority: P2)

**Goal**: Remove user-facing manual date format friction in Task flow.

**Independent Test**: User creates dated task without typing a date string and without format-related validation errors.

### Tests for User Story 2 ⚠️

- [X] T018 [P] [US2] Add negative regression test to ensure manual text-date validation path is no longer required for UI flow in tests/unit/ValidationTests.swift
- [X] T019 [P] [US2] Add integration test for changing selected date before submit in tests/integration/DailyNoteWriterIntegrationTests.swift
- [X] T020 [P] [US2] Add integration test for submitting task with no selected date in tests/integration/DailyNoteWriterIntegrationTests.swift

### Implementation for User Story 2

- [X] T021 [US2] Remove obsolete manual date-input handling from task dialog logic in src/app/StatusBarController.swift
- [X] T022 [US2] Ensure no format-error message is shown when using picker-only path in src/app/CaptureWindowController.swift
- [X] T023 [US2] Preserve explicit error handling for destination failures and draft retention in src/app/CaptureWindowController.swift

**Checkpoint**: User Stories 1 and 2 should both work independently

---

## Phase 5: User Story 3 - Conserver la compatibilité de sortie markdown (Priority: P2)

**Goal**: Maintain Tasks/Dataview compatibility after date picker integration.

**Independent Test**: Tasks created with and without date picker output remain readable and queryable as before.

### Tests for User Story 3 ⚠️

- [X] T024 [P] [US3] Add compatibility regression tests for `- [ ]` prefix persistence in tests/contract/MarkdownOutputContractTests.swift
- [X] T025 [P] [US3] Add compatibility regression tests for `📅 YYYY-MM-DD` serialization in tests/contract/MarkdownOutputContractTests.swift
- [X] T026 [P] [US3] Add integration test validating append behavior unchanged for dated tasks in tests/integration/DailyNoteWriterIntegrationTests.swift

### Implementation for User Story 3

- [X] T027 [US3] Verify and adjust task line rendering contract in src/services/MarkdownFormatter.swift
- [X] T028 [US3] Verify due-date optional behavior remains unchanged in src/services/DailyNoteWriter.swift
- [X] T029 [US3] Align task submission flow with markdown compatibility constraints in src/app/CaptureWindowController.swift

**Checkpoint**: All user stories should now be independently functional

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Final hardening, documentation, and execution validation

- [X] T030 [P] Update usage and validation steps for date picker task flow in specs/002-task-date-picker/quickstart.md
- [X] T031 Execute full relevant test suites and capture outcomes in specs/002-task-date-picker/quickstart.md
- [X] T032 [P] Update project-level notes for task date picker behavior in README.md
- [X] T033 [P] Run build validation after UI updates and note result in specs/002-task-date-picker/quickstart.md

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3+)**: Depend on Foundational completion
  - US1 first for MVP value
  - US2 and US3 follow after US1 wiring is stable
- **Polish (Phase 6)**: Depends on completion of targeted user stories

### User Story Dependencies

- **User Story 1 (P1)**: Depends on foundational due-date normalization and formatter guarantees
- **User Story 2 (P2)**: Depends on US1 date-picker UI wiring being in place
- **User Story 3 (P2)**: Depends on US1/US2 completion to validate compatibility regressions

### Within Each User Story

- Core tests MUST be written and fail before implementation tasks
- UI interaction wiring before behavior refinement
- Behavior refinement before compatibility stabilization

### Parallel Opportunities

- Phase 1 tasks T003-T004 can run in parallel
- Foundational tests T009-T010 can run in parallel
- US1 tests T011-T013 can run in parallel
- US2 tests T018-T020 can run in parallel
- US3 tests T024-T026 can run in parallel
- Polish tasks T030, T032, T033 can run in parallel

---

## Parallel Example: User Story 1

```bash
# Launch US1 tests in parallel:
Task: "T011 [US1] Add UI-flow test in tests/integration/DailyNoteWriterIntegrationTests.swift"
Task: "T012 [US1] Add formatter assertion in tests/unit/MarkdownFormatterTests.swift"
Task: "T013 [US1] Add contract assertion in tests/contract/MarkdownOutputContractTests.swift"

# Run implementation tasks touching different responsibilities:
Task: "T014 [US1] Replace due-date text input with date picker in src/app/StatusBarController.swift"
Task: "T016 [US1] Update submit API usage in src/app/CaptureWindowController.swift"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1 and Phase 2
2. Complete Phase 3 (US1)
3. Validate task creation with date picker and due date output
4. Demo MVP update

### Incremental Delivery

1. Deliver US1 (date picker available)
2. Deliver US2 (remove manual date friction)
3. Deliver US3 (compatibility hardening)
4. Run polish and regression validations

### Parallel Team Strategy

1. Developer A: UI wiring and capture flow (`src/app/*`)
2. Developer B: formatter and validation (`src/services/*`, `src/domain/*`)
3. Developer C: test updates (`tests/unit`, `tests/integration`, `tests/contract`)

---

## Notes

- [P] tasks are safe to parallelize when they do not change the same files.
- All user story tasks include `[USx]` labels for traceability.
- Every task references concrete file paths.
- Recommended MVP scope: Phase 1 + Phase 2 + Phase 3 (US1).
