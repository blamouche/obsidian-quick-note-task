# Contract: Settings Window Configuration

## Trigger
- User opens `Settings` from the menu bar app.

## Required Composition
- A dedicated Settings window is displayed.
- Exactly two configuration sections are present:
  - `Obsidian Vault` selection.
  - `Default Note Folder` selection.

## Behavior
- Each section can be updated independently.
- Updating vault does not overwrite default folder unless the user explicitly changes it.
- Updating default folder does not alter vault selection.
- Existing configured values are visible when reopening Settings.

## Validation Feedback
- Invalid or inaccessible configuration is shown with explicit state/message.
- UI provides a corrective path (reselect vault/folder) from the same window.

## Regression Guarantees
- Existing markdown capture format remains unchanged.
- Settings remains the single user-facing entry point for destination configuration.
