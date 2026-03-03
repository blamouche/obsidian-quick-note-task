# Quickstart: Obsidian Menu Bar Capture

## Prerequisites
- macOS 14+
- Obsidian vault available locally
- Write permission to destination folder

## Setup
1. Launch the application.
2. Open `Settings` from the menu bar app.
3. Select the local destination folder in your Obsidian vault.
4. Confirm the folder is saved and accessible.

## Capture a quick note
1. Click the menu bar icon.
2. Select `Quick Note`.
3. Enter plain text.
4. Submit.
5. Verify the text appears in `YYYY-MM-DD - Note.md`.

## Capture a task
1. Click the menu bar icon.
2. Select `Task`.
3. Enter a title.
4. Optionally set a due date.
5. Submit.
6. Verify a task line was appended in Tasks-compatible format.

## Validate append behavior
1. Submit at least two captures on the same day.
2. Open the daily file.
3. Confirm entries are appended in order and separated by `---`.

## Failure handling checks
1. Temporarily revoke access or move the destination folder.
2. Submit a capture.
3. Confirm an explicit error is shown and input is still recoverable.

## Validation commands
1. Build app target:
   `swift build`
2. Attempt test suite:
   `swift test`
3. If `swift test` fails because `XCTest` is unavailable in the active toolchain,
   run build validation and manual checks from this quickstart until toolchain is fixed.
