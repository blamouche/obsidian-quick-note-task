# Feature Specification: UX Productivity Flow

**Feature Branch**: `003-ux-productivity`  
**Created**: 2026-03-03  
**Status**: Draft  
**Input**: User description: "modifier l'UX de l'app pour qu'elle soit excellente pour l'utilisateur. Respecter les bonnes pratiques, limiter le nombre de clics, rendre indisponibles les actions tant que la config n'est pas faite, UX orientée productivité"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Capturer immédiatement après configuration (Priority: P1)

En tant qu'utilisateur, je veux un parcours initial clair et rapide pour configurer
la destination une seule fois puis capturer des notes/tasks sans friction.

**Why this priority**: Sans configuration valide, l'application ne rend aucune valeur
métier; ce flux doit donc être guidé et bloquant sur les actions non disponibles.

**Independent Test**: Sur une installation neuve, l'utilisateur ouvre l'app,
configure un dossier valide, puis ajoute une quick note avec succès sans chercher
manuellement les étapes.

**Acceptance Scenarios**:

1. **Given** aucune destination n'est configurée, **When** l'utilisateur ouvre le menu de l'app, **Then** les actions de capture sont visiblement indisponibles et une action de configuration est mise en avant.
2. **Given** aucune destination n'est configurée, **When** l'utilisateur tente une capture via raccourci/menu, **Then** l'app bloque la soumission et affiche une explication orientée action pour terminer la configuration.
3. **Given** une destination valide est configurée, **When** l'utilisateur rouvre le menu, **Then** les actions de capture redeviennent disponibles sans étape supplémentaire.

---

### User Story 2 - Ajouter une note ou une task avec un minimum d'interactions (Priority: P1)

En tant qu'utilisateur fréquent, je veux saisir une quick note ou une task en très
peu d'actions pour réduire l'interruption de mon travail.

**Why this priority**: La promesse produit est la capture rapide depuis la barre de
menus; la performance UX dépend directement du nombre de clics et de validations.

**Independent Test**: Avec destination configurée, l'utilisateur ajoute une quick
note et une task en parcours courts, puis vérifie l'écriture correcte dans la note
du jour.

**Acceptance Scenarios**:

1. **Given** une destination valide est configurée, **When** l'utilisateur choisit `Quick Note`, saisit un texte et valide, **Then** la note est ajoutée avec confirmation claire.
2. **Given** une destination valide est configurée, **When** l'utilisateur choisit `Task`, saisit un titre et valide sans échéance, **Then** la task est ajoutée avec confirmation claire.
3. **Given** une destination valide est configurée, **When** l'utilisateur active une échéance puis valide la task, **Then** la task est ajoutée avec la date sélectionnée.

---

### User Story 3 - Comprendre l'état de l'application en un coup d'oeil (Priority: P2)

En tant qu'utilisateur, je veux savoir immédiatement si l'app est prête, bloquée,
ou en erreur pour éviter les essais inutiles et corriger vite.

**Why this priority**: Un feedback explicite réduit les erreurs répétées et améliore
la confiance, mais reste secondaire après la capacité à capturer.

**Independent Test**: L'utilisateur provoque les états non configuré, configuré,
et erreur d'écriture, puis confirme que chaque état affiche un message distinct avec
une action claire.

**Acceptance Scenarios**:

1. **Given** l'app est non configurée, **When** le menu est affiché, **Then** un statut explicite "configuration requise" est visible.
2. **Given** une erreur d'écriture survient, **When** la soumission échoue, **Then** le message d'erreur indique la cause et la prochaine action recommandée.
3. **Given** une capture réussie, **When** la confirmation est affichée, **Then** l'utilisateur voit le résultat (fichier cible) sans ambiguïté.

---

### Edge Cases

- Que se passe-t-il si le dossier configuré est supprimé ou inaccessible après une configuration initiale réussie?
- Que se passe-t-il si l'utilisateur annule le sélecteur de dossier lors du parcours de configuration initial?
- Que se passe-t-il si l'utilisateur soumet un texte vide ou composé uniquement d'espaces?
- Que se passe-t-il si une action de capture est déclenchée alors que l'état de configuration vient de changer?
- Que se passe-t-il si deux captures successives sont lancées rapidement depuis le menu?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: L'application MUST détecter au démarrage et à chaque ouverture du menu si la destination est configurée et accessible.
- **FR-002**: Tant qu'aucune destination valide n'est configurée, les actions `Quick Note` et `Task` MUST être indisponibles visuellement et fonctionnellement.
- **FR-003**: Quand la configuration est manquante, l'application MUST mettre en avant une action unique et explicite pour configurer la destination.
- **FR-004**: Après configuration réussie, les actions de capture MUST devenir disponibles sans redémarrage de l'application.
- **FR-005**: Le flux de création `Quick Note` MUST permettre une soumission en parcours court avec confirmation de réussite.
- **FR-006**: Le flux de création `Task` MUST permettre une soumission en parcours court avec titre obligatoire et échéance optionnelle.
- **FR-007**: Toute tentative de soumission invalide (champ obligatoire vide, destination indisponible, erreur d'écriture) MUST afficher un message clair décrivant la cause et l'action corrective.
- **FR-008**: En cas d'échec de soumission, le contenu saisi MUST être conservé pour éviter la ressaisie.
- **FR-009**: L'interface MUST afficher un état global compréhensible de disponibilité de l'app (prête, configuration requise, erreur récente).
- **FR-010**: L'app MUST limiter le nombre d'étapes nécessaires pour atteindre la première capture réussie après installation.
- **FR-011**: Le comportement d'écriture dans la note journalière existante MUST rester inchangé en contenu fonctionnel.

### Key Entities *(include if feature involves data)*

- **Configuration State**: État utilisateur de la destination (non configurée, configurée valide, configurée invalide/inaccessible).
- **Capture Action Availability**: État d'activation des actions de capture dans l'interface selon la configuration.
- **Capture Feedback**: Résultat présenté à l'utilisateur après tentative de capture (succès, échec, guidance corrective).

## Assumptions

- Les deux actions principales de productivité restent `Quick Note` et `Task`.
- La destination Obsidian est une dépendance obligatoire avant toute capture.
- La réduction de clics vise surtout le flux initial (première configuration) et les flux de capture récurrents.
- Les formats de sortie markdown existants restent conformes et hors périmètre de changement fonctionnel.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 95% des nouveaux utilisateurs réalisent une première capture réussie en moins de 90 secondes après ouverture initiale de l'app.
- **SC-002**: 100% des tentatives de capture avec configuration absente affichent des actions indisponibles et un message de configuration explicite.
- **SC-003**: Le nombre médian d'interactions utilisateur pour ajouter une quick note réussie n'excède pas 3 interactions après configuration.
- **SC-004**: Au moins 90% des utilisateurs déclarent comprendre immédiatement l'état de l'application (prête/non prête) lors d'une évaluation UX.
- **SC-005**: Les échecs de capture liés à des prérequis manquants diminuent d'au moins 50% par rapport au flux actuel.
