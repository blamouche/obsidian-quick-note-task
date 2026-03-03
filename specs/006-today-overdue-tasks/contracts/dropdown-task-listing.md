# Contract: Dropdown Task Listing

## Trigger
- User opens the status bar dropdown while app is running.

## Placement
- Task list section is rendered strictly between `Tasks` and `Configure settings`.

## Visibility Preconditions
- Vault configuration is valid and accessible.
- If preconditions fail, task list section is not rendered.

## Inclusion Rules
- Include only tasks that satisfy all conditions:
  - task is not completed.
  - task has an exploitable due date.
  - due date is less than or equal to current local date.
  - task text does not match configured exclusion filter.

## Exclusion Rules
- Completed tasks are never shown.
- Tasks without due date are never shown in this section.
- Future-due tasks are never shown in this section.
- Tasks matching exclusion filter are never shown.

## Refresh Guarantees
- Dropdown opening recalculates list from current vault content.
- Any task toggle action triggers list refresh from persisted markdown state.
