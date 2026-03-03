# Tasks: UI Visual Refresh

**Input**: Design documents from `/specs/004-ui-visual-refresh/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/

**Tests**: Include test tasks for critical UI flows, visual-state signaling, and functional non-regression (capture/configuration/markdown).

**Organization**: Tasks are grouped by user story to enable independent implementation and testing.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Prepare visual refresh scaffolding and test placeholders.

- [X] T001 Review feature contracts and scenarios in specs/004-ui-visual-refresh/contracts/visual-presentation.md and specs/004-ui-visual-refresh/contracts/folder-affordance.md
- [X] T002 Create visual contract test scaffold in tests/contract/VisualPresentationContractTests.swift
- [X] T003 [P] Create folder affordance contract test scaffold in tests/contract/FolderAffordanceContractTests.swift
- [X] T004 [P] Create integration test scaffold for refreshed capture/settings windows in tests/integration/StatusBarControllerIntegrationTests.swift
- [X] T005 [P] Create unit test scaffold for reusable UI style tokens/helpers in tests/unit/UIStyleTests.swift

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Shared visual foundation required by all user stories.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

- [X] T006 Define reusable typography, spacing, and color-state style tokens in src/support/UIStyle.swift
- [X] T007 Integrate shared style token access in src/app/CaptureWindowController.swift
- [X] T008 [P] Integrate shared style token access in src/app/SettingsController.swift
- [X] T009 [P] Integrate shared style token access for menu/status visual states in src/app/StatusBarController.swift
- [X] T010 Ensure disabled-state rendering includes non-color cue support in src/app/StatusBarController.swift
- [X] T011 Add unit coverage for style token validity and role mapping in tests/unit/UIStyleTests.swift
- [X] T012 [P] Add contract assertions for visual state signaling baseline in tests/contract/VisualPresentationContractTests.swift

**Checkpoint**: Foundation ready - user story implementation can now begin.

---

## Phase 3: User Story 1 - Lecture et saisie plus agréables (Priority: P1) 🎯 MVP

**Goal**: Improve readability and typography hierarchy in quick capture windows without changing functional behavior.

**Independent Test**: Open Quick Note and Task windows and verify clear hierarchy (title/labels/inputs/actions), keyboard flow readability, and unchanged submit behavior.

### Tests for User Story 1 ⚠️

- [X] T013 [P] [US1] Add contract test for typography hierarchy consistency in tests/contract/VisualPresentationContractTests.swift
- [X] T014 [P] [US1] Add integration test for quick note readability and unchanged submit flow in tests/integration/StatusBarControllerIntegrationTests.swift
- [X] T015 [P] [US1] Add integration test for task readability and unchanged submit flow in tests/integration/StatusBarControllerIntegrationTests.swift

### Implementation for User Story 1

- [X] T016 [US1] Apply refreshed typography hierarchy to Quick Note window in src/app/CaptureWindowController.swift
- [X] T017 [US1] Apply refreshed typography hierarchy to Task window in src/app/CaptureWindowController.swift
- [X] T018 [US1] Harmonize input/control sizes and spacing for capture forms in src/app/CaptureWindowController.swift
- [X] T019 [US1] Preserve keyboard focus order and submission ergonomics after visual update in src/app/CaptureWindowController.swift

**Checkpoint**: User Story 1 is independently functional and testable.

---

## Phase 4: User Story 2 - Interface moderne et équilibrée (Priority: P1)

**Goal**: Deliver consistent spacing and modern color-state semantics across menu, capture, and settings surfaces.

**Independent Test**: Navigate menu + Quick Note + Task + settings, then verify consistent spacing rhythm and distinguishable states (active/disabled/success/error) with non-color cues preserved.

### Tests for User Story 2 ⚠️

- [X] T020 [P] [US2] Add contract test for spacing rhythm consistency across windows in tests/contract/VisualPresentationContractTests.swift
- [X] T021 [P] [US2] Add contract test for state signaling (active/disabled/success/error) in tests/contract/VisualPresentationContractTests.swift
- [X] T022 [P] [US2] Add integration test for disabled-state readability without color-only cues in tests/integration/StatusBarControllerIntegrationTests.swift
- [X] T023 [P] [US2] Add regression integration test for unchanged markdown output during refreshed UI flow in tests/integration/DailyNoteWriterIntegrationTests.swift

### Implementation for User Story 2

- [X] T024 [US2] Apply consistent spacing rhythm to menu/status UI sections in src/app/StatusBarController.swift
- [X] T025 [US2] Apply consistent spacing rhythm to settings window layout in src/app/SettingsController.swift
- [X] T026 [US2] Apply color-state roles for success/error/disabled feedback in src/app/StatusBarController.swift
- [X] T027 [US2] Align capture window feedback visual hierarchy with shared state roles in src/app/CaptureWindowController.swift
- [X] T028 [US2] Ensure visual refresh does not change markdown formatting behavior in src/services/MarkdownFormatter.swift

**Checkpoint**: User Stories 1 and 2 are independently functional.

---

## Phase 5: User Story 3 - Fenêtres de configuration visuellement épurées (Priority: P2)

**Goal**: Remove decorative folder icon from targeted windows while preserving explicit destination actions.

**Independent Test**: Open settings and capture-related folder access surfaces; confirm decorative folder icon is absent and destination action remains explicit and fully operational.

### Tests for User Story 3 ⚠️

- [X] T029 [P] [US3] Add folder-affordance contract test ensuring decorative icon is absent in tests/contract/FolderAffordanceContractTests.swift
- [X] T030 [P] [US3] Add integration test for settings destination action clarity without icon in tests/integration/StatusBarControllerIntegrationTests.swift
- [X] T031 [P] [US3] Add integration test for unchanged destination picker flow after icon removal in tests/integration/DestinationStoreIntegrationTests.swift

### Implementation for User Story 3

- [X] T032 [US3] Remove decorative folder icon from settings destination UI in src/app/SettingsController.swift
- [X] T033 [US3] Remove decorative folder icon from capture-related folder affordance in src/app/CaptureWindowController.swift
- [X] T034 [US3] Ensure textual affordance remains explicit for choose/change destination actions in src/app/SettingsController.swift and src/app/CaptureWindowController.swift

**Checkpoint**: All user stories are independently functional and testable.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Final verification, docs alignment, and regression hardening.

- [X] T035 [P] Update quickstart validation notes and expected outcomes in specs/004-ui-visual-refresh/quickstart.md
- [X] T036 [P] Record final design decisions and tradeoffs in specs/004-ui-visual-refresh/research.md
- [X] T037 Run full build/test validation and capture outcomes in specs/004-ui-visual-refresh/quickstart.md
- [X] T038 [P] Update user-facing documentation for refreshed visuals in README.md

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: no dependencies
- **Phase 2 (Foundational)**: depends on Phase 1 and blocks all stories
- **Phase 3-5 (User Stories)**: depend on Phase 2 completion
- **Phase 6 (Polish)**: depends on stories targeted for release

### User Story Dependencies

- **US1 (P1)**: starts after Foundational and delivers MVP readability value
- **US2 (P1)**: starts after Foundational; integrates with US1 styling but remains independently testable
- **US3 (P2)**: starts after Foundational; depends functionally on existing settings/capture surfaces and remains independently testable

### Within Each User Story

- Write tests first and ensure they fail before implementation
- Apply shared style primitives before screen-specific refinements
- Validate non-regression of capture/configuration flows before closing story

### Parallel Opportunities

- Setup: T003, T004, T005
- Foundational: T008, T009, T012
- US1 tests: T013, T014, T015
- US2 tests: T020, T021, T022, T023
- US3 tests: T029, T030, T031
- Polish/docs: T035, T036, T038

---

## Parallel Example: User Story 1

```bash
Task: "T013 [US1] Add contract test for typography hierarchy in tests/contract/VisualPresentationContractTests.swift"
Task: "T014 [US1] Add quick note readability integration test in tests/integration/StatusBarControllerIntegrationTests.swift"
```

## Parallel Example: User Story 2

```bash
Task: "T020 [US2] Add spacing rhythm contract test in tests/contract/VisualPresentationContractTests.swift"
Task: "T022 [US2] Add disabled-state readability integration test in tests/integration/StatusBarControllerIntegrationTests.swift"
```

## Parallel Example: User Story 3

```bash
Task: "T029 [US3] Add folder icon removal contract test in tests/contract/FolderAffordanceContractTests.swift"
Task: "T031 [US3] Add destination picker non-regression integration test in tests/integration/DestinationStoreIntegrationTests.swift"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1 and Phase 2
2. Complete Phase 3 (US1)
3. Validate readability and non-regression end-to-end
4. Demo/deploy MVP visual uplift

### Incremental Delivery

1. Deliver US1 (typography/readability)
2. Deliver US2 (spacing + color-state consistency)
3. Deliver US3 (folder icon removal + preserved affordance)
4. Execute polish tasks and full regression checks

### Parallel Team Strategy

1. Developer A: shared style system + capture window updates (`src/support/UIStyle.swift`, `src/app/CaptureWindowController.swift`)
2. Developer B: menu/settings visual state updates (`src/app/StatusBarController.swift`, `src/app/SettingsController.swift`)
3. Developer C: contracts/integration/unit tests (`tests/contract/`, `tests/integration/`, `tests/unit/`)

---

## Notes

- All tasks follow checklist format with IDs and concrete file paths.
- `[P]` tasks are parallel-safe only if no same-file conflict exists.
- Recommended MVP scope: Phase 1 + Phase 2 + Phase 3 (US1 only).
