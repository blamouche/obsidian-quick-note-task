import Foundation

public struct TaskEntry: Sendable {
    public let title: String
    public let dueDate: Date?

    public init(title: String, dueDate: Date? = nil) {
        self.title = title
        self.dueDate = dueDate
    }
}
