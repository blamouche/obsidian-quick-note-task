# Tasks: Obsidian Menu Bar Capture

**Input**: Design documents from `/specs/001-menubar-obsidian-capture/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/

**Tests**: Include test tasks by default for critical user flows and all
security-relevant behavior.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [X] T001 Create initial source and test folders per plan in src/ and tests/
- [X] T002 Create app entrypoint and status bar bootstrap in src/app/StatusBarController.swift
- [X] T003 [P] Create shared date/provider and logger stubs in src/support/DateProvider.swift and src/support/Logger.swift
- [X] T004 [P] Create domain model stubs in src/domain/CaptureEntry.swift and src/domain/TaskEntry.swift
- [X] T005 Configure XCTest target layout and test file scaffolding in tests/unit/, tests/integration/, and tests/contract/

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [X] T006 Implement input validation rules (non-empty quick note/task title, due-date format) in src/domain/Validation.swift
- [X] T007 Implement destination folder persistence with bookmark data in src/services/DestinationStore.swift
- [X] T008 Implement daily note filename/date resolution (`YYYY-MM-DD - Note.md`) in src/services/DailyNotePathResolver.swift
- [X] T009 Implement markdown formatting core (separator + base renderers) in src/services/MarkdownFormatter.swift
- [X] T010 Implement append-only safe file writing with explicit error mapping in src/services/DailyNoteWriter.swift
- [X] T011 [P] Add unit tests for validation rules in tests/unit/ValidationTests.swift
- [X] T012 [P] Add unit tests for daily note path/date naming in tests/unit/DailyNotePathResolverTests.swift
- [X] T013 [P] Add contract tests for markdown compatibility rules in tests/contract/MarkdownOutputContractTests.swift

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - Ajouter une quick note (Priority: P1) 🎯 MVP

**Goal**: Capture a plain-text quick note from status bar and append it to daily note file.

**Independent Test**: User submits a non-empty quick note and sees it appended to today's file; empty quick note is rejected with explicit error.

### Tests for User Story 1 ⚠️

- [X] T014 [P] [US1] Add formatter tests for quick note output block in tests/unit/MarkdownFormatterTests.swift
- [X] T015 [P] [US1] Add integration test for creating missing daily file on first quick note in tests/integration/DailyNoteWriterIntegrationTests.swift
- [X] T016 [P] [US1] Add integration test for append-at-end behavior and separator insertion in tests/integration/DailyNoteWriterIntegrationTests.swift

### Implementation for User Story 1

- [X] T017 [US1] Implement quick note capture UI flow in src/app/CaptureWindowController.swift
- [X] T018 [US1] Wire quick note menu action from status item in src/app/StatusBarController.swift
- [X] T019 [US1] Implement quick note markdown rendering in src/services/MarkdownFormatter.swift
- [X] T020 [US1] Integrate quick note submit pipeline (validate -> resolve path -> append) in src/app/CaptureWindowController.swift
- [X] T021 [US1] Implement explicit UI error state for empty quick note and write failures in src/app/CaptureWindowController.swift

**Checkpoint**: User Story 1 should be fully functional and independently testable

---

## Phase 4: User Story 2 - Ajouter une task avec échéance optionnelle (Priority: P1)

**Goal**: Capture tasks from status bar in Tasks/Dataview-compatible format with optional due date.

**Independent Test**: User submits task with and without due date and both entries are appended in compatible markdown task format.

### Tests for User Story 2 ⚠️

- [X] T022 [P] [US2] Add formatter tests for task output with and without due date in tests/unit/MarkdownFormatterTests.swift
- [X] T023 [P] [US2] Add contract test for `- [ ]` prefix and due-date serialization in tests/contract/MarkdownOutputContractTests.swift
- [X] T024 [P] [US2] Add integration test for task append path from UI submission in tests/integration/DailyNoteWriterIntegrationTests.swift

### Implementation for User Story 2

- [X] T025 [US2] Implement task capture UI fields (title + optional due date) in src/app/CaptureWindowController.swift
- [X] T026 [US2] Wire task menu action from status item in src/app/StatusBarController.swift
- [X] T027 [US2] Implement task markdown formatting per contract in src/services/MarkdownFormatter.swift
- [X] T028 [US2] Integrate task submit pipeline and validation in src/app/CaptureWindowController.swift
- [X] T029 [US2] Implement explicit UI error state for empty title and invalid due date in src/app/CaptureWindowController.swift

**Checkpoint**: User Stories 1 and 2 should both work independently

---

## Phase 5: User Story 3 - Configurer le dossier cible Obsidian (Priority: P2)

**Goal**: Let user configure and persist destination folder used for all captures.

**Independent Test**: User selects destination folder, restarts app, and subsequent captures use the same folder.

### Tests for User Story 3 ⚠️

- [X] T030 [P] [US3] Add integration test for destination persistence across app restart simulation in tests/integration/DestinationStoreIntegrationTests.swift
- [X] T031 [P] [US3] Add integration test for inaccessible destination error handling in tests/integration/DestinationStoreIntegrationTests.swift

### Implementation for User Story 3

- [X] T032 [US3] Implement folder selection UI and save action in src/app/SettingsController.swift
- [X] T033 [US3] Integrate destination load at startup in src/app/StatusBarController.swift
- [X] T034 [US3] Enforce destination validation before any write in src/services/DailyNoteWriter.swift
- [X] T035 [US3] Implement retry-safe error UX preserving user input when destination is invalid in src/app/CaptureWindowController.swift

**Checkpoint**: All user stories should now be independently functional

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [X] T036 [P] Add end-to-end quickstart validation script notes in specs/001-menubar-obsidian-capture/quickstart.md
- [ ] T037 Run full test suite and stabilize flaky cases in tests/unit/, tests/integration/, and tests/contract/
- [X] T038 [P] Harden logging to avoid raw note/task content exposure in src/support/Logger.swift
- [X] T039 [P] Update user-facing usage notes and known error states in README.md

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3+)**: Depend on Foundational completion
  - US1 and US2 can proceed in parallel after Phase 2
  - US3 should start after T007/T033 interfaces are stable
- **Polish (Phase 6)**: Depends on completion of targeted user stories

### User Story Dependencies

- **User Story 1 (P1)**: Depends on foundational validation, path resolver, formatter, writer (T006-T010)
- **User Story 2 (P1)**: Depends on foundational validation and formatter (T006, T009, T010); independent from US1 business logic
- **User Story 3 (P2)**: Depends on destination persistence and app startup wiring (T007, T033)

### Within Each User Story

- Tests MUST be written and fail before implementation tasks
- Validation before formatting
- Formatting before writer integration
- UI wiring after service contracts are ready

### Parallel Opportunities

- Setup tasks T003-T004 can run in parallel
- Foundational tests T011-T013 can run in parallel
- US1 tests T014-T016 can run in parallel
- US2 tests T022-T024 can run in parallel
- US3 tests T030-T031 can run in parallel
- Polish tasks T036, T038, T039 can run in parallel

---

## Parallel Example: User Story 1

```bash
# Launch US1 tests together:
Task: "T014 [US1] Add formatter tests in tests/unit/MarkdownFormatterTests.swift"
Task: "T015 [US1] Add missing-file creation integration test in tests/integration/DailyNoteWriterIntegrationTests.swift"
Task: "T016 [US1] Add append/separator integration test in tests/integration/DailyNoteWriterIntegrationTests.swift"

# Launch service/UI tasks that don't touch the same file:
Task: "T019 [US1] Implement quick note markdown rendering in src/services/MarkdownFormatter.swift"
Task: "T018 [US1] Wire quick note action in src/app/StatusBarController.swift"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational
3. Complete Phase 3: User Story 1
4. Validate quick note capture end-to-end with file create/append behavior

### Incremental Delivery

1. Deliver US1 (quick note)
2. Deliver US2 (task formatting compatibility)
3. Deliver US3 (destination configuration persistence)
4. Finish with polish and full regression testing

### Parallel Team Strategy

1. Developer A: Foundational services (T006-T010)
2. Developer B: Test suites (T011-T016, T022-T024, T030-T031)
3. Developer C: UI controllers and wiring (T017-T018, T025-T026, T032-T035)

---

## Notes

- [P] tasks are safe to parallelize when they do not change the same files.
- All user story tasks include `[USx]` labels for traceability.
- Every task references a concrete file path.
- Recommended MVP scope: Phase 1 + Phase 2 + Phase 3 (US1 only).
