import Foundation

public enum TaskToggleServiceError: Error, LocalizedError {
    case missingVault
    case sourceOutsideVault
    case unableToUpdateSource

    public var errorDescription: String? {
        switch self {
        case .missingVault:
            return "Vault is not configured."
        case .sourceOutsideVault:
            return "Task source is outside configured vault."
        case .unableToUpdateSource:
            return "Unable to update source markdown file."
        }
    }
}

public final class TaskToggleService {
    private let writer: DailyNoteWriter
    private let scanner: VaultTaskScanner

    public init(writer: DailyNoteWriter = .init(),
                scanner: VaultTaskScanner = .init()) {
        self.writer = writer
        self.scanner = scanner
    }

    public func toggleComplete(task: DropdownTaskItem, vaultURL: URL?) -> TaskToggleResult {
        guard let vaultURL else {
            return TaskToggleResult(
                completionUpdated: false,
                recurrenceRescheduled: false,
                errorType: .writeFailure,
                userMessage: "Vault is not configured."
            )
        }

        guard Validation.isContained(task.source.fileURL, in: vaultURL) else {
            return TaskToggleResult(
                completionUpdated: false,
                recurrenceRescheduled: false,
                errorType: .staleReference,
                userMessage: "Task source is outside configured vault."
            )
        }

        do {
            let completedLine = markCompleted(line: task.source.rawLine)
            try writer.replaceTaskLine(
                fileURL: task.source.fileURL,
                vaultRoot: vaultURL,
                lineNumber: task.source.lineNumber,
                expectedRawLine: task.source.rawLine,
                replacementLine: completedLine
            )
        } catch DailyNoteWriterError.staleTaskReference {
            return TaskToggleResult(
                completionUpdated: false,
                recurrenceRescheduled: false,
                errorType: .staleReference,
                userMessage: "Task changed in markdown, please reopen menu and try again."
            )
        } catch {
            return TaskToggleResult(
                completionUpdated: false,
                recurrenceRescheduled: false,
                errorType: .writeFailure,
                userMessage: "Failed to update markdown task state."
            )
        }

        guard let recurrence = task.recurrence else {
            return TaskToggleResult(
                completionUpdated: true,
                recurrenceRescheduled: false,
                errorType: .none,
                userMessage: "Task completed."
            )
        }

        guard let nextDueDate = scanner.nextDueDate(from: recurrence, baseDate: task.dueDate) else {
            return TaskToggleResult(
                completionUpdated: true,
                recurrenceRescheduled: false,
                errorType: .invalidRecurrence,
                userMessage: "Task completed, but recurrence rule is invalid."
            )
        }

        do {
            let nextLine = nextOccurrenceLine(from: task, nextDueDate: nextDueDate, recurrence: recurrence)
            let completedLine = markCompleted(line: task.source.rawLine)
            try writer.insertTaskLineAfter(
                fileURL: task.source.fileURL,
                vaultRoot: vaultURL,
                lineNumber: task.source.lineNumber,
                expectedRawLine: completedLine,
                lineToInsert: nextLine
            )
            return TaskToggleResult(
                completionUpdated: true,
                recurrenceRescheduled: true,
                errorType: .none,
                userMessage: "Task completed and recurrence scheduled."
            )
        } catch {
            return TaskToggleResult(
                completionUpdated: true,
                recurrenceRescheduled: false,
                errorType: .invalidRecurrence,
                userMessage: "Task completed, but next recurrence could not be saved."
            )
        }
    }

    private func markCompleted(line: String) -> String {
        if let range = line.range(of: "- [ ]") {
            var copy = line
            copy.replaceSubrange(range, with: "- [x]")
            return copy
        }
        return line
    }

    private func nextOccurrenceLine(from task: DropdownTaskItem,
                                    nextDueDate: Date,
                                    recurrence: RecurrenceDescriptor) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"

        var base = "- [ ] \(task.title) 📅 \(formatter.string(from: nextDueDate))"
        if let normalizedRule = normalizedRecurrenceRule(for: recurrence) {
            base += " 🔁 \(normalizedRule)"
        }

        return base
    }

    private func normalizedRecurrenceRule(for recurrence: RecurrenceDescriptor) -> String? {
        guard let frequency = recurrence.frequency else {
            return nil
        }

        switch frequency {
        case .daily:
            return "every day"
        case .weekday:
            return "every weekday"
        case .weekly:
            return "every week"
        case .monthly:
            return "every month"
        case .yearly:
            return "every year"
        case .customDays(let days):
            return "every \(days) days"
        }
    }
}
