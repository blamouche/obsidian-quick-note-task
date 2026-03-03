# Quickstart: UI Visual Refresh

## Prerequisites
- App builds and launches on macOS 14+.
- A valid destination folder is available for capture flow regression checks.

## Scenario 1: Visual consistency across windows
1. Launch app and open menu bar entry.
2. Open Quick Note window, then Task window, then destination settings.
3. Verify typography hierarchy is consistent (title > labels > inputs > secondary actions).
4. Verify spacing rhythm appears consistent across all windows.

## Scenario 2: State readability (active, disabled, success, error)
1. Start with a valid destination and inspect enabled actions.
2. Switch to an invalid destination state and inspect disabled actions.
3. Trigger one success and one recoverable error message.
4. Verify each state is distinguishable without relying only on color.

## Scenario 3: Folder icon removal
1. Open settings window and locate destination folder action.
2. Verify decorative folder icon is absent.
3. Confirm destination action label remains explicit and actionable.
4. Repeat check from capture-related window entry points if present.

## Scenario 4: Functional non-regression
1. Create a quick note and verify append to daily note file.
2. Create a task (with and without due date) and verify markdown output.
3. Verify destination reconfiguration still unblocks capture actions.

## Validation Commands
1. Build:
   `swift build`
2. Tests:
   `swift test`

## Latest Execution Outcomes (2026-03-03)
- `swift build`: PASS
- `swift test`: FAIL in current environment due to missing `XCTest` module in active Swift toolchain (`no such module 'XCTest'`).
