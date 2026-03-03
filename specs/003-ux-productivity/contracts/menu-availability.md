# Contract: Menu Availability and Setup Gating

## Trigger
- User opens menu bar app menu.

## States

### State A: Destination not configured
- `Quick Note`: disabled.
- `Task`: disabled.
- `Settings` (or equivalent setup action): enabled and highlighted as next step.
- Status message: explicit setup required guidance.

### State B: Destination configured and valid
- `Quick Note`: enabled.
- `Task`: enabled.
- `Settings`: enabled.
- Status message: app ready for capture.

### State C: Destination configured but invalid/inaccessible
- `Quick Note`: disabled.
- `Task`: disabled.
- `Settings`: enabled for recovery.
- Status message: explains issue and recommends reconfiguration.

## Behavioral Guarantees
- Disabled actions must not execute capture logic.
- Keyboard shortcuts mapped to disabled actions must also be blocked.
- Availability state must refresh after settings changes without app restart.
