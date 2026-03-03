import Foundation

public struct TaskEntry: Sendable {
    public let title: String
    public let dueDate: Date?

    public init(title: String, dueDate: Date? = nil) {
        self.title = title
        self.dueDate = dueDate
    }
}

public struct TaskInputState: Sendable {
    public let title: String
    public let dueDateEnabled: Bool
    public let selectedDueDate: Date?

    public init(title: String, dueDateEnabled: Bool, selectedDueDate: Date?) {
        self.title = title
        self.dueDateEnabled = dueDateEnabled
        self.selectedDueDate = selectedDueDate
    }

    public var normalizedDueDate: Date? {
        dueDateEnabled ? selectedDueDate : nil
    }
}
