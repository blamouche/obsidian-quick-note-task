# Contract: Task Markdown Output

## Without Due Date
```markdown
- [ ] Préparer le bilan hebdomadaire
```

## With Due Date
```markdown
- [ ] Préparer le bilan hebdomadaire 📅 2026-03-10
```

## Rules
- Prefix MUST remain `- [ ]`.
- Due date MUST be optional.
- When present, due date MUST be serialized as `YYYY-MM-DD`.
- Output MUST remain compatible with Tasks and Dataview usage.

## Regression Notes
- Tasks created without due date MUST keep prior format exactly.
- Tasks created with picker-selected date MUST only add the `📅 YYYY-MM-DD`
  suffix and MUST not alter other task tokens.
