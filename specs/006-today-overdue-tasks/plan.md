# Implementation Plan: Today & Overdue Task Dropdown

**Branch**: `006-today-overdue-tasks` | **Date**: 2026-03-03 | **Spec**: [/Users/benoitlamouche/Documents/github/obsidian-quick-note-task/specs/006-today-overdue-tasks/spec.md](/Users/benoitlamouche/Documents/github/obsidian-quick-note-task/specs/006-today-overdue-tasks/spec.md)
**Input**: Feature specification from `/specs/006-today-overdue-tasks/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

Ajouter dans la dropdown de l'app une section listant les tâches Obsidian non
réalisées dues aujourd'hui ou en retard, appliquer un filtre d'exclusion texte
configurable dans Settings, permettre le cochage direct avec synchronisation
markdown, et replanifier automatiquement les tâches récurrentes selon leur
règle sans modifier les flux existants de capture.

## Technical Context

**Language/Version**: Swift 6.x (Swift tools 6.0, compatible codebase Swift 6.2)  
**Primary Dependencies**: AppKit (menu/status + checkbox interactions), Foundation (date/filesystem parsing), modules domain/services existants  
**Storage**: Système de fichiers local dans le vault Obsidian configuré (aucun nouveau stockage persistant)  
**Testing**: XCTest via `tests/unit`, `tests/integration`, `tests/contract` (filtrage échéance/exclusion, cochage markdown, récurrence)  
**Target Platform**: macOS 14+  
**Project Type**: desktop-app  
**Performance Goals**: affichage de la liste des tâches dans la dropdown en moins de 1 seconde pour un vault standard; mise à jour visuelle après cochage en moins de 2 secondes  
**Constraints**: fail-closed si vault indisponible; ne jamais afficher les tâches déjà cochées; filtrer uniquement les tâches dues <= date locale du jour; préserver format markdown existant; pas de dépendance externe ajoutée  
**Scale/Scope**: évolution ciblée de `StatusBarController`, `SettingsController`, services de parsing/écriture markdown et tests associés

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
  Le filtre texte utilisateur est validé/sanitisé; les écritures markdown restent limitées au vault approuvé; aucune gestion de secret nouvelle.
- macOS reliability: PASS  
  Feature entièrement basée sur AppKit/Foundation et gestion explicite des erreurs d'accès local.
- Test discipline: PASS  
  Stratégie de tests unitaires/intégration/contrat définie pour filtrage, cochage, erreurs d'écriture et récurrence.
- Data handling: PASS  
  Lecture/écriture bornée au vault configuré; pas d'export ni de journalisation du contenu complet des notes.
- Complexity control: PASS  
  Extension incrémentale des composants existants sans nouveau sous-système ni stockage.

### Post-Design Constitution Re-Check

- Security by default: PASS
- macOS reliability: PASS
- Test discipline: PASS
- Data handling: PASS
- Complexity control: PASS

## Project Structure

### Documentation (this feature)

```text
specs/006-today-overdue-tasks/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   ├── dropdown-task-listing.md
│   └── task-toggle-recurrence.md
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
│   ├── StatusBarControllerTests.swift
│   ├── SettingsControllerTests.swift
│   ├── MarkdownFormatterTests.swift
│   └── ValidationTests.swift
├── integration/
│   ├── StatusBarControllerIntegrationTests.swift
│   ├── DailyNoteWriterIntegrationTests.swift
│   └── DestinationStoreIntegrationTests.swift
└── contract/
    ├── MenuAvailabilityContractTests.swift
    ├── SettingsValidationGatingContractTests.swift
    └── DropdownTasksContractTests.swift
```

**Structure Decision**: conserver l'architecture Swift package existante; implémenter la fonctionnalité via extension des contrôleurs/services actuels, avec contrats dédiés au listing dropdown et au cochage + récurrence.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| None | N/A | N/A |
