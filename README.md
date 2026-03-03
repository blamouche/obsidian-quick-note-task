# Obsidian Quick Note Task

macOS menu bar utility to quickly append quick notes and tasks into an Obsidian
daily note file (`YYYY-MM-DD - Note.md`).

## Current status

- Feature specs, plan, contracts, and executable task breakdown are generated in
  `specs/001-menubar-obsidian-capture/`.
- Date picker enhancement specs/plan/tasks are generated in
  `specs/002-task-date-picker/`.
- UX productivity enhancement specs/plan/tasks are generated in
  `specs/003-ux-productivity/`.
- Swift package scaffold, core domain/services, app controllers, and test files
  are implemented.
- Task creation UI now includes an optional native date picker instead of
  manual date text input.
- Menu UX now enforces configuration-first behavior:
  `Quick Note` and `Task` are disabled until destination setup is valid.
- App status messaging now exposes explicit states (setup required, ready,
  recovery required) with actionable settings labels.
- Build validation passes with `swift build`.
- UI visual refresh (004) now defines shared typography/spacing/state style tokens, improves capture window readability, and removes decorative folder icon affordances while keeping destination actions explicit.

## Known limitation

- `swift test` currently fails in this environment due to missing `XCTest`
  module in the active Swift toolchain. The test files are present under
  `tests/` and ready to run once the toolchain exposes XCTest.

## CI/CD release automation

This repository includes a GitHub Actions pipeline in
`.github/workflows/release.yml`, triggered on every push to `main`:

- Build a production `.app` bundle from SwiftPM executable
- Package the app into a `.dmg`
- Upload the `.dmg` as a workflow artifact
- Publish the `.dmg` in GitHub Releases
- Update this README with the latest release URL

No signing, notarization, certificate import, or Sparkle integration is used in
this workflow.

### Latest DMG download

<!-- DMG_LINK_START -->

Latest DMG: [https://github.com/blamouche/obsidian-quick-note-task/releases/download/0.0.3/ObsidianQuickNoteTask-0.0.3.dmg](https://github.com/blamouche/obsidian-quick-note-task/releases/download/0.0.3/ObsidianQuickNoteTask-0.0.3.dmg)
Last update: 2026-03-03 (UTC)
<!-- DMG_LINK_END -->

### Optional customizations

Workflow env defaults:

- Bundle ID: `com.benoitlamouche.obsidianquicknotetask`
- App bundle name: `ObsidianQuickNoteTask`

If needed, adjust values in `.github/workflows/release.yml`.
