# Implementation Plan: UI Visual Refresh

**Branch**: `004-ui-visual-refresh` | **Date**: 2026-03-03 | **Spec**: [/Users/benoitlamouche/Documents/github/obsidian-quick-note-task/specs/004-ui-visual-refresh/spec.md](/Users/benoitlamouche/Documents/github/obsidian-quick-note-task/specs/004-ui-visual-refresh/spec.md)
**Input**: Feature specification from `/specs/004-ui-visual-refresh/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

Refondre l'interface visuelle de l'app macOS pour améliorer lisibilité et
attractivité (typographie, tailles, espacements, palette d'états) tout en
préservant strictement les flux métier existants de capture et configuration,
avec suppression de l'icône dossier décorative dans les fenêtres concernées.

## Technical Context

**Language/Version**: Swift 6.x (Swift tools 6.0, compatible codebase Swift 6.2)  
**Primary Dependencies**: AppKit (fenêtres/menu/status UI), Foundation (états locaux), modules domain/services existants  
**Storage**: Système de fichiers local (vault Obsidian déjà configuré; aucun nouveau stockage)  
**Testing**: XCTest via `tests/unit`, `tests/integration`, `tests/contract` (ajout de contrats UI visuels + non-régression flux)  
**Target Platform**: macOS 14+  
**Project Type**: desktop-app  
**Performance Goals**: ouverture de fenêtre sans latence perceptible; aucun allongement perceptible du parcours de capture  
**Constraints**: ne pas modifier format markdown ni logique métier; conserver accessibilité des états désactivés; suppression ciblée de l'icône dossier décorative  
**Scale/Scope**: amélioration UI des surfaces existantes (menu bar, fenêtres Quick Note/Task, configuration) sans nouveaux écrans

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- Security by default: input validation, secret handling, dependency risk review
  explicitly addressed.
- macOS reliability: target macOS version, permissions, filesystem/path
  behavior, and `zsh` compatibility documented.
- Test discipline: automated tests defined for critical flows and
  security-relevant failures.
- Data handling: least-privilege scope and logging redaction plan documented.
- Complexity control: any added complexity justified in "Complexity Tracking".

- Security by default: PASS  
  Aucun nouveau point d'entrée externe; la feature est visuelle et conserve la validation existante.
- macOS reliability: PASS  
  AppKit natif et version cible macOS 14+ inchangés; aucune dépendance shell/runtime supplémentaire.
- Test discipline: PASS  
  Contrats UI et tests de non-régression capture/configuration planifiés.
- Data handling: PASS  
  Aucun nouveau stockage ni journalisation de contenu brut introduits.
- Complexity control: PASS  
  Consolidation de styles et suppression d'élément visuel existant, sans nouveau sous-système.

### Post-Design Constitution Re-Check

- Security by default: PASS
- macOS reliability: PASS
- Test discipline: PASS
- Data handling: PASS
- Complexity control: PASS

## Project Structure

### Documentation (this feature)

```text
specs/004-ui-visual-refresh/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   ├── visual-presentation.md
│   └── folder-affordance.md
└── tasks.md
```

### Source Code (repository root)
```text
app/
└── main.swift

src/
├── app/
│   ├── StatusBarController.swift
│   ├── CaptureWindowController.swift
│   └── SettingsController.swift
├── domain/
│   ├── Validation.swift
│   ├── CaptureEntry.swift
│   └── TaskEntry.swift
├── services/
│   ├── DestinationStore.swift
│   ├── DailyNoteWriter.swift
│   ├── DailyNotePathResolver.swift
│   └── MarkdownFormatter.swift
└── support/
    ├── AppIconFactory.swift
    ├── DateProvider.swift
    └── Logger.swift

tests/
├── unit/
│   ├── CaptureWindowControllerTests.swift
│   ├── SettingsControllerTests.swift
│   ├── ValidationTests.swift
│   ├── MarkdownFormatterTests.swift
│   └── DailyNotePathResolverTests.swift
├── integration/
│   ├── StatusBarControllerIntegrationTests.swift
│   ├── DailyNoteWriterIntegrationTests.swift
│   └── DestinationStoreIntegrationTests.swift
└── contract/
    ├── MenuAvailabilityContractTests.swift
    ├── CaptureFeedbackContractTests.swift
    └── MarkdownOutputContractTests.swift
```

**Structure Decision**: conserver l'architecture Swift package actuelle et implémenter la refonte visuelle dans les contrôleurs AppKit existants, avec contrats dédiés pour l'apparence et la suppression de l'icône dossier.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| None | N/A | N/A |
