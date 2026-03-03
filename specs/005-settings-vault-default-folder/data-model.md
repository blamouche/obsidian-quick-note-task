# Data Model: Settings Window Configuration Split

## Vault Configuration
- Purpose: représenter le vault Obsidian local sélectionné comme racine de travail.
- Fields:
  - `vaultPath`: chemin absolu sélectionné par l'utilisateur.
  - `isAccessible`: booléen de disponibilité actuelle (lecture/écriture).
  - `validationMessage`: message utilisateur en cas d'état invalide.
- Validation rules:
  - `vaultPath` doit référencer un dossier local existant.
  - `isAccessible` doit être réévalué avant les opérations de capture.

## Default Note Folder Configuration
- Purpose: représenter le dossier de destination par défaut pour la création de notes/tasks.
- Fields:
  - `folderPath`: chemin du dossier configuré.
  - `isAccessible`: booléen de disponibilité actuelle.
  - `isInsideVault`: booléen indiquant l'appartenance au vault sélectionné.
  - `validationMessage`: message utilisateur si la destination est invalide.
- Validation rules:
  - `folderPath` doit pointer vers un dossier local existant.
  - `isInsideVault` doit être `true` pour permettre la capture.
  - `isAccessible` doit être `true` pour permettre la capture.

## Settings Window State
- Purpose: agréger l'état de configuration visible dans la fenêtre Settings.
- Fields:
  - `vaultConfig`: référence à `Vault Configuration`.
  - `defaultFolderConfig`: référence à `Default Note Folder Configuration`.
  - `overallStatus`: `valid | invalidVault | invalidFolder | invalidBoth`.
- Validation rules:
  - `overallStatus = valid` uniquement si `vaultConfig.isAccessible = true` et `defaultFolderConfig.isAccessible = true` et `defaultFolderConfig.isInsideVault = true`.
  - chaque configuration doit pouvoir être modifiée sans écraser automatiquement l'autre.

## Capture Eligibility State
- Purpose: déterminer si les actions `Quick Note` et `Task` sont disponibles.
- Fields:
  - `canCapture`: booléen.
  - `blockingReason`: `none | vaultMissing | vaultInaccessible | folderMissing | folderInaccessible | folderOutsideVault`.
- Validation rules:
  - `canCapture` doit être `false` pour toute valeur de `blockingReason` différente de `none`.
  - l'interface doit exposer un message explicite aligné avec `blockingReason`.

## Relationships
- `Settings Window State` compose `Vault Configuration` et `Default Note Folder Configuration`.
- `Capture Eligibility State` est dérivé de `Settings Window State`.
- Les services de capture consomment `Capture Eligibility State` avant toute écriture markdown.

## State Transitions
- `overallStatus`: `invalid* -> valid` quand les deux sélections sont cohérentes et accessibles.
- `overallStatus`: `valid -> invalid*` si vault/dossier devient inaccessible ou incohérent.
- `canCapture`: `false -> true` après correction configuration valide sans redémarrage.
- `canCapture`: `true -> false` dès détection d'un état de configuration invalide.
