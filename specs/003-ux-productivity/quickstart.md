# Quickstart: UX Productivity Flow

## Prerequisites
- App builds and launches on macOS.
- No destination configured (for first-run scenarios).

## Scenario 1: First run with configuration-first guidance
1. Launch app and open the menu bar icon.
2. Verify `Quick Note` and `Task` are disabled.
3. Select setup action from menu and choose a valid Obsidian folder.
4. Re-open menu and verify capture actions are now enabled.

## Scenario 2: Fast quick note capture after setup
1. Open menu and select `Quick Note`.
2. Enter note content.
3. Submit.
4. Verify success feedback and appended content in daily note file.

## Scenario 3: Fast task capture with optional due date
1. Open menu and select `Task`.
2. Enter title.
3. Optionally enable/select due date.
4. Submit and verify success feedback and correct markdown output.

## Scenario 4: Recovery from invalid destination
1. Configure destination, then make it inaccessible (rename/remove folder).
2. Open menu and verify capture actions are disabled with clear recovery message.
3. Reconfigure destination from setup action.
4. Verify capture actions become enabled again.

## Regression Checks
1. Successful capture still writes to `YYYY-MM-DD - Note.md`.
2. Failure paths preserve draft input.
3. Task markdown format remains compatible with existing usage.

## Validation Commands
1. Build:
   `swift build`
2. Tests:
   `swift test`

## Latest Execution Outcomes (2026-03-03)
- `swift build`: PASS
- `swift test`: FAIL in current environment due to missing `XCTest` module in
  active Swift toolchain (`no such module 'XCTest'`).
