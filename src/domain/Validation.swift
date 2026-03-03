import Foundation

public enum ValidationError: Error, Equatable, LocalizedError {
    case emptyQuickNote
    case emptyTaskTitle
    case invalidDueDateFormat

    public var errorDescription: String? {
        switch self {
        case .emptyQuickNote:
            return "Quick note text cannot be empty."
        case .emptyTaskTitle:
            return "Task title cannot be empty."
        case .invalidDueDateFormat:
            return "Due date must use YYYY-MM-DD format."
        }
    }
}

public enum Validation {
    public static func validateQuickNote(_ text: String) throws -> String {
        let normalized = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalized.isEmpty else { throw ValidationError.emptyQuickNote }
        return normalized
    }

    public static func validateTaskTitle(_ title: String) throws -> String {
        let normalized = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalized.isEmpty else { throw ValidationError.emptyTaskTitle }
        return normalized
    }

    public static func parseOptionalDueDate(_ input: String?) throws -> Date? {
        guard let input, !input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return nil
        }
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"

        guard let date = formatter.date(from: input) else {
            throw ValidationError.invalidDueDateFormat
        }
        return date
    }
}
