# Contract: Capture Feedback and Recovery

## Scope
- Applies to both `Quick Note` and `Task` capture flows.

## Required Outcomes

### Success
- Show concise confirmation.
- Include destination file context.
- Clear transient draft state.

### Blocked (Prerequisite Missing)
- Triggered when destination is missing or invalid before submission.
- Must explain why action is unavailable.
- Must provide direct corrective action path (configure/reconfigure destination).

### Error (Write or Validation Failure)
- Show explicit error summary and next action recommendation.
- Preserve user-entered content to support retry without full re-entry.
- Do not expose sensitive content in logs or generic system notifications.

## Input Constraints
- Empty or whitespace-only required fields are rejected with actionable message.
- Invalid destination path states are treated as blocked/error based on detection point.

## Regression Guarantees
- Markdown output format for successful captures remains unchanged.
- Existing append-to-daily-note behavior remains unchanged except for improved UX signaling.
