# Tasks: Settings Window Configuration Split

**Input**: Design documents from `/specs/005-settings-vault-default-folder/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/

**Tests**: Include test tasks for critical configuration flows, capture gating, and destination non-regression.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Prepare test scaffolding and align feature contracts with existing code structure.

- [X] T001 Review feature docs in specs/005-settings-vault-default-folder/spec.md and specs/005-settings-vault-default-folder/plan.md
- [X] T002 Create settings-window contract test scaffold in tests/contract/SettingsWindowConfigurationContractTests.swift
- [X] T003 [P] Create settings-gating contract test scaffold in tests/contract/SettingsValidationGatingContractTests.swift
- [X] T004 [P] Extend integration test scaffold for settings/capture flow in tests/integration/StatusBarControllerIntegrationTests.swift
- [X] T005 [P] Add settings persistence unit test scaffold in tests/unit/SettingsControllerTests.swift

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core configuration state and validation infrastructure used by all user stories.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

- [X] T006 Add explicit vault configuration persistence API in src/services/DestinationStore.swift
- [X] T007 Add explicit default-folder configuration persistence API in src/services/DestinationStore.swift
- [X] T008 [P] Add vault/folder coherence validation helpers in src/domain/Validation.swift
- [X] T009 Define settings window aggregate state mapping (valid/invalidVault/invalidFolder/invalidBoth) in src/app/SettingsController.swift
- [X] T010 [P] Wire capture eligibility derivation from settings state in src/app/StatusBarController.swift
- [X] T011 Add unit tests for vault/folder validation matrix in tests/unit/ValidationTests.swift
- [X] T012 [P] Add integration test for capture gating refresh without restart in tests/integration/StatusBarControllerIntegrationTests.swift

**Checkpoint**: Foundation ready - user story implementation can now begin.

---

## Phase 3: User Story 1 - Configurer le vault Obsidian local (Priority: P1) 🎯 MVP

**Goal**: Allow explicit local Obsidian vault selection in Settings and persist it across app sessions.

**Independent Test**: Open Settings, select a valid vault, reopen Settings, and verify the selected vault remains active.

### Tests for User Story 1 ⚠️

- [X] T013 [P] [US1] Add contract test for vault selector presence and persisted display in tests/contract/SettingsWindowConfigurationContractTests.swift
- [X] T014 [P] [US1] Add unit tests for vault path save/load behavior in tests/unit/SettingsControllerTests.swift
- [X] T015 [P] [US1] Add integration test for canceling vault picker preserving prior state in tests/integration/StatusBarControllerIntegrationTests.swift

### Implementation for User Story 1

- [X] T016 [US1] Add vault selection UI section in settings window layout in src/app/SettingsController.swift
- [X] T017 [US1] Implement vault picker action and selection handling in src/app/SettingsController.swift
- [X] T018 [US1] Persist selected vault path through destination store in src/services/DestinationStore.swift
- [X] T019 [US1] Restore configured vault value when settings window opens in src/app/SettingsController.swift
- [X] T020 [US1] Surface invalid vault state message in settings window in src/app/SettingsController.swift

**Checkpoint**: User Story 1 is independently functional and testable.

---

## Phase 4: User Story 2 - Définir le dossier par défaut des notes (Priority: P1)

**Goal**: Allow default note folder selection in Settings and use it for subsequent Quick Note/Task captures.

**Independent Test**: Change default folder in Settings, create a quick note/task, and verify output is written to that folder.

### Tests for User Story 2 ⚠️

- [X] T021 [P] [US2] Add contract test for default-folder selector presence and persistence in tests/contract/SettingsWindowConfigurationContractTests.swift
- [X] T022 [P] [US2] Add contract test for invalid default-folder gating behavior in tests/contract/SettingsValidationGatingContractTests.swift
- [X] T023 [P] [US2] Add integration test for quick note write location using selected default folder in tests/integration/DailyNoteWriterIntegrationTests.swift
- [X] T024 [P] [US2] Add integration test for task write location using selected default folder in tests/integration/DailyNoteWriterIntegrationTests.swift

### Implementation for User Story 2

- [X] T025 [US2] Add default-folder UI section and current value display in src/app/SettingsController.swift
- [X] T026 [US2] Implement default-folder picker action and selection handling in src/app/SettingsController.swift
- [X] T027 [US2] Persist default-folder path using existing destination mechanism in src/services/DestinationStore.swift
- [X] T028 [US2] Enforce folder-inside-vault validation before enabling capture in src/domain/Validation.swift
- [X] T029 [US2] Use configured default folder for capture path resolution in src/services/DailyNotePathResolver.swift
- [X] T030 [US2] Keep markdown formatting unchanged while switching destination folder in src/services/MarkdownFormatter.swift

**Checkpoint**: User Stories 1 and 2 are independently functional.

---

## Phase 5: User Story 3 - Gérer les deux configurations dans une seule fenêtre (Priority: P2)

**Goal**: Deliver a single Settings window containing exactly two independent configuration sections and consistent global status.

**Independent Test**: Open Settings and verify both sections are visible and editable independently; changing one must not overwrite the other.

### Tests for User Story 3 ⚠️

- [X] T031 [P] [US3] Add contract test asserting exactly two configuration sections in settings window in tests/contract/SettingsWindowConfigurationContractTests.swift
- [X] T032 [P] [US3] Add contract test for independent update behavior (vault does not overwrite folder, folder does not overwrite vault) in tests/contract/SettingsWindowConfigurationContractTests.swift
- [X] T033 [P] [US3] Add integration test for mixed invalid state disabling capture actions in tests/contract/SettingsValidationGatingContractTests.swift

### Implementation for User Story 3

- [X] T034 [US3] Refactor settings window composition to render exactly two sections in src/app/SettingsController.swift
- [X] T035 [US3] Ensure vault update path does not mutate default-folder value implicitly in src/app/SettingsController.swift
- [X] T036 [US3] Ensure default-folder update path does not mutate vault value implicitly in src/app/SettingsController.swift
- [X] T037 [US3] Propagate unified settings validity status to menu availability state in src/app/StatusBarController.swift
- [X] T038 [US3] Ensure settings recovery action is explicit when captures are blocked in src/app/StatusBarController.swift

**Checkpoint**: All user stories are independently functional and testable.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Final regression pass, documentation updates, and quickstart verification.

- [X] T039 [P] Update feature quickstart validation notes in specs/005-settings-vault-default-folder/quickstart.md
- [X] T040 [P] Record final implementation decisions and tradeoffs in specs/005-settings-vault-default-folder/research.md
- [X] T041 [P] Update user-facing configuration guidance in README.md
- [X] T042 Run full build/test validation and capture outcomes in specs/005-settings-vault-default-folder/quickstart.md

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: no dependencies
- **Phase 2 (Foundational)**: depends on Phase 1 and blocks all user stories
- **Phase 3-5 (User Stories)**: depend on Phase 2 completion
- **Phase 6 (Polish)**: depends on all targeted stories being complete

### User Story Dependencies

- **US1 (P1)**: can start after Foundational and delivers MVP value
- **US2 (P1)**: can start after Foundational; functionally complements US1 but remains independently testable
- **US3 (P2)**: can start after Foundational; validates consolidated settings behavior across US1/US2

### Within Each User Story

- Write tests first and ensure they fail before implementation
- Implement UI/actions before persistence wiring only when state model is already stable
- Validate capture non-regression before closing the story

### Parallel Opportunities

- Setup: T003, T004, T005
- Foundational: T008, T010, T012
- US1 tests: T013, T014, T015
- US2 tests: T021, T022, T023, T024
- US3 tests: T031, T032, T033
- Polish/docs: T039, T040, T041

---

## Parallel Example: User Story 1

```bash
Task: "T013 [US1] Add vault selector contract test in tests/contract/SettingsWindowConfigurationContractTests.swift"
Task: "T014 [US1] Add vault persistence unit tests in tests/unit/SettingsControllerTests.swift"
```

## Parallel Example: User Story 2

```bash
Task: "T022 [US2] Add invalid default-folder gating contract test in tests/contract/SettingsValidationGatingContractTests.swift"
Task: "T023 [US2] Add quick note destination integration test in tests/integration/DailyNoteWriterIntegrationTests.swift"
```

## Parallel Example: User Story 3

```bash
Task: "T031 [US3] Add exact-two-sections contract test in tests/contract/SettingsWindowConfigurationContractTests.swift"
Task: "T033 [US3] Add mixed-invalid-state gating test in tests/contract/SettingsValidationGatingContractTests.swift"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1 and Phase 2
2. Complete Phase 3 (US1)
3. Validate vault selection persistence end-to-end
4. Demo/deploy MVP

### Incremental Delivery

1. Deliver US1 (vault selection + persistence)
2. Deliver US2 (default folder selection + capture destination)
3. Deliver US3 (single window with strict two-section independence)
4. Execute polish and full regression checks

### Parallel Team Strategy

1. Developer A: Settings UI and interaction flow (`src/app/SettingsController.swift`)
2. Developer B: Persistence/validation/path resolution (`src/services/DestinationStore.swift`, `src/domain/Validation.swift`, `src/services/DailyNotePathResolver.swift`)
3. Developer C: Contracts and integration/unit tests (`tests/contract/`, `tests/integration/`, `tests/unit/`)

---

## Notes

- All tasks follow checklist format with IDs and concrete file paths.
- `[P]` tasks are parallel-safe only if no same-file conflict exists.
- Recommended MVP scope: Phase 1 + Phase 2 + Phase 3 (US1 only).
