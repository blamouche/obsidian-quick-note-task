# Contract: Markdown Output

## Target File
- Path pattern: `{destination}/YYYY-MM-DD - Note.md`
- Date basis: local system date at submit time.

## Visual Separator
- Separator token between appended entries: `---`
- Physical representation when appending to non-empty file:
  - blank line
  - `---`
  - blank line

## Quick Note Entry Format
- Output block:
  - `### Quick Note`
  - raw user text on following line(s)
- Example:
```markdown
### Quick Note
Brainstorm: simplifier le flux d'ajout de tâches.
```

## Task Entry Format
- Without due date:
```markdown
- [ ] Finaliser le résumé hebdomadaire
```
- With due date:
```markdown
- [ ] Finaliser le résumé hebdomadaire 📅 2026-03-05
```

## Compatibility Rules
- Tasks MUST start with `- [ ]`.
- Due date MUST be serialized as `YYYY-MM-DD`.
- Output MUST remain valid markdown text and readable in plain Obsidian editor.
