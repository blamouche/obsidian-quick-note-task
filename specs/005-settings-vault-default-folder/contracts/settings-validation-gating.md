# Contract: Settings Validation and Capture Gating

## Scope
- Applies to `Quick Note` and `Task` capture availability.

## Valid State
- Conditions:
  - Vault is configured and accessible.
  - Default note folder is configured, accessible, and inside selected vault.
- Outcome:
  - Capture actions are enabled.

## Invalid States

### Invalid Vault
- Triggered when vault is missing or inaccessible.
- Outcome:
  - Capture actions are disabled.
  - Blocking reason is explicit and points to Settings.

### Invalid Default Folder
- Triggered when default folder is missing, inaccessible, or outside vault.
- Outcome:
  - Capture actions are disabled.
  - Blocking reason is explicit and points to Settings.

### Mixed Invalid State
- Triggered when vault and folder are both invalid.
- Outcome:
  - Capture actions are disabled until both are corrected.

## Behavioral Guarantees
- Disabled capture actions must not execute write logic.
- Availability state refreshes after Settings updates without app restart.
- Existing valid configuration keeps capture flow unchanged.
