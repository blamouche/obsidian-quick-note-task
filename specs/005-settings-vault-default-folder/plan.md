# Implementation Plan: Settings Window Configuration Split

**Branch**: `005-settings-vault-default-folder` | **Date**: 2026-03-03 | **Spec**: [/Users/benoitlamouche/Documents/github/obsidian-quick-note-task/specs/005-settings-vault-default-folder/spec.md](/Users/benoitlamouche/Documents/github/obsidian-quick-note-task/specs/005-settings-vault-default-folder/spec.md)
**Input**: Feature specification from `/specs/005-settings-vault-default-folder/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

Refondre la section `Settings` pour ouvrir une fenêtre dédiée regroupant deux
configurations explicites: sélection du vault Obsidian local et sélection du
dossier par défaut de création de note, tout en préservant le flux de capture
markdown existant et la compatibilité avec la configuration actuelle.

## Technical Context

**Language/Version**: Swift 6.x (Swift tools 6.0, compatible codebase Swift 6.2)  
**Primary Dependencies**: AppKit (window/menu controls), Foundation (filesystem/path state), UniformTypeIdentifiers (folder picking), modules domain/services existants  
**Storage**: Système de fichiers local dans le vault Obsidian utilisateur (aucun nouveau stockage)  
**Testing**: XCTest via `tests/unit`, `tests/integration`, `tests/contract` (configuration persistence, gating de capture, contrats settings)  
**Target Platform**: macOS 14+  
**Project Type**: desktop-app  
**Performance Goals**: ouverture de la fenêtre Settings sans latence perceptible; aucun allongement perceptible du flux de capture après configuration  
**Constraints**: exactement deux configurations dans la fenêtre Settings; conserver la logique markdown existante; empêcher les captures si vault/dossier invalide; ne pas écraser une configuration par l'autre sans action explicite  
**Scale/Scope**: évolution ciblée des contrôleurs Settings/Status et services de configuration existants; pas de nouveau sous-système de stockage

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
  Les chemins vault/dossier restent validés avant usage; aucun secret ou dépendance externe ajoutés.
- macOS reliability: PASS  
  Flux basé sur composants natifs AppKit/NSOpenPanel; compatibilité macOS 14+ inchangée.
- Test discipline: PASS  
  Tests unitaires, intégration et contrats couvrent persistance settings, états invalides et non-régression capture.
- Data handling: PASS  
  Données limitées aux chemins validés dans le périmètre vault utilisateur; pas de journalisation de contenu de note.
- Complexity control: PASS  
  Réutilisation des services existants avec extension de configuration à deux paramètres indépendants.

### Post-Design Constitution Re-Check

- Security by default: PASS
- macOS reliability: PASS
- Test discipline: PASS
- Data handling: PASS
- Complexity control: PASS

## Project Structure

### Documentation (this feature)

```text
specs/005-settings-vault-default-folder/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   ├── settings-window-configuration.md
│   └── settings-validation-gating.md
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
    ├── UIStyle.swift
    ├── AppIconFactory.swift
    ├── DateProvider.swift
    └── Logger.swift

tests/
├── unit/
│   ├── SettingsControllerTests.swift
│   ├── CaptureWindowControllerTests.swift
│   ├── DailyNotePathResolverTests.swift
│   └── ValidationTests.swift
├── integration/
│   ├── DestinationStoreIntegrationTests.swift
│   ├── StatusBarControllerIntegrationTests.swift
│   └── DailyNoteWriterIntegrationTests.swift
└── contract/
    ├── MenuAvailabilityContractTests.swift
    ├── CaptureFeedbackContractTests.swift
    └── FolderAffordanceContractTests.swift
```

**Structure Decision**: conserver l'architecture Swift package existante; implémenter la nouvelle fenêtre Settings et la séparation vault/dossier dans les contrôleurs/services actuels avec contrats dédiés à la configuration et au gating.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| None | N/A | N/A |
