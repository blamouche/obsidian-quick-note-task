# Obsidian Quick Note Task

macOS menu bar utility to quickly append quick notes and tasks into an Obsidian
daily note file (`YYYY-MM-DD - Note.md`).

## Current status

- Feature specs, plan, contracts, and executable task breakdown are generated in
  `specs/001-menubar-obsidian-capture/`.
- Swift package scaffold, core domain/services, app controllers, and test files
  are implemented.
- Build validation passes with `swift build`.

## Known limitation

- `swift test` currently fails in this environment due to missing `XCTest`
  module in the active Swift toolchain. The test files are present under
  `tests/` and ready to run once the toolchain exposes XCTest.
