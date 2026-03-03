# Tasks: Today & Overdue Task Dropdown

**Input**: Design documents from `/specs/006-today-overdue-tasks/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/

**Tests**: Include test tasks by default for critical user flows and security-relevant behavior (input sanitization, vault-scope writes, write-failure handling).

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (`[US1]`, `[US2]`, `[US3]`, `[US4]`)
- Every task includes an exact file path

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Prepare fixtures and test scaffolding for dropdown-task workflows

- [X] T001 Create markdown fixture vault for due/overdue/recurring tasks in `tests/fixtures/vault_tasks/`
- [X] T002 [P] Add shared fixture loader helpers in `tests/support/TaskFixtures.swift`
- [X] T003 [P] Create contract test scaffold for dropdown tasks in `tests/contract/DropdownTasksContractTests.swift`
- [X] T004 [P] Create integration test scaffold for markdown sync flows in `tests/integration/TaskSyncIntegrationTests.swift`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core task-listing and safe-write primitives required by all user stories

**⚠️ CRITICAL**: No user story work should start before this phase is complete

- [X] T005 Define shared dropdown task entities and toggle result model in `src/domain/TaskListItem.swift`
- [X] T006 [P] Extend settings persistence with exclusion text state in `src/services/DestinationStore.swift`
- [X] T007 [P] Add safe markdown mutation helpers with vault-bound checks in `src/services/DailyNoteWriter.swift`
- [X] T008 Implement vault task scanning and source reference indexing service in `src/services/VaultTaskScanner.swift`
- [X] T009 Add validation and sanitization helpers for exclusion text and task source references in `src/domain/Validation.swift`
- [X] T010 Create baseline unit tests for scanner and settings persistence in `tests/unit/VaultTaskScannerTests.swift`

**Checkpoint**: Foundation ready - user story implementation can proceed

---

## Phase 3: User Story 1 - Voir les tâches à traiter immédiatement (Priority: P1) 🎯 MVP

**Goal**: Show only non-completed tasks due today or overdue in dropdown, positioned between `Tasks` and `Configure settings`

**Independent Test**: Open dropdown with mixed fixtures and verify only unchecked tasks with due date <= today appear in the expected section location.

### Tests for User Story 1

- [X] T011 [P] [US1] Add contract test for section placement and vault-gated visibility in `tests/contract/DropdownTasksContractTests.swift`
- [X] T012 [P] [US1] Add unit tests for unchecked + due<=today filtering in `tests/unit/VaultTaskScannerTests.swift`
- [X] T013 [P] [US1] Add integration test for dropdown rendering from fixture vault in `tests/integration/StatusBarControllerIntegrationTests.swift`

### Implementation for User Story 1

- [X] T014 [US1] Implement due<=today and unchecked filtering in `src/services/VaultTaskScanner.swift`
- [X] T015 [US1] Insert dropdown task section between existing menu items in `src/app/StatusBarController.swift`
- [X] T016 [US1] Refresh task section on menu open using current vault state in `src/app/StatusBarController.swift`
- [X] T017 [US1] Handle no-vault and empty-result states in `src/app/StatusBarController.swift`

**Checkpoint**: User Story 1 is independently functional and testable

---

## Phase 4: User Story 2 - Exclure certains contenus via Settings (Priority: P1)

**Goal**: Add configurable exclusion text in Settings and hide matching tasks from dropdown

**Independent Test**: Configure exclusion text, reopen dropdown, and verify matching tasks are removed while other eligible tasks remain.

### Tests for User Story 2

- [X] T018 [P] [US2] Add unit tests for exclusion text sanitization and matching rules in `tests/unit/SettingsControllerTests.swift`
- [X] T019 [P] [US2] Add integration test for exclusion setting impact on dropdown list in `tests/integration/StatusBarControllerIntegrationTests.swift`

### Implementation for User Story 2

- [X] T020 [US2] Add exclusion text input and persistence wiring in `src/app/SettingsController.swift`
- [X] T021 [US2] Apply exclusion filter to eligible tasks in `src/services/VaultTaskScanner.swift`
- [X] T022 [US2] Trigger dropdown task-list reload after exclusion setting changes in `src/app/StatusBarController.swift`
- [X] T023 [US2] Enforce fail-closed handling for unsafe exclusion input in `src/domain/Validation.swift`

**Checkpoint**: User Story 2 is independently functional and testable

---

## Phase 5: User Story 3 - Cocher une tâche depuis la dropdown (Priority: P2)

**Goal**: Let user check a task from dropdown and synchronize completion state to source markdown

**Independent Test**: Check one dropdown task, confirm markdown source is updated, and verify task disappears after refresh; simulate write failure and verify rollback message.

### Tests for User Story 3

- [X] T024 [P] [US3] Add contract test for checkbox toggle success/failure guarantees in `tests/contract/DropdownTasksContractTests.swift`
- [X] T025 [P] [US3] Add integration test for checkbox-to-markdown completion sync in `tests/integration/TaskSyncIntegrationTests.swift`
- [X] T026 [P] [US3] Add integration negative test for write-failure rollback behavior in `tests/integration/TaskSyncIntegrationTests.swift`

### Implementation for User Story 3

- [X] T027 [US3] Render task checkboxes and callback actions in dropdown menu in `src/app/StatusBarController.swift`
- [X] T028 [US3] Implement source-targeted task completion writes in `src/services/TaskToggleService.swift`
- [X] T029 [US3] Enforce vault-scope path guards for toggle writes in `src/services/TaskToggleService.swift`
- [X] T030 [US3] Surface success/error feedback and post-toggle refresh in `src/app/StatusBarController.swift`

**Checkpoint**: User Story 3 is independently functional and testable

---

## Phase 6: User Story 4 - Replanifier les tâches récurrentes (Priority: P2)

**Goal**: Reprogram recurring tasks on successful completion according to recurrence rule

**Independent Test**: Check recurring task, verify completion plus newly scheduled occurrence; with invalid rule, verify completion remains and warning is shown.

### Tests for User Story 4

- [X] T031 [P] [US4] Add unit tests for recurrence parsing and next-date computation in `tests/unit/MarkdownFormatterTests.swift`
- [X] T032 [P] [US4] Add integration test for recurring completion and next occurrence creation in `tests/integration/TaskSyncIntegrationTests.swift`
- [X] T033 [P] [US4] Add integration test for invalid recurrence warning path in `tests/integration/TaskSyncIntegrationTests.swift`

### Implementation for User Story 4

- [X] T034 [US4] Extend recurrence descriptor extraction during scan in `src/services/VaultTaskScanner.swift`
- [X] T035 [US4] Implement recurrence reprogramming flow after successful toggle in `src/services/TaskToggleService.swift`
- [X] T036 [US4] Add invalid-recurrence warning feedback in `src/app/StatusBarController.swift`

**Checkpoint**: User Story 4 is independently functional and testable

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Hardening, documentation, and full validation across stories

- [X] T037 [P] Update behavior and configuration documentation in `README.md`
- [X] T038 Run quickstart validation scenarios and record outcomes in `specs/006-today-overdue-tasks/quickstart.md`
- [ ] T039 [P] Run full test suite and stabilize contract ordering expectations in `tests/contract/DropdownTasksContractTests.swift`
- [X] T040 Review and harden task-content logging redaction in `src/support/Logger.swift`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: no dependencies
- **Phase 2 (Foundational)**: depends on Phase 1 and blocks all user stories
- **Phase 3-6 (User Stories)**: depend on Phase 2
- **Phase 7 (Polish)**: depends on completion of target user stories

### User Story Dependencies

- **US1 (P1)**: starts after Phase 2; no dependency on other stories
- **US2 (P1)**: starts after Phase 2; can run in parallel with US1
- **US3 (P2)**: starts after Phase 2; depends functionally on shared scanner/indexing from foundation
- **US4 (P2)**: starts after Phase 2; builds on US3 toggle pipeline

### Within Each User Story

- Tests first, then implementation
- Service/domain changes before controller wiring
- Complete story behavior and validation before moving to next checkpoint

### Parallel Opportunities

- Setup tasks marked `[P]` can run concurrently
- Foundational tasks `T006` and `T007` can run concurrently
- After Phase 2, US1 and US2 can run concurrently
- In each story, tasks marked `[P]` can run concurrently

---

## Parallel Example: User Story 1

```bash
Task: "T011 [US1] contract placement test in tests/contract/DropdownTasksContractTests.swift"
Task: "T012 [US1] unit filtering tests in tests/unit/VaultTaskScannerTests.swift"
Task: "T013 [US1] integration dropdown rendering test in tests/integration/StatusBarControllerIntegrationTests.swift"
```

## Parallel Example: User Story 2

```bash
Task: "T018 [US2] exclusion sanitization tests in tests/unit/SettingsControllerTests.swift"
Task: "T019 [US2] exclusion integration test in tests/integration/StatusBarControllerIntegrationTests.swift"
```

## Parallel Example: User Story 3

```bash
Task: "T024 [US3] contract toggle guarantees in tests/contract/DropdownTasksContractTests.swift"
Task: "T025 [US3] integration toggle sync in tests/integration/TaskSyncIntegrationTests.swift"
Task: "T026 [US3] integration write-failure rollback in tests/integration/TaskSyncIntegrationTests.swift"
```

## Parallel Example: User Story 4

```bash
Task: "T031 [US4] recurrence unit tests in tests/unit/MarkdownFormatterTests.swift"
Task: "T032 [US4] integration recurring reprogramming in tests/integration/TaskSyncIntegrationTests.swift"
Task: "T033 [US4] integration invalid recurrence warning in tests/integration/TaskSyncIntegrationTests.swift"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1 and Phase 2.
2. Complete Phase 3 (US1).
3. Validate US1 independently against spec scenarios.
4. Demo/deploy MVP increment.

### Incremental Delivery

1. Deliver US1 (core listing value).
2. Deliver US2 (signal/noise control).
3. Deliver US3 (completion from dropdown).
4. Deliver US4 (recurrence continuity).
5. Finish Phase 7 polish and regression validation.

### Parallel Team Strategy

1. Team aligns on Phase 1-2 foundation.
2. Then split:
   - Dev A: US1
   - Dev B: US2
3. After US1/US2 merge:
   - Dev A/B: US3 and US4 pipeline

---

## Notes

- `[P]` means no dependency on incomplete tasks and no same-file conflict expected.
- `[USx]` labels ensure story traceability and independent validation.
- All tasks follow required checklist format with Task ID and file path.
