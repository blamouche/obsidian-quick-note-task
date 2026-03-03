# Quickstart: Task Date Picker

## Prerequisites
- Application builds and launches on macOS.
- Destination Obsidian folder already configured from Settings.

## Scenario 1: Add task with due date via date picker
1. Launch app and open menu bar icon.
2. Select `Task`.
3. Enter task title.
4. Select a due date using date picker.
5. Submit.
6. Verify today's note file contains task line with `📅 YYYY-MM-DD`.

## Scenario 2: Add task without due date
1. Open `Task` flow.
2. Enter task title.
3. Keep due date empty/disabled.
4. Submit.
5. Verify task line is added without date suffix.

## Scenario 3: Modify selected date before submit
1. Open `Task` flow.
2. Enter task title.
3. Select one date, then change it.
4. Submit.
5. Verify output uses final selected date.

## Regression checks
1. Quick Note flow still works unchanged.
2. Destination error still shows explicit message and preserves draft.
3. Existing task parsing in Obsidian remains functional.

## Validation commands
1. Run build validation:
   `swift build`
2. Run test validation:
   `swift test`

## Latest execution outcomes (2026-03-03)
- `swift build`: PASS
- `swift test`: FAIL in current environment due to missing `XCTest` module in
  active Swift toolchain (`no such module 'XCTest'`).
