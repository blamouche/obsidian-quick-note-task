# Feature Specification: UI Visual Refresh

**Feature Branch**: `004-ui-visual-refresh`  
**Created**: 2026-03-03  
**Status**: Draft  
**Input**: User description: "crée une spec 004 pour amélioration de l'UI. Tu es un expert des UI modernes et attractives. L'app doit être jolie à utiliser, meilleur typo, meilleure tailles, espacements, couleurs modernes. Retirer l'icone moche du dossier dans les fenêtres."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Lecture et saisie plus agréables (Priority: P1)

En tant qu'utilisateur quotidien, je veux une typographie plus lisible et des tailles
cohérentes pour lire et saisir mes quick notes/tasks sans fatigue visuelle.

**Why this priority**: La lisibilité impacte directement chaque interaction, sur
chaque ouverture de fenêtre; c'est la valeur UX la plus immédiate.

**Independent Test**: Ouvrir les fenêtres Quick Note et Task, puis vérifier que la
hiérarchie visuelle (titre, labels, champs, actions) est claire et homogène sans
changer la logique fonctionnelle.

**Acceptance Scenarios**:

1. **Given** la fenêtre de capture est ouverte, **When** l'utilisateur visualise les textes et champs, **Then** les styles typographiques sont harmonisés et lisibles à première lecture.
2. **Given** la fenêtre de capture est ouverte, **When** l'utilisateur compare les éléments principaux (titre, labels, champs, boutons), **Then** les tailles suivent une hiérarchie cohérente et stable.
3. **Given** une saisie en cours, **When** l'utilisateur parcourt les champs au clavier, **Then** la mise en forme reste claire et ne gêne pas la complétion rapide.

---

### User Story 2 - Interface moderne et équilibrée (Priority: P1)

En tant qu'utilisateur, je veux une interface visuellement moderne avec des
espacements réguliers et une palette couleur claire pour percevoir l'application
comme soignée et agréable.

**Why this priority**: Une UI moderne et équilibrée renforce la confiance produit et
réduit la friction cognitive dans les flux rapides.

**Independent Test**: Ouvrir tous les écrans de l'app (menu barre, Quick Note,
Task, configuration) et confirmer une cohérence visuelle globale des espacements,
couleurs d'accent et états interactifs.

**Acceptance Scenarios**:

1. **Given** l'utilisateur navigue entre les fenêtres de l'app, **When** il compare les marges et espacements, **Then** les rythmes d'espacement sont constants et non tassés.
2. **Given** des actions disponibles et indisponibles sont affichées, **When** l'utilisateur observe les couleurs et contrastes, **Then** l'état de chaque action est compréhensible sans ambiguïté.
3. **Given** un message de feedback (succès/erreur), **When** il est présenté à l'utilisateur, **Then** la couleur et la hiérarchie visuelle aident à identifier rapidement le type de message.

---

### User Story 3 - Fenêtres de configuration visuellement épurées (Priority: P2)

En tant qu'utilisateur, je veux supprimer l'icône dossier jugée inesthétique dans les
fenêtres afin d'avoir une expérience plus propre et moins datée.

**Why this priority**: Cette amélioration est ciblée mais visible; elle améliore la
perception qualité sans modifier le coeur fonctionnel.

**Independent Test**: Ouvrir les fenêtres concernées par la sélection ou l'affichage
du dossier, puis vérifier que l'icône dossier n'apparaît plus et que l'action reste
clairement compréhensible.

**Acceptance Scenarios**:

1. **Given** la fenêtre de configuration de destination est ouverte, **When** l'utilisateur consulte la zone dossier, **Then** aucune icône dossier décorative n'est affichée.
2. **Given** une fenêtre de capture affiche l'accès au dossier de destination, **When** l'utilisateur regarde la commande associée, **Then** l'icône dossier inesthétique est absente tout en conservant un libellé explicite.
3. **Given** l'utilisateur doit changer de dossier, **When** il lance l'action de sélection, **Then** le flux de choix de dossier reste inchangé malgré la suppression visuelle de l'icône.

---

### Edge Cases

- Que se passe-t-il si la fenêtre est redimensionnée à une taille réduite (pas de chevauchement texte/champs) ?
- Que se passe-t-il si les textes localisés sont plus longs (français/anglais) et risquent de casser l'alignement ?
- Que se passe-t-il si l'utilisateur active des préférences système de contraste élevé ?
- Que se passe-t-il si une action est désactivée: son état reste-t-il lisible sans dépendre uniquement de la couleur ?
- Que se passe-t-il si la suppression de l'icône dossier retire aussi un repère important pour comprendre l'action ?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: L'application MUST appliquer une hiérarchie typographique cohérente entre titres, libellés, champs et actions sur les fenêtres de capture et de configuration.
- **FR-002**: L'application MUST améliorer la lisibilité des champs de saisie via des tailles de texte et espacements internes cohérents.
- **FR-003**: L'application MUST harmoniser les espacements verticaux et horizontaux des composants interactifs sur toutes les fenêtres principales.
- **FR-004**: L'application MUST utiliser une palette visuelle moderne avec distinctions explicites entre états neutre, actif, succès, erreur et désactivé.
- **FR-005**: Les états désactivés MUST rester compréhensibles même sans perception des couleurs.
- **FR-006**: Les améliorations visuelles MUST préserver les flux existants de capture quick note, capture task et configuration de destination.
- **FR-007**: Les fenêtres de configuration et de capture MUST supprimer l'icône dossier décorative jugée inesthétique.
- **FR-008**: La suppression de l'icône dossier MUST conserver un libellé/action explicite pour sélectionner ou changer le dossier.
- **FR-009**: Les textes et composants MUST rester lisibles et non tronqués sur les tailles de fenêtre supportées.
- **FR-010**: L'expérience visuelle MUST rester cohérente entre ouverture initiale, états de réussite et états d'erreur.

### Key Entities *(include if feature involves data)*

- **UI Visual Style**: Ensemble des règles visuelles utilisateur (typographie, tailles, espacements, palette d'états) appliquées à l'interface.
- **Window Presentation State**: État d'affichage des fenêtres (normale, erreur, action désactivée) qui influence la hiérarchie et le feedback visuel.
- **Destination Access Cue**: Élément textuel/actionnel permettant d'indiquer et modifier le dossier cible sans recourir à l'icône dossier décorative.

## Assumptions

- Le périmètre concerne uniquement l'apparence et l'ergonomie visuelle, pas le comportement métier de capture.
- Les fenêtres concernées sont le menu barre, la capture Quick Note, la capture Task et la configuration de destination.
- Le style visuel final doit rester sobre et professionnel, sans surcharge d'ornements.
- Le retrait de l'icône dossier vise les éléments décoratifs, pas les composants natifs obligatoires du sélecteur système.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Lors d'un test utilisateur interne, au moins 90% des participants jugent l'interface "plus moderne" que la version précédente.
- **SC-002**: Au moins 90% des participants identifient correctement les actions principales et leurs états (actif/désactivé) en moins de 5 secondes.
- **SC-003**: 100% des écrans couverts par la feature n'affichent plus l'icône dossier décorative ciblée.
- **SC-004**: Au moins 95% des participants déclarent une lisibilité améliorée pour la saisie de quick note/task.
- **SC-005**: Le taux de réussite des flux existants (quick note, task, configuration) reste inchangé par rapport à la version avant refresh visuel.
