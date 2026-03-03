# Quickstart: Settings Window Configuration Split

## Prerequisites
- App builds and launches on macOS 14+.
- A local Obsidian vault exists.
- User has filesystem access to target folders.

## Scenario 1: Configure vault and default folder from Settings
1. Launch app and open menu bar entry.
2. Open `Settings`.
3. Select a local Obsidian vault.
4. Select the default note folder.
5. Close and reopen `Settings`.
6. Verify both selections are persisted and visible.

## Scenario 2: Capture uses configured destination
1. Ensure vault and default folder are valid in `Settings`.
2. Create a `Quick Note`.
3. Create a `Task`.
4. Verify both entries are written into the configured default folder.

## Scenario 3: Invalid configuration blocks capture
1. Configure a valid vault and folder.
2. Make vault or folder inaccessible (or choose an invalid folder).
3. Open menu and verify capture actions are disabled.
4. Verify blocking message points to `Settings`.
5. Restore valid configuration and confirm capture actions are enabled again.

## Scenario 4: Independent updates
1. Open `Settings` with valid initial values.
2. Update only vault selection.
3. Verify folder setting is unchanged unless explicitly modified.
4. Update only default folder.
5. Verify vault selection remains unchanged.

## Implementation Notes
- `Settings` opens a dedicated window with exactly two configuration sections:
  - Obsidian vault selection
  - Default note folder selection

## Validation Commands
1. Build:
   `swift build`
2. Tests:
   `swift test`

## Latest Execution Outcomes (2026-03-03)
- `swift build`: PASS
- `swift test`: FAIL in current environment due to missing `XCTest` module in active Swift toolchain (`no such module 'XCTest'`).
