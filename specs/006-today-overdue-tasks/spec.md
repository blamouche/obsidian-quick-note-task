# Feature Specification: Today & Overdue Task Dropdown

**Feature Branch**: `006-today-overdue-tasks`  
**Created**: 2026-03-03  
**Status**: Draft  
**Input**: User description: "Si le vault est configuré, je veux afficher dans la dropdown de l'application (entre Tasks et Configure settings) la liste des todo à faire aujourd'hui ou en retard. la deadline doit être >= aujourd'hui. Dans la configuration, ajouter un champ texte qui permet d'ajouter un texte a supprimer de la recherche. Si le texte indiqué dans cette configuration est présent dans la task, celle-ci ne doit pas etre affichée. Afficher uniquement les tasks qui ne sont pas réalisées (cochées). Ajouter une checkbox a côté des taches, si on la coche, la tache doit être cochée dans le fichier MD obsidian correspondant. Pour les taches récurrentes, il faut gérer la récurrence afin de reprogrammer la tache selon les critères indiqués dans la task."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Voir les tâches à traiter immédiatement (Priority: P1)

En tant qu'utilisateur avec un vault configuré, je veux voir dans la dropdown les tâches non réalisées à faire aujourd'hui ou en retard, pour prioriser mon travail sans ouvrir Obsidian.

**Why this priority**: C'est la valeur principale de la feature: rendre visible l'urgence opérationnelle directement depuis la barre de menu.

**Independent Test**: Avec un vault configuré contenant des tâches non cochées en retard, aujourd'hui et futures, ouvrir la dropdown et vérifier que seules les tâches attendues sont listées entre `Tasks` et `Configure settings`.

**Acceptance Scenarios**:

1. **Given** un vault est configuré et contient des tâches non cochées en retard, dues aujourd'hui et futures, **When** l'utilisateur ouvre la dropdown, **Then** seules les tâches non cochées en retard ou dues aujourd'hui sont affichées.
2. **Given** aucun vault n'est configuré, **When** l'utilisateur ouvre la dropdown, **Then** aucune liste de tâches du jour/en retard n'est affichée.
3. **Given** une tâche est déjà cochée dans le markdown, **When** la dropdown est affichée, **Then** cette tâche n'apparaît pas dans la liste.

---

### User Story 2 - Exclure certains contenus via Settings (Priority: P1)

En tant qu'utilisateur, je veux définir un texte d'exclusion dans la configuration pour masquer automatiquement les tâches contenant ce texte.

**Why this priority**: Le filtre permet d'éliminer le bruit et d'adapter la liste aux tâches réellement actionnables.

**Independent Test**: Configurer un texte d'exclusion, puis vérifier que toutes les tâches non cochées contenant ce texte disparaissent de la dropdown, sans impacter les autres.

**Acceptance Scenarios**:

1. **Given** un texte d'exclusion est configuré, **When** une tâche non cochée contient ce texte, **Then** la tâche est exclue de la liste affichée.
2. **Given** le texte d'exclusion est vide, **When** la dropdown est ouverte, **Then** aucune tâche n'est exclue par ce critère.
3. **Given** le texte d'exclusion est modifié, **When** la dropdown est rouverte, **Then** la liste reflète le nouveau filtrage.

---

### User Story 3 - Cocher une tâche depuis la dropdown (Priority: P2)

En tant qu'utilisateur, je veux cocher une tâche directement depuis la dropdown afin de terminer une action rapidement et synchroniser l'état dans le fichier markdown source.

**Why this priority**: Réduit les aller-retours vers Obsidian et accélère la clôture des tâches courantes.

**Independent Test**: Cocher une tâche depuis la dropdown puis relire le fichier markdown concerné pour vérifier que la tâche est marquée comme réalisée.

**Acceptance Scenarios**:

1. **Given** une tâche non cochée est affichée dans la dropdown, **When** l'utilisateur coche sa case, **Then** la tâche est marquée réalisée dans le fichier markdown correspondant.
2. **Given** une tâche vient d'être cochée avec succès, **When** la liste est rafraîchie, **Then** cette tâche n'est plus affichée.
3. **Given** la mise à jour du fichier markdown échoue, **When** l'utilisateur coche une tâche, **Then** l'application conserve l'état non réalisé dans l'interface et signale l'échec.

---

### User Story 4 - Replanifier les tâches récurrentes (Priority: P2)

En tant qu'utilisateur, je veux que le marquage d'une tâche récurrente crée automatiquement sa prochaine occurrence selon la règle de récurrence de la tâche.

**Why this priority**: Sans replanification automatique, cocher une tâche récurrente casse le flux de suivi périodique.

**Independent Test**: Cocher une tâche récurrente affichée dans la dropdown, puis vérifier que la tâche terminée est cochée et qu'une nouvelle occurrence est ajoutée avec la prochaine échéance.

**Acceptance Scenarios**:

1. **Given** une tâche récurrente non cochée est affichée, **When** l'utilisateur la coche, **Then** la tâche est marquée réalisée et une nouvelle occurrence est programmée selon sa règle de récurrence.
2. **Given** une tâche non récurrente est cochée, **When** l'opération se termine, **Then** aucune nouvelle occurrence n'est créée.
3. **Given** la règle de récurrence d'une tâche est invalide ou inexploitable, **When** la tâche est cochée, **Then** la tâche est marquée réalisée et l'application signale que la replanification n'a pas pu être appliquée.

### Edge Cases

- Que se passe-t-il si la même tâche correspond à la fois au critère "due aujourd'hui/en retard" et au texte d'exclusion? (Le filtre d'exclusion doit prévaloir.)
- Que se passe-t-il si deux tâches identiques existent dans des fichiers markdown différents? (Le cochage doit cibler uniquement la bonne occurrence source.)
- Que se passe-t-il si un fichier markdown est modifié entre l'affichage de la dropdown et le cochage utilisateur?
- Que se passe-t-il si le vault devient indisponible pendant le rafraîchissement de la liste?
- Que se passe-t-il si aucune tâche ne correspond aux critères (non cochée + due aujourd'hui/en retard + non exclue)?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Le système MUST afficher une section de tâches dans la dropdown uniquement si un vault Obsidian est configuré.
- **FR-002**: La section de tâches MUST être positionnée entre les entrées `Tasks` et `Configure settings` dans la dropdown.
- **FR-003**: Le système MUST afficher uniquement les tâches non réalisées (non cochées).
- **FR-004**: Le système MUST afficher uniquement les tâches dont l'échéance est due aujourd'hui ou en retard.
- **FR-005**: Le système MUST exclure toutes les tâches contenant le texte d'exclusion configuré par l'utilisateur.
- **FR-006**: Le système MUST fournir dans Settings un champ texte permettant de définir, modifier et vider le texte d'exclusion.
- **FR-007**: Chaque tâche affichée MUST proposer une case à cocher permettant de la marquer réalisée.
- **FR-008**: Lorsqu'une tâche est cochée depuis la dropdown, le système MUST refléter cet état dans le fichier markdown Obsidian source correspondant.
- **FR-009**: Après cochage réussi d'une tâche, le système MUST retirer cette tâche de la liste affichée.
- **FR-010**: Le système MUST traiter les tâches récurrentes en créant la prochaine occurrence selon la règle de récurrence présente dans la tâche au moment du cochage.
- **FR-011**: Si une règle de récurrence ne peut pas être appliquée, le système MUST marquer la tâche actuelle comme réalisée et MUST informer l'utilisateur que la replanification n'a pas été effectuée.
- **FR-012**: En cas d'échec d'écriture dans un fichier markdown lors d'un cochage, le système MUST informer l'utilisateur et MUST conserver la tâche en état non réalisée dans la liste.
- **FR-013**: Le système MUST ignorer les tâches sans échéance exploitable pour le filtre "aujourd'hui/en retard".
- **FR-SEC-001**: Le système MUST valider et assainir les entrées texte utilisateur (notamment le texte d'exclusion) avant usage.
- **FR-MAC-001**: Le système MUST rester compatible avec les versions macOS officiellement supportées par l'application et gérer explicitement les erreurs d'accès fichiers locales.

### Key Entities *(include if feature involves data)*

- **Dropdown Task Item**: Représente une tâche affichable dans la dropdown, avec son libellé, son statut de réalisation, sa date d'échéance, sa source markdown et son éventuelle règle de récurrence.
- **Task Exclusion Filter**: Préférence utilisateur contenant le texte servant à exclure des tâches de l'affichage.
- **Task Source Reference**: Référence permettant d'identifier de manière fiable la tâche à mettre à jour dans le bon fichier markdown.
- **Recurrence Rule**: Critère métier attaché à une tâche indiquant comment calculer sa prochaine occurrence après réalisation.

## Assumptions

- "À faire aujourd'hui ou en retard" est interprété comme: échéance de la tâche inférieure ou égale à la date locale du jour.
- Les tâches sans échéance ne sont pas incluses dans cette nouvelle section, car elles ne peuvent pas être classées "aujourd'hui/en retard".
- Le texte d'exclusion est un critère de présence textuelle simple appliqué sur le contenu de la tâche.
- Le format de récurrence attendu est celui déjà utilisé dans les tâches markdown du vault utilisateur.
- Les autres flux existants de création de note et de tâche restent inchangés.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Dans un jeu de test de référence, 100% des tâches affichées dans la dropdown respectent simultanément les critères "non cochée", "échéance aujourd'hui/en retard" et "non exclue".
- **SC-002**: Après activation d'un texte d'exclusion, au moins 95% des tâches contenant ce texte sont absentes de la liste au prochain rafraîchissement.
- **SC-003**: 95% des cochages effectués depuis la dropdown mettent à jour correctement le fichier markdown source en moins de 2 secondes.
- **SC-004**: 100% des tâches récurrentes cochées en test créent une nouvelle occurrence conforme à leur règle de récurrence lorsqu'elle est valide.
- **SC-005**: Le taux de tâches cochées depuis la dropdown sans ouverture d'Obsidian atteint au moins 70% sur une période de validation interne.
