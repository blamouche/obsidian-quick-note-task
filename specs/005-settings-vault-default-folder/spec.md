# Feature Specification: Settings Window Configuration Split

**Feature Branch**: `005-settings-vault-default-folder`  
**Created**: 2026-03-03  
**Status**: Draft  
**Input**: User description: "nouvelle spec 005 Modifier la section settings : doit ouvrir une fenêtre avec deux configurations, sélection du Vault Obsidian local, sélection du dossier par défaut où créer la note (celui qui existe actuellement)"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Configurer le vault Obsidian local (Priority: P1)

En tant qu'utilisateur, je veux sélectionner explicitement mon vault Obsidian local
pour que l'application sache dans quel espace de travail écrire mes captures.

**Why this priority**: Sans vault correctement sélectionné, l'application ne peut pas
répondre au besoin principal de capture dans Obsidian.

**Independent Test**: Ouvrir la fenêtre Settings, choisir un vault local valide,
fermer puis rouvrir la fenêtre, et vérifier que la sélection est conservée.

**Acceptance Scenarios**:

1. **Given** la fenêtre Settings est ouverte, **When** l'utilisateur choisit un vault Obsidian local valide, **Then** la configuration du vault est enregistrée et visible.
2. **Given** un vault a déjà été configuré, **When** l'utilisateur rouvre Settings, **Then** le vault actuel est affiché comme sélection active.
3. **Given** l'utilisateur annule la sélection du vault, **When** il revient à Settings, **Then** la configuration précédente reste inchangée.

---

### User Story 2 - Définir le dossier par défaut des notes (Priority: P1)

En tant qu'utilisateur, je veux choisir le dossier par défaut de création de note
pour contrôler précisément où les quick notes/tasks sont ajoutées dans mon vault.

**Why this priority**: Le dossier de destination détermine l'organisation des notes
au quotidien et influence directement la qualité du flux de capture.

**Independent Test**: Ouvrir la fenêtre Settings, modifier le dossier par défaut,
créer une note, puis vérifier que la note est écrite dans le dossier choisi.

**Acceptance Scenarios**:

1. **Given** la fenêtre Settings est ouverte, **When** l'utilisateur sélectionne un dossier par défaut valide, **Then** ce dossier devient la destination par défaut des nouvelles notes.
2. **Given** un dossier par défaut est déjà configuré, **When** l'utilisateur revient dans Settings, **Then** le dossier actuel est affiché.
3. **Given** l'utilisateur change de dossier par défaut, **When** il valide puis crée une nouvelle note, **Then** la nouvelle destination est utilisée immédiatement.

---

### User Story 3 - Gérer les deux configurations dans une seule fenêtre (Priority: P2)

En tant qu'utilisateur, je veux une fenêtre Settings unique qui regroupe les deux
configurations (vault + dossier par défaut) pour réduire les allers-retours et
comprendre rapidement l'état global de configuration.

**Why this priority**: Une configuration centralisée améliore l'efficacité et la
compréhension, tout en restant secondaire par rapport à la validité des données.

**Independent Test**: Ouvrir Settings et vérifier que les deux sections sont
présentes, compréhensibles et modifiables indépendamment l'une de l'autre.

**Acceptance Scenarios**:

1. **Given** l'utilisateur ouvre Settings, **When** la fenêtre s'affiche, **Then** les deux configurations distinctes (vault et dossier par défaut) sont visibles dans la même fenêtre.
2. **Given** une seule des deux configurations est modifiée, **When** l'utilisateur enregistre ou ferme la fenêtre, **Then** la configuration non modifiée reste intacte.
3. **Given** les deux configurations sont valides, **When** l'utilisateur lance une capture, **Then** l'application utilise le vault et le dossier définis dans Settings.

---

### Edge Cases

- Que se passe-t-il si le vault sélectionné devient inaccessible après configuration?
- Que se passe-t-il si le dossier par défaut sélectionné n'existe plus dans le vault?
- Que se passe-t-il si l'utilisateur configure un vault mais aucun dossier par défaut?
- Que se passe-t-il si l'utilisateur configure un dossier qui n'appartient pas au vault sélectionné?
- Que se passe-t-il si l'utilisateur ferme la fenêtre Settings pendant une modification non finalisée?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: La section Settings MUST ouvrir une fenêtre dédiée de configuration.
- **FR-002**: La fenêtre Settings MUST présenter exactement deux configurations distinctes: sélection du vault Obsidian local et sélection du dossier par défaut de création de note.
- **FR-003**: L'utilisateur MUST pouvoir sélectionner un vault Obsidian local depuis la fenêtre Settings.
- **FR-004**: La configuration du vault sélectionné MUST être conservée entre les ouvertures de l'application.
- **FR-005**: L'utilisateur MUST pouvoir sélectionner le dossier par défaut de création de note depuis la même fenêtre Settings.
- **FR-006**: Le dossier par défaut configuré actuellement MUST rester la référence fonctionnelle et être modifiable dans cette nouvelle fenêtre.
- **FR-007**: La modification de la configuration du vault MUST NOT écraser automatiquement la configuration du dossier par défaut sans action explicite utilisateur.
- **FR-008**: La modification de la configuration du dossier par défaut MUST NOT modifier la configuration du vault sélectionné.
- **FR-009**: Toute configuration invalide (vault ou dossier inaccessible) MUST afficher un état explicite et bloquer les captures dépendantes tant qu'elle n'est pas corrigée.
- **FR-010**: Les captures créées après configuration valide MUST utiliser le vault et le dossier par défaut définis dans Settings.

### Key Entities *(include if feature involves data)*

- **Vault Configuration**: Sélection du vault Obsidian local utilisé comme périmètre principal de travail.
- **Default Note Folder Configuration**: Sélection du dossier de destination par défaut pour la création des notes/tasks.
- **Settings Window State**: État de la fenêtre de configuration regroupant les deux paramètres et leur validité.

## Assumptions

- La logique de création de contenu markdown reste inchangée; seul le périmètre de configuration Settings évolue.
- Le "dossier par défaut" correspond au mécanisme de destination déjà existant dans l'application.
- Le vault et le dossier par défaut sont deux paramètres indépendants mais complémentaires.
- L'application nécessite des configurations valides pour garantir des captures réussies.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% des utilisateurs testeurs identifient les deux configurations attendues dans la fenêtre Settings en moins de 10 secondes.
- **SC-002**: 95% des utilisateurs complètent la configuration initiale (vault + dossier par défaut) sans assistance en moins de 60 secondes.
- **SC-003**: 100% des captures de test sont créées dans le dossier par défaut configuré lorsque les deux paramètres sont valides.
- **SC-004**: 100% des cas de configuration invalide affichent un état explicite avant tentative de capture.
- **SC-005**: Le taux d'erreurs liées à une mauvaise destination de note diminue d'au moins 50% par rapport au flux précédent.
