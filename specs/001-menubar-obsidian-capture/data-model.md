# Data Model: Obsidian Menu Bar Capture

## CaptureEntry
- Purpose: normalized representation of any user capture before persistence.
- Fields:
  - `id`: unique identifier for traceability (UUID string)
  - `type`: enum (`quick_note`, `task`)
  - `createdAt`: local timestamp
  - `rawText`: user text payload
- Validation:
  - `rawText` must be non-empty after trimming.

## TaskEntry
- Purpose: task-specific payload used to generate Tasks-compatible markdown.
- Fields:
  - `title`: required non-empty text
  - `dueDate`: optional local date
- Validation:
  - `title` must be non-empty after trimming.
  - `dueDate` (if present) must be serialized as `YYYY-MM-DD`.

## DailyNoteFile
- Purpose: append-only daily markdown target.
- Fields:
  - `date`: local calendar date
  - `fileName`: derived as `YYYY-MM-DD - Note.md`
  - `absolutePath`: resolved under configured destination folder
- Rules:
  - Create if missing.
  - Append content only; never truncate existing file.
  - Insert visual separator before each new appended entry (except first entry in empty file).

## DestinationFolderSetting
- Purpose: persisted write destination.
- Fields:
  - `bookmarkData`: serialized macOS bookmark data
  - `lastValidatedAt`: timestamp of last successful access check
- Rules:
  - Must resolve to an existing writable local directory.
  - Invalid/unreachable setting triggers user-visible error and no write.

## Relationships
- One `DestinationFolderSetting` resolves many `DailyNoteFile` instances over time.
- Each `DailyNoteFile` contains many appended `CaptureEntry` records in chronological order.
- `TaskEntry` is a specialized payload for `CaptureEntry` where `type = task`.
