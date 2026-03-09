# Todo

## Plan
- [x] Ajouter l’action/menu `New note` sous `Task` dans le dropdown.
- [x] Ajouter une modale `New note` avec titre éditable prérempli au format `yyyy-MM-dd - ` et un champ de contenu multi-ligne.
- [x] Implémenter la création d’un fichier `.md` dans le `default note folder` configuré.
- [x] Couvrir le changement avec des tests unitaires/intégration.
- [x] Exécuter les validations pertinentes et vérifier l’état git.

## Review
- Ajout d’une nouvelle action `New note` dans le menu status bar et dans l’API `StatusAction`.
- Ajout d’une modale dédiée avec champ titre prérempli (`yyyy-MM-dd - `) et éditeur de contenu.
- Ajout de `CaptureWindowController.submitStandaloneNote(...)` et `suggestedNewNoteTitlePrefix()`.
- Ajout de `DailyNoteWriter.createNoteFile(...)` avec sanitization du nom de fichier, extension `.md`, et suffixe auto (`(2)`, `(3)`, ...) en cas de collision.
- Tests ajoutés/ajustés:
  - `tests/unit/CaptureWindowControllerTests.swift`
  - `tests/integration/StatusBarControllerIntegrationTests.swift`
  - `tests/contract/MenuAvailabilityContractTests.swift`
- Validation:
  - `swift build` ✅
  - `swift test ...` ❌ bloqué par l’environnement (`no such module 'XCTest'`).
