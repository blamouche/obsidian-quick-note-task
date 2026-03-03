# Feature Specification: Obsidian Menu Bar Capture

**Feature Branch**: `001-menubar-obsidian-capture`  
**Created**: 2026-03-03  
**Status**: Draft  
**Input**: User description: "mini app mac en barre de status pour quick note/task dans Obsidian"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Ajouter une quick note (Priority: P1)

En tant qu'utilisateur macOS, je veux ouvrir l'application depuis la barre de statut,
choisir "Quick Note" et saisir un texte libre afin de capturer une idée en quelques secondes
sans ouvrir Obsidian.

**Why this priority**: C'est la valeur principale attendue: capture instantanée de notes.

**Independent Test**: Depuis la barre de statut, l'utilisateur crée une quick note, puis vérifie
qu'elle est ajoutée à la fin du fichier du jour au bon emplacement.

**Acceptance Scenarios**:

1. **Given** l'application est lancée et un dossier Obsidian est configuré, **When** l'utilisateur clique l'icône de barre de statut puis "Quick Note" et valide un texte non vide, **Then** la note est ajoutée dans `YYYY-MM-DD - Note.md`.
2. **Given** le fichier du jour n'existe pas, **When** l'utilisateur valide une quick note, **Then** le fichier est créé puis la note est ajoutée.

---

### User Story 2 - Ajouter une task avec échéance optionnelle (Priority: P1)

En tant qu'utilisateur macOS, je veux choisir "Task" depuis la barre de statut, saisir un titre,
et éventuellement une date d'échéance, pour créer une tâche compatible avec mes requêtes
Dataview et le plugin Tasks.

**Why this priority**: La capture de tâches est le second usage critique de l'outil.

**Independent Test**: L'utilisateur crée une task avec et sans échéance; les deux entrées sont
lisibles comme tâches dans les vues Tasks/Dataview.

**Acceptance Scenarios**:

1. **Given** un dossier Obsidian configuré, **When** l'utilisateur crée une task avec un titre et une échéance, **Then** la ligne de tâche est ajoutée dans un format compatible Tasks/Dataview avec la date.
2. **Given** un dossier Obsidian configuré, **When** l'utilisateur crée une task avec un titre sans échéance, **Then** la ligne de tâche est ajoutée dans un format compatible Tasks/Dataview sans date.

---

### User Story 3 - Configurer le dossier cible Obsidian (Priority: P2)

En tant qu'utilisateur, je veux configurer le dossier local de destination pour que les captures
soient écrites dans le bon vault Obsidian, même après redémarrage de l'application.

**Why this priority**: Sans dossier cible correct, la fonctionnalité principale est inutilisable.

**Independent Test**: L'utilisateur choisit un dossier, redémarre l'application, puis vérifie que
les nouvelles captures sont écrites dans ce dossier.

**Acceptance Scenarios**:

1. **Given** aucune configuration initiale, **When** l'utilisateur sélectionne un dossier local, **Then** ce dossier devient la destination active des nouvelles entrées.
2. **Given** un dossier déjà configuré, **When** l'utilisateur relance l'application, **Then** la destination configurée est conservée.

---

### Edge Cases

- Que se passe-t-il si le dossier configuré n'existe plus ou n'est plus accessible?
- Que se passe-t-il si l'utilisateur valide une quick note vide ou une task sans titre?
- Que se passe-t-il si le fichier du jour est verrouillé ou non modifiable?
- Que se passe-t-il lors d'un changement de date (avant/après minuit) pendant l'utilisation?
- Que se passe-t-il si le même contenu est soumis plusieurs fois très rapidement?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: L'application MUST être accessible depuis la barre de statut macOS.
- **FR-002**: Au clic, l'application MUST proposer exactement deux actions de capture: `Quick Note` et `Task`.
- **FR-003**: Le flux `Quick Note` MUST accepter un texte brut non vide et créer une nouvelle entrée de note.
- **FR-004**: Le flux `Task` MUST exiger un titre non vide et permettre une date d'échéance optionnelle.
- **FR-005**: Les tasks MUST être écrites dans un format compatible plugin Tasks et exploitable par Dataview.
- **FR-006**: Pour chaque ajout, la destination MUST être le fichier `YYYY-MM-DD - Note.md` correspondant à la date locale courante.
- **FR-007**: Si le fichier du jour n'existe pas, le système MUST le créer avant ajout du contenu.
- **FR-008**: Si le fichier du jour existe, le système MUST ajouter le nouveau contenu en fin de fichier sans supprimer l'existant.
- **FR-009**: Chaque entrée ajoutée MUST être séparée visuellement de l'entrée précédente.
- **FR-010**: L'application MUST permettre la sélection d'un dossier local de destination pour Obsidian.
- **FR-011**: Le dossier sélectionné MUST être conservé pour les usages suivants de l'application.
- **FR-012**: Si la destination est invalide ou inaccessible, l'application MUST afficher une erreur explicite et ne pas perdre le contenu saisi.
- **FR-013**: Le système MUST empêcher l'écriture de contenu vide (quick note vide ou task sans titre).

### Key Entities *(include if feature involves data)*

- **Capture Entry**: Élément saisi par l'utilisateur, de type `quick_note` ou `task`, contenant le texte principal et des métadonnées (horodatage, type).
- **Task Entry**: Capture Entry spécialisée contenant un titre obligatoire et une échéance optionnelle.
- **Daily Note File**: Fichier quotidien nommé `YYYY-MM-DD - Note.md` qui stocke les entrées ajoutées dans l'ordre chronologique.
- **Destination Folder Setting**: Paramètre persistant indiquant le dossier Obsidian local où écrire les fichiers journaliers.

## Assumptions

- Le dossier de destination est un chemin local sur la machine de l'utilisateur.
- Le format visuel de séparation peut être standardisé tant qu'il est clairement identifiable dans le markdown.
- Les utilisateurs cibles utilisent les conventions habituelles des plugins Tasks et Dataview dans Obsidian.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 95% des captures (quick note ou task) sont complétées en moins de 10 secondes après clic sur l'icône de barre de statut.
- **SC-002**: 100% des captures valides sont ajoutées au fichier journalier correct sans écrasement de contenu existant.
- **SC-003**: 100% des tasks ajoutées sont détectables dans une vue Tasks standard et interrogeables dans Dataview.
- **SC-004**: Dans un test utilisateur guidé, au moins 90% des utilisateurs configurent correctement le dossier destination en une tentative.
- **SC-005**: 100% des erreurs d'accès au dossier/fichier sont signalées avec un message explicite et sans perte du texte saisi.
