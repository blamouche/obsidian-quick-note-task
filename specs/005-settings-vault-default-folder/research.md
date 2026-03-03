# Research: Settings Window Configuration Split

## Decision 1: Regrouper les paramètres dans une fenêtre Settings unique
- Decision: centraliser la configuration du vault et du dossier par défaut dans une seule fenêtre dédiée.
- Rationale: réduit les allers-retours, améliore la lisibilité de l'état de configuration global et répond explicitement au besoin produit.
- Alternatives considered:
  - Conserver des points d'entrée séparés: plus de friction et compréhension fragmentée.
  - Modifier uniquement le menu sans fenêtre dédiée: manque de clarté pour deux paramètres distincts.

## Decision 2: Conserver deux configurations strictement indépendantes
- Decision: chaque réglage (vault, dossier par défaut) est modifiable indépendamment sans effet implicite sur l'autre.
- Rationale: évite les effets de bord, respecte FR-007/FR-008 et simplifie le débogage des états invalides.
- Alternatives considered:
  - Réinitialiser automatiquement le dossier lors du changement de vault: comportement surprenant et potentiellement destructif.
  - Coupler les deux sélections en un seul champ: ambiguïté sur la source de vérité.

## Decision 3: Imposer une validation explicite des chemins avant capture
- Decision: considérer la configuration invalide si le vault ou le dossier est inaccessible ou incohérent, et bloquer les captures dépendantes.
- Rationale: fail-closed conforme à la constitution, limite les erreurs d'écriture et rend l'état utilisateur explicite.
- Alternatives considered:
  - Essayer d'écrire puis gérer l'erreur tardivement: feedback trop tardif et perte de productivité.
  - Autoriser les captures avec configuration partielle: risque élevé d'échec et de confusion utilisateur.

## Decision 4: Garder le mécanisme actuel de dossier par défaut comme base
- Decision: réutiliser le paramètre de destination existant comme "Default Note Folder", exposé dans la nouvelle fenêtre Settings.
- Rationale: minimise les régressions, évite une migration de données et respecte la contrainte "celui qui existe actuellement".
- Alternatives considered:
  - Introduire un nouveau paramètre parallèle: risque de divergence et dette de migration.
  - Renommer sans rétrocompatibilité: perte de continuité utilisateur.

## Decision 5: Encadrer la feature par des contrats UI et de gating
- Decision: formaliser deux contrats: composition de fenêtre Settings (2 sections) et comportement de blocage quand configuration invalide.
- Rationale: rend la portée testable et prévient les régressions d'UX/fiabilité dans les prochains changements.
- Alternatives considered:
  - Couverture uniquement par tests unitaires: insuffisant pour exprimer les engagements comportementaux inter-composants.
  - Pas de contrat formel: risque de dérive du périmètre produit.

## Implementation Notes (2026-03-03)
- Aucun `NEEDS CLARIFICATION` restant dans le contexte technique de cette feature.
- Le design conserve l'écriture markdown existante et agit uniquement sur le paramétrage de destination.
- Les contrôles de validité sont évalués avant soumission pour préserver un comportement fail-closed.
- Implémentation réalisée avec deux sélections indépendantes dans `SettingsController` (`vault` + `default folder`) et un gating de capture aligné sur cet état agrégé.

## Final Validation Notes (2026-03-03)
- Build validation: PASS (`swift build`).
- Test validation: FAIL in current environment because XCTest is unavailable in the active toolchain (`no such module 'XCTest'`).
- Tradeoff kept: absence de nouveau stockage persistant, réutilisation des services de destination existants.
