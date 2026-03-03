import Foundation

public struct DailyNotePathResolver {
    public init() {}

    public func fileName(for date: Date, calendar: Calendar = .current) -> String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = calendar.timeZone
        formatter.dateFormat = "yyyy-MM-dd"
        return "\(formatter.string(from: date)) - Note.md"
    }

    public func fileURL(baseDirectory: URL, date: Date, calendar: Calendar = .current) -> URL {
        baseDirectory.appendingPathComponent(fileName(for: date, calendar: calendar), isDirectory: false)
    }
}
