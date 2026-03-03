# Research: UI Visual Refresh

## Decision 1: Introduire une hiérarchie typographique explicite
- Decision: définir une hiérarchie de niveaux visuels (titre, libellé, champ, action secondaire) cohérente sur toutes les fenêtres.
- Rationale: la lisibilité et la compréhension de l'action principale reposent d'abord sur une hiérarchie stable.
- Alternatives considered:
  - Ajustements ponctuels écran par écran: risque d'incohérences persistantes.
  - Conserver les tailles actuelles: n'améliore pas la perception "moderne" demandée.

## Decision 2: Standardiser une échelle d'espacements et de densité
- Decision: utiliser un rythme d'espacements régulier entre sections, groupes de champs et zones d'actions.
- Rationale: un rythme constant réduit la charge cognitive et améliore la qualité perçue.
- Alternatives considered:
  - Espacements libres selon écran: rendu hétérogène et difficile à maintenir.
  - Réduction agressive des marges: densité trop élevée, fatigue visuelle.

## Decision 3: Clarifier les états UI par rôles de couleur
- Decision: définir des rôles visuels d'état (neutre, actif, succès, erreur, désactivé) avec contraste suffisant et repères non chromatiques.
- Rationale: l'utilisateur doit comprendre immédiatement les états sans ambiguïté.
- Alternatives considered:
  - S'appuyer uniquement sur la couleur: faible robustesse accessibilité.
  - Uniformiser toutes les couleurs: perte de signal utile sur les retours d'état.

## Decision 4: Supprimer l'icône dossier décorative tout en gardant l'affordance
- Decision: retirer l'icône dossier jugée inesthétique et conserver des libellés d'action explicites pour choisir/changer le dossier.
- Rationale: répond à la demande utilisateur sans régression de compréhension fonctionnelle.
- Alternatives considered:
  - Remplacer par une autre icône: ne répond pas au besoin de simplification visuelle.
  - Retirer aussi le libellé: risque d'ambiguïté sur l'action dossier.

## Decision 5: Limiter la feature à la couche visuelle
- Decision: ne modifier ni logique métier de capture, ni format markdown, ni règles de validation existantes.
- Rationale: réduit le risque de régression et garde le scope concentré sur la valeur UX.
- Alternatives considered:
  - Coupler avec refactor fonctionnel: complexité et risque non nécessaires pour l'objectif.

## Implementation Notes (2026-03-03)
- Aucun `NEEDS CLARIFICATION` restant dans le contexte technique de cette feature.
- Les contrats de Phase 1 couvrent cohérence visuelle inter-fenêtres et suppression ciblée de l'icône dossier.
- Les tests attendus portent sur non-régression des flux métier et validation des états visuels clés.

## Final Validation Notes (2026-03-03)
- Build validation: PASS (`swift build`).
- Test validation: FAIL in current environment because XCTest is unavailable in the active toolchain (`no such module 'XCTest'`).
- Tradeoff kept: visual refresh scope remains strictly UI/presentation and does not alter markdown serialization or destination persistence logic.
