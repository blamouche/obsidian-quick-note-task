import Foundation

public struct MarkdownFormatter {
    public let separator = "\n\n---\n\n"

    public init() {}

    public func formatQuickNote(text: String) -> String {
        "### Quick Note\n\(text)"
    }

    public func formatTask(title: String, dueDate: Date?, recurrenceRule: String? = nil) -> String {
        let normalizedRecurrence = recurrenceRule?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let recurrenceToken: String
        if let normalizedRecurrence, !normalizedRecurrence.isEmpty {
            recurrenceToken = " 🔁 \(normalizedRecurrence)"
        } else {
            recurrenceToken = ""
        }

        guard let dueDate else {
            return "- [ ] \(title)\(recurrenceToken)"
        }
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"
        return "- [ ] \(title) 📅 \(formatter.string(from: dueDate))\(recurrenceToken)"
    }
}
