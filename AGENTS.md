# obsidian-quick-note-task Development Guidelines

Auto-generated from all feature plans. Last updated: 2026-03-03

## Active Technologies
- Swift 6.2 + AppKit (menu bar UI, date picker control), Foundation (date serialization) (002-task-date-picker)
- Existing local markdown write flow in selected Obsidian directory (no data model storage change) (002-task-date-picker)
- Swift 6.2 + AppKit (menu/status UX), Foundation (filesystem/date), existing domain/services modules (003-ux-productivity)
- Local filesystem in user-selected Obsidian vault (existing markdown append flow) (003-ux-productivity)
- Swift 6.x (Swift tools 6.0, compatible codebase Swift 6.2) + AppKit (fenêtres/menu/status UI), Foundation (états locaux), modules domain/services existants (004-ui-visual-refresh)
- Système de fichiers local (vault Obsidian déjà configuré; aucun nouveau stockage) (004-ui-visual-refresh)

- Swift 5.10 + AppKit (status bar UI), Foundation (filesystem/date), UniformTypeIdentifiers (folder picker) (001-menubar-obsidian-capture)

## Project Structure

```text
src/
tests/
```

## Commands

# Add commands for Swift 5.10

## Code Style

Swift 5.10: Follow standard conventions

## Recent Changes
- 004-ui-visual-refresh: Added Swift 6.x (Swift tools 6.0, compatible codebase Swift 6.2) + AppKit (fenêtres/menu/status UI), Foundation (états locaux), modules domain/services existants
- 003-ux-productivity: Added Swift 6.2 + AppKit (menu/status UX), Foundation (filesystem/date), existing domain/services modules
- 002-task-date-picker: Added Swift 6.2 + AppKit (menu bar UI, date picker control), Foundation (date serialization)


<!-- MANUAL ADDITIONS START -->
<!-- MANUAL ADDITIONS END -->
