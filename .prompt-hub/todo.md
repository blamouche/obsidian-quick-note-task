# Todo

## Plan
- [x] Ajouter la gestion du raccourci clavier `⌘V` dans les modales `Quick Note` et `New note`.
- [x] Garder le collage en texte brut (sans style) lors de ce raccourci.
- [x] Compiler l’app pour valider.
- [x] Mettre à jour traçabilité `.prompt-hub`.

## Review
- Ajout d’un monitor clavier local pendant les modales `Quick Note` et `New note`.
- `⌘V` déclenche explicitement `pasteAsPlainText` sur le `NSTextView` actif.
- Nettoyage du monitor à la fermeture/validation/annulation de la modale.
- Validation: `swift build` OK.
