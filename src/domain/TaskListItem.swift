import Foundation

public struct TaskSourceReference: Equatable {
    public let fileURL: URL
    public let lineNumber: Int
    public let rawLine: String

    public init(fileURL: URL, lineNumber: Int, rawLine: String) {
        self.fileURL = fileURL
        self.lineNumber = lineNumber
        self.rawLine = rawLine
    }
}

public enum RecurrenceIntervalUnit: Equatable {
    case day
    case week
    case month
    case year
}

public enum RecurrenceFrequency: Equatable {
    case daily
    case weekday
    case weekly
    case monthly
    case yearly
    case customDays(Int)
    case customInterval(Int, RecurrenceIntervalUnit)
}

public struct RecurrenceDescriptor: Equatable {
    public let rawRule: String
    public let frequency: RecurrenceFrequency?

    public init(rawRule: String, frequency: RecurrenceFrequency?) {
        self.rawRule = rawRule
        self.frequency = frequency
    }

    public var isValid: Bool {
        frequency != nil
    }
}

public struct DropdownTaskItem: Equatable, Identifiable {
    public let id: String
    public let title: String
    public let dueDate: Date
    public let isOverdue: Bool
    public let source: TaskSourceReference
    public let recurrence: RecurrenceDescriptor?

    public init(id: String,
                title: String,
                dueDate: Date,
                isOverdue: Bool,
                source: TaskSourceReference,
                recurrence: RecurrenceDescriptor?) {
        self.id = id
        self.title = title
        self.dueDate = dueDate
        self.isOverdue = isOverdue
        self.source = source
        self.recurrence = recurrence
    }
}

public enum TaskToggleErrorType: Equatable {
    case none
    case writeFailure
    case staleReference
    case invalidRecurrence
}

public struct TaskToggleResult: Equatable {
    public let completionUpdated: Bool
    public let recurrenceRescheduled: Bool
    public let errorType: TaskToggleErrorType
    public let userMessage: String

    public init(completionUpdated: Bool,
                recurrenceRescheduled: Bool,
                errorType: TaskToggleErrorType,
                userMessage: String) {
        self.completionUpdated = completionUpdated
        self.recurrenceRescheduled = recurrenceRescheduled
        self.errorType = errorType
        self.userMessage = userMessage
    }
}
