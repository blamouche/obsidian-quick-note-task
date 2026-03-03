# Feature Specification: Task Date Picker

**Feature Branch**: `002-task-date-picker`  
**Created**: 2026-03-03  
**Status**: Draft  
**Input**: User description: "ajouter un date picker dans l'interface pour l'ajout de task"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Sélectionner une date d'échéance via date picker (Priority: P1)

En tant qu'utilisateur de l'application menu bar, je veux choisir la date d'échéance
d'une task avec un date picker pour éviter les erreurs de format et aller plus vite.

**Why this priority**: Le flux task existe déjà; l'ajout du date picker améliore
directement la fiabilité et l'expérience principale.

**Independent Test**: L'utilisateur ouvre l'option `Task`, saisit un titre,
sélectionne une date dans le date picker, valide, puis vérifie que la task est
ajoutée avec une date d'échéance correcte.

**Acceptance Scenarios**:

1. **Given** un dossier de destination valide est configuré, **When** l'utilisateur ajoute une task avec un titre et choisit une date via le date picker, **Then** la task est ajoutée avec une échéance valide dans le fichier du jour.
2. **Given** un dossier de destination valide est configuré, **When** l'utilisateur ajoute une task sans choisir de date, **Then** la task est ajoutée sans échéance.

---

### User Story 2 - Éviter les erreurs de saisie de date (Priority: P2)

En tant qu'utilisateur, je veux éviter la saisie manuelle d'une date pour réduire
les erreurs et les rejets au moment de l'ajout de task.

**Why this priority**: Réduit la friction et les erreurs utilisateur, mais reste
secondaire par rapport à la capture d'une task.

**Independent Test**: L'utilisateur n'a plus besoin de saisir un texte de date
manuellement pour créer une task avec échéance.

**Acceptance Scenarios**:

1. **Given** l'interface task est ouverte, **When** l'utilisateur choisit une date depuis le composant visuel, **Then** aucune validation de format date n'est nécessaire côté utilisateur.
2. **Given** l'utilisateur modifie la date sélectionnée avant validation, **When** il soumet la task, **Then** la date finale sélectionnée est celle persistée.

---

### User Story 3 - Conserver la compatibilité de sortie markdown (Priority: P2)

En tant qu'utilisateur Obsidian, je veux que les tasks générées avec date picker
restent compatibles avec Tasks et Dataview.

**Why this priority**: La compatibilité de sortie est une contrainte fonctionnelle
forte de la solution existante.

**Independent Test**: Une task créée via date picker est visible dans une requête
Tasks/Dataview comme les tasks déjà générées avant ce changement.

**Acceptance Scenarios**:

1. **Given** une task est créée avec date via le date picker, **When** l'entrée est ajoutée au markdown, **Then** le format de date respecte la convention attendue.
2. **Given** des tasks créées avant et après ce changement, **When** elles sont consultées dans Obsidian, **Then** le comportement de lecture reste cohérent.

---

### Edge Cases

- Que se passe-t-il si l'utilisateur ouvre le flux task puis annule sans valider?
- Que se passe-t-il si la date est activée puis désactivée avant soumission?
- Que se passe-t-il lors d'un changement de jour (minuit) entre ouverture du formulaire et validation?
- Que se passe-t-il si le dossier destination devient inaccessible au moment de la soumission?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Le flux `Task` MUST proposer un composant de sélection de date (date picker) dans l'interface.
- **FR-002**: Le date picker MUST permettre de choisir une échéance optionnelle pour une task.
- **FR-003**: Le titre de task MUST rester obligatoire et non vide.
- **FR-004**: L'utilisateur MUST pouvoir soumettre une task sans échéance.
- **FR-005**: Si une échéance est sélectionnée, la task générée MUST inclure une date d'échéance valide.
- **FR-006**: Le format de sortie markdown des tasks MUST rester compatible avec les usages Tasks et Dataview.
- **FR-007**: Le changement d'interface MUST préserver le comportement actuel d'ajout dans `YYYY-MM-DD - Note.md`.
- **FR-008**: Le système MUST continuer d'afficher une erreur explicite si la destination est invalide/inaccessible.
- **FR-009**: Le système MUST préserver la saisie utilisateur en cas d'échec d'écriture.

### Key Entities *(include if feature involves data)*

- **Task Input State**: État de saisie de la task dans l'interface, incluant titre obligatoire et échéance optionnelle sélectionnée.
- **Due Date Selection**: Valeur de date issue du date picker, facultative, transformée en date de sortie markdown.
- **Task Markdown Entry**: Ligne de task ajoutée au fichier du jour avec ou sans échéance.

## Assumptions

- Le date picker remplace la saisie manuelle du champ date dans le flux task.
- Le format de date de sortie attendu reste inchangé par rapport au comportement actuel.
- Le reste du flux (destination dossier, append dans la note du jour, séparateur visuel) est déjà en place et ne change pas fonctionnellement.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 95% des utilisateurs créent une task avec échéance sans erreur de date au premier essai.
- **SC-002**: 100% des tasks créées avec date picker sont enregistrées avec une date valide dans la sortie markdown.
- **SC-003**: 100% des tasks sans échéance restent créables et correctement enregistrées.
- **SC-004**: Le temps moyen de création d'une task avec échéance diminue d'au moins 20% par rapport à la saisie manuelle.
- **SC-005**: Aucune régression sur l'ajout dans `YYYY-MM-DD - Note.md` n'est observée dans les scénarios de validation.
