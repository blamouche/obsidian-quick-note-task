# Quickstart: Today & Overdue Task Dropdown

## Prerequisites
- App builds and launches on macOS 14+.
- A local Obsidian vault is configured in Settings.
- Test vault contains markdown tasks with due dates and at least one recurring task.

## Scenario 1: Display only due-today/overdue uncompleted tasks
1. Prepare tasks in vault:
   - one overdue and unchecked
   - one due today and unchecked
   - one due in future and unchecked
   - one overdue but checked
2. Open the menu bar dropdown.
3. Verify task section appears between `Tasks` and `Configure settings`.
4. Verify only overdue + due today unchecked tasks are listed.

## Scenario 2: Exclusion filter in Settings
1. Open `Settings`.
2. Set exclusion text (example: `#snooze`).
3. Reopen dropdown.
4. Verify tasks containing `#snooze` are absent.
5. Clear exclusion text and verify those tasks appear again if otherwise eligible.

## Scenario 3: Check task from dropdown updates markdown
1. In dropdown, tick one visible task checkbox.
2. Verify the task line is marked completed in source markdown file.
3. Verify task disappears from dropdown after refresh.

## Scenario 4: Recurring task reprogramming
1. Ensure a visible task has a valid recurrence rule.
2. Tick task checkbox from dropdown.
3. Verify current occurrence is marked completed.
4. Verify a new occurrence is created with the next due date according to rule.

## Scenario 5: Error handling
1. Simulate source file write failure (e.g., file unavailable).
2. Tick a visible task.
3. Verify user sees an explicit error and task remains uncompleted in dropdown.
4. Simulate invalid recurrence rule on a recurring task.
5. Verify completion succeeds but recurrence warning is shown and no new occurrence is created.

## Validation Commands
1. Build:
   `swift build`
2. Tests:
   `swift test`

## Expected Test Focus
- Unit: date/status/exclusion filtering and recurrence parsing outcomes.
- Integration: markdown toggle write + dropdown refresh behavior.
- Contract: section placement in menu and user-visible result guarantees.

## Latest Execution Outcomes (2026-03-03)
- `swift build`: PASS
- `swift test`: FAIL in this environment because XCTest is unavailable in the active toolchain (`no such module 'XCTest'`).
