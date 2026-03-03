# Research: Today & Overdue Task Dropdown

## Decision 1: Interpréter "aujourd'hui ou en retard" comme échéance <= date locale du jour
- Decision: retenir uniquement les tâches non cochées dont l'échéance est antérieure ou égale à la date locale courante.
- Rationale: c'est la seule interprétation cohérente avec la notion "en retard" et avec l'objectif de priorisation immédiate.
- Alternatives considered:
  - Échéance >= aujourd'hui: inclut des tâches futures, contredit la notion de retard.
  - Afficher toutes les tâches datées: bruit important et perte de focus opérationnel.

## Decision 2: Exécuter le filtre d'exclusion après les filtres de statut/date
- Decision: appliquer le filtre texte configurable uniquement sur l'ensemble des tâches déjà éligibles (non cochées + dues aujourd'hui/en retard).
- Rationale: réduit le coût de filtrage et évite d'exclure des éléments hors périmètre de toute façon non affichés.
- Alternatives considered:
  - Exclusion en premier: même résultat fonctionnel mais moins lisible pour le raisonnement métier.
  - Exclusion optionnelle par vue: complexité UX non demandée.

## Decision 3: Utiliser une référence source stable pour le cochage markdown
- Decision: chaque item de dropdown doit conserver une référence explicite vers son fichier source et son occurrence de tâche pour appliquer une mise à jour sûre.
- Rationale: évite les collisions quand plusieurs tâches ont le même libellé dans des fichiers différents.
- Alternatives considered:
  - Match par libellé seul: ambigu et sujet aux erreurs d'écriture.
  - Réindexer tout le vault au moment du clic: plus coûteux et plus fragile aux conditions de course.

## Decision 4: Replanifier les tâches récurrentes au moment du cochage
- Decision: pour une tâche récurrente cochée avec succès, générer immédiatement la prochaine occurrence selon la règle portée par la tâche.
- Rationale: maintient la continuité du suivi périodique sans action supplémentaire utilisateur.
- Alternatives considered:
  - Replanification différée par job séparé: complexité inutile pour ce périmètre.
  - Ne pas replanifier en cas de cochage depuis dropdown: incohérence fonctionnelle selon le point d'entrée.

## Decision 5: Échec partiel explicite en cas de récurrence invalide
- Decision: si la règle de récurrence est invalide, conserver le cochage de la tâche courante mais notifier l'absence de replanification.
- Rationale: évite de perdre l'intention de clôture utilisateur tout en rendant l'écart visible.
- Alternatives considered:
  - Annuler tout le cochage: pénalise l'utilisateur et bloque une action valide.
  - Ignorer silencieusement l'échec de replanification: non conforme à la traçabilité attendue.

## Decision 6: Rafraîchissement immédiat de la section dropdown après mutation
- Decision: après toute action de cochage (succès ou échec), recalculer la liste affichée à partir de l'état réel des fichiers.
- Rationale: garantit une UI cohérente et limite les états transitoires trompeurs.
- Alternatives considered:
  - Mise à jour optimiste non vérifiée: risque de divergence UI/fichier.
  - Rafraîchissement manuel seulement: charge cognitive inutile.

## Final Validation Notes (2026-03-03)
- Tous les points du contexte technique sont résolus, aucun `NEEDS CLARIFICATION` restant.
- Les décisions respectent la constitution: fail-closed, périmètre local vault, tests obligatoires.
