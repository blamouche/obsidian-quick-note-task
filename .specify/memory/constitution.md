<!--
Sync Impact Report
- Version change: template -> 1.0.0
- Modified principles:
  - Principle 1 -> I. Security by Default (NON-NEGOTIABLE)
  - Principle 2 -> II. macOS Native Reliability
  - Principle 3 -> III. Test Discipline and Verification
  - Principle 4 -> IV. Least Privilege Data Handling
  - Principle 5 -> V. Simplicity, Traceability, and Maintainability
- Added sections:
  - Platform and Security Constraints
  - Development Workflow and Quality Gates
- Removed sections:
  - None
- Templates requiring updates:
  - ✅ updated: .specify/templates/plan-template.md
  - ✅ updated: .specify/templates/spec-template.md
  - ✅ updated: .specify/templates/tasks-template.md
  - ⚠ pending (folder not present): .specify/templates/commands/*.md
- Follow-up TODOs:
  - None
-->
# Obsidian Quick Note Task Constitution

## Core Principles

### I. Security by Default (NON-NEGOTIABLE)
All code paths MUST fail closed and validate all external input, including note
content, filenames, plugin settings, environment values, and command arguments.
Secrets MUST be stored only in macOS Keychain or explicitly approved secure
stores, never in source, logs, or plaintext config. Any dependency addition
MUST include a known-vulnerability check before merge.
Rationale: the project handles user notes and local automation, so compromise
impact is high even for local-first workflows.

### II. macOS Native Reliability
Features targeting macOS MUST use stable platform capabilities and support the
lowest supported macOS version documented in each feature plan. Automations
MUST handle filesystem sandbox nuances, permission prompts, and path edge cases
without data loss. Any shell integration MUST be POSIX-safe and compatible with
default `zsh` behavior on macOS.
Rationale: predictable behavior on developer and end-user macOS systems is a
core product requirement.

### III. Test Discipline and Verification
Every feature MUST define executable acceptance criteria and include automated
tests for critical flows: note capture, task extraction, parsing, and failure
handling. Security-relevant logic (input validation, credential usage, command
execution) MUST be covered by negative tests. Merges MUST be blocked on failing
tests and static analysis checks.
Rationale: quick-note automation changes frequently and regressions are often
silent without robust tests.

### IV. Least Privilege Data Handling
Collection and processing of note data MUST be minimal, purpose-bound, and
auditable. Logs MUST exclude raw note content unless explicitly redacted and
approved for debugging. File operations MUST be restricted to user-approved
vault paths, and destructive operations MUST require explicit confirmation.
Rationale: privacy and trust depend on minimizing data exposure by default.

### V. Simplicity, Traceability, and Maintainability
Designs MUST prefer small, composable units with explicit contracts over hidden
side effects. Each change MUST include traceable rationale in specs, plans,
tasks, and commit history. New complexity requires written justification in the
implementation plan's complexity tracking section.
Rationale: the project remains maintainable only when behavior and decisions are
easy to understand and review.

## Platform and Security Constraints

- Runtime and tooling MUST work on macOS with default developer tools and `zsh`.
- External binaries and scripts MUST pin versions or document compatibility
  windows.
- Network calls MUST have explicit timeout, retry strategy, and error handling.
- Dependencies MUST be minimized; remove unused packages during each feature
  cycle.
- Any local cache or persisted artifact MUST have a defined retention policy.

## Development Workflow and Quality Gates

1. Specification:
   all features start with explicit user scenarios, security considerations, and
   macOS compatibility notes.
2. Planning:
   implementation plans MUST pass the constitution check before research/design
   and again before implementation.
3. Execution:
   tasks MUST include testing, validation, and security-hardening work items, not
   only functional delivery.
4. Review:
   at least one reviewer verifies principles compliance, test evidence, and
   security impact.
5. Release readiness:
   regressions, unresolved high-severity security issues, or undocumented macOS
   behavior changes block release.

## Governance

This constitution supersedes conflicting local process notes for engineering
execution and review. Amendments require:
1. a documented proposal describing changed principles/sections,
2. explicit impact analysis on templates and active workflows,
3. maintainer approval, and
4. synchronized updates to dependent artifacts in the same change set.

Versioning policy:
- MAJOR for incompatible principle removals/redefinitions.
- MINOR for new principles/sections or materially expanded obligations.
- PATCH for clarifications, wording fixes, or non-semantic edits.

Compliance review expectations:
- Every plan and PR MUST include a constitution compliance check.
- Non-compliance MUST be remediated before merge or tracked with time-bounded
  waiver approved by a maintainer.

**Version**: 1.0.0 | **Ratified**: 2026-03-03 | **Last Amended**: 2026-03-03
