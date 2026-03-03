# Data Model: UI Visual Refresh

## Visual Typography Profile
- Purpose: représenter les niveaux de texte visibles dans l'interface.
- Fields:
  - `level`: `title | label | input | actionPrimary | actionSecondary`.
  - `relativeSize`: `large | medium | base | compact`.
  - `weightRole`: `emphasis | standard`.
- Validation rules:
  - chaque surface UI doit mapper ses textes sur un niveau défini.
  - `title` doit toujours être d'un niveau visuel supérieur aux `label`.

## Spacing Rhythm
- Purpose: garantir un espacement cohérent entre composants.
- Fields:
  - `zone`: `windowPadding | sectionGap | fieldGap | actionGap`.
  - `density`: `comfortable | compact`.
- Validation rules:
  - une fenêtre donnée doit rester sur une densité unique par défaut.
  - les `actionGap` ne peuvent pas être supérieurs aux `sectionGap`.

## Color State Role
- Purpose: encoder les états utilisateur de manière cohérente.
- Fields:
  - `state`: `neutral | active | success | error | disabled`.
  - `contrastHint`: indication qualitative de lisibilité (`normal | reinforced`).
  - `nonColorCueRequired`: booléen.
- Validation rules:
  - `disabled` impose `nonColorCueRequired = true`.
  - `error` et `success` doivent être distinguables visuellement.

## Folder Action Presentation
- Purpose: décrire l'affichage de l'action de dossier sans icône décorative.
- Fields:
  - `iconVisible`: bool.
  - `actionLabelPresent`: bool.
  - `context`: `settingsWindow | captureWindow`.
- Validation rules:
  - `iconVisible` doit être `false` pour les contextes ciblés.
  - `actionLabelPresent` doit rester `true`.

## Relationships
- `Visual Typography Profile`, `Spacing Rhythm` et `Color State Role` composent la `Window Visual Composition` de chaque surface.
- `Folder Action Presentation` est un cas spécialisé de composition visuelle pour l'accès au dossier.
- Les états métier existants alimentent `Color State Role` sans changer la logique métier.

## State Transitions
- `Folder Action Presentation.iconVisible`: `true -> false` lors de l'activation de la refonte.
- `Window Visual Composition`: `legacy -> refreshed` par fenêtre, sans impact sur les transitions métier (ready/blocked/error).
