# Contract: Visual Presentation Consistency

## Trigger
- User opens status menu, quick note window, task window, or destination settings window.

## Required Outcomes

### Typography and Hierarchy
- Titles, labels, inputs, and actions expose a clear visual hierarchy.
- Typography remains consistent for equivalent roles across windows.

### Spacing and Density
- Window paddings and inter-component spacing follow a consistent rhythm.
- Layout remains readable at supported window sizes without overlap.

### State Signaling
- Active, disabled, success, and error states are visually distinct.
- Disabled state is understandable with cues beyond color alone.

## Behavioral Guarantees
- Visual refresh must not alter command availability logic.
- Visual refresh must not alter markdown output behavior.
- Existing focus order and keyboard navigation remain functional.
