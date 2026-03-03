# Data Model: Today & Overdue Task Dropdown

## Dropdown Task Item
- Purpose: représenter une tâche affichée dans la dropdown pour action rapide.
- Fields:
  - `id`: identifiant stable de l'item dans la session de menu.
  - `title`: texte de la tâche.
  - `isCompleted`: booléen (toujours `false` à l'affichage initial).
  - `dueDate`: date d'échéance normalisée en date locale.
  - `isOverdue`: booléen dérivé (`dueDate < today`).
  - `source`: référence `Task Source Reference`.
  - `recurrence`: référence optionnelle `Recurrence Descriptor`.
- Validation rules:
  - `isCompleted` doit être `false` pour qu'un item soit affichable.
  - `dueDate` doit être présente et <= date locale du jour.
  - item exclu si `title` contient le texte d'exclusion actif.

## Task Exclusion Filter
- Purpose: stocker la règle de texte à exclure de la recherche dropdown.
- Fields:
  - `value`: texte libre utilisateur.
  - `isEnabled`: booléen dérivé (`value` non vide après trim).
- Validation rules:
  - le texte doit être assaini avant comparaison.
  - une valeur vide désactive le filtre.

## Task Source Reference
- Purpose: localiser de façon sûre la tâche à mettre à jour dans le bon markdown.
- Fields:
  - `filePath`: chemin absolu du fichier markdown source dans le vault.
  - `lineAnchor`: ancre de position logique de la tâche (numéro de ligne ou équivalent stable).
  - `rawTaskText`: représentation brute utilisée pour vérification d'intégrité.
- Validation rules:
  - `filePath` doit rester dans le périmètre du vault configuré.
  - l'opération de cochage doit échouer proprement si l'ancre ne correspond plus.

## Recurrence Descriptor
- Purpose: décrire la règle de récurrence portée par une tâche.
- Fields:
  - `ruleText`: expression de récurrence lue depuis la tâche.
  - `isValid`: booléen de validité après analyse.
  - `nextDueDate`: prochaine échéance calculée (optionnelle tant que non résolue).
- Validation rules:
  - `nextDueDate` doit être > date courante pour une règle valide.
  - en cas de règle invalide, `isValid=false` et aucune occurrence nouvelle n'est créée.

## Task Toggle Result
- Purpose: représenter l'issue d'une action de cochage utilisateur.
- Fields:
  - `completionUpdated`: booléen.
  - `recurrenceRescheduled`: booléen.
  - `errorType`: `none | writeFailure | staleReference | invalidRecurrence`.
  - `userMessage`: message synthétique affichable.
- Validation rules:
  - `completionUpdated=false` si l'écriture markdown échoue.
  - `recurrenceRescheduled=false` autorisé même quand `completionUpdated=true` si récurrence invalide.

## Relationships
- `Dropdown Task Item` utilise `Task Source Reference` et optionnellement `Recurrence Descriptor`.
- `Task Exclusion Filter` est appliqué à l'ensemble des `Dropdown Task Item` éligibles date/statut.
- Une action utilisateur produit un `Task Toggle Result` lié à un `Dropdown Task Item`.

## State Transitions
- Visibilité item: `hidden -> visible` quand non cochée, due <= today, non exclue, vault accessible.
- Visibilité item: `visible -> hidden` après cochage réussi.
- Récurrence: `pending -> rescheduled` quand règle valide; `pending -> failed` quand règle invalide.
- Action cochage: `idle -> applying -> success|failure`, avec refresh de la liste en sortie.
