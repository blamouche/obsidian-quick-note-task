import Foundation

public enum CaptureType: String, Sendable {
    case quickNote = "quick_note"
    case task
}

public struct CaptureEntry: Sendable {
    public let id: UUID
    public let type: CaptureType
    public let createdAt: Date
    public let rawText: String

    public init(id: UUID = UUID(), type: CaptureType, createdAt: Date = Date(), rawText: String) {
        self.id = id
        self.type = type
        self.createdAt = createdAt
        self.rawText = rawText
    }
}
