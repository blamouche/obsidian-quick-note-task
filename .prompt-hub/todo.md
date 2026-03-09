# Todo

## Plan
- [x] Forcer le champ texte de la modale `New note` en mode texte brut (paste sans mise en forme).
- [x] Appliquer le même comportement au champ `Quick Note` pour cohérence UX.
- [x] Compiler pour valider les changements.
- [x] Mettre à jour la section review et la mémoire.

## Review
- `NSTextView` de `New note` et `Quick Note` configurés en texte brut (`isRichText = false`, `importsGraphics = false`).
- Substitutions automatiques désactivées pour préserver le contenu collé tel quel.
- Validation: `swift build` OK.
