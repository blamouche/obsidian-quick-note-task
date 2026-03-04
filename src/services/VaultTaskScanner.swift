import Foundation

public final class VaultTaskScanner {
    private let dateProvider: DateProviding
    private let calendar: Calendar

    public init(dateProvider: DateProviding = SystemDateProvider(),
                calendar: Calendar = Calendar(identifier: .gregorian)) {
        self.dateProvider = dateProvider
        var utcCalendar = calendar
        utcCalendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .gmt
        self.calendar = utcCalendar
    }

    public func scanDueTasks(vaultURL: URL,
                             exclusionText: String?) -> [DropdownTaskItem] {
        guard Validation.isAccessibleDirectory(vaultURL) else {
            return []
        }

        let normalizedExclusion = Validation.sanitizeExclusionText(exclusionText)
        let today = startOfDayUTC(dateProvider.now())
        let markdownFiles = markdownFilesUnderVault(vaultURL)

        var results: [DropdownTaskItem] = []
        for fileURL in markdownFiles {
            let parsed = parseTasks(from: fileURL,
                                    vaultURL: vaultURL,
                                    today: today,
                                    exclusionText: normalizedExclusion)
            results.append(contentsOf: parsed)
        }

        return results.sorted { lhs, rhs in
            if lhs.dueDate == rhs.dueDate {
                if lhs.source.fileURL.path == rhs.source.fileURL.path {
                    return lhs.source.lineNumber < rhs.source.lineNumber
                }
                return lhs.source.fileURL.path < rhs.source.fileURL.path
            }
            return lhs.dueDate < rhs.dueDate
        }
    }

    public func parseDueDate(from text: String) -> Date? {
        let regex = try? NSRegularExpression(pattern: "📅\\s*(\\d{4}-\\d{2}-\\d{2})")
        guard let regex,
              let match = regex.firstMatch(in: text, range: NSRange(location: 0, length: text.utf16.count)),
              let range = Range(match.range(at: 1), in: text) else {
            return nil
        }

        let dateText = String(text[range])
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: dateText).map(startOfDayUTC)
    }

    public func parseRecurrence(from text: String) -> RecurrenceDescriptor? {
        let regex = try? NSRegularExpression(pattern: "🔁\\s*([^\\n]+)$")
        guard let regex,
              let match = regex.firstMatch(in: text, range: NSRange(location: 0, length: text.utf16.count)),
              let range = Range(match.range(at: 1), in: text) else {
            return nil
        }

        let raw = String(text[range]).trimmingCharacters(in: .whitespacesAndNewlines)
        let lower = raw.lowercased()

        if lower == "every day" || lower == "daily" {
            return RecurrenceDescriptor(rawRule: raw, frequency: .daily)
        }
        if lower == "every weekday" || lower == "weekdays" {
            return RecurrenceDescriptor(rawRule: raw, frequency: .weekday)
        }
        if lower == "every week" || lower == "weekly" {
            return RecurrenceDescriptor(rawRule: raw, frequency: .weekly)
        }
        if lower == "every month" || lower == "monthly" {
            return RecurrenceDescriptor(rawRule: raw, frequency: .monthly)
        }
        if lower == "every year" || lower == "yearly" {
            return RecurrenceDescriptor(rawRule: raw, frequency: .yearly)
        }

        let daysRegex = try? NSRegularExpression(pattern: "every\\s+(\\d+)\\s+days")
        if let daysRegex,
           let match = daysRegex.firstMatch(in: lower, range: NSRange(location: 0, length: lower.utf16.count)),
           let range = Range(match.range(at: 1), in: lower),
           let value = Int(lower[range]), value > 0 {
            return RecurrenceDescriptor(rawRule: raw, frequency: .customDays(value))
        }

        return RecurrenceDescriptor(rawRule: raw, frequency: nil)
    }

    public func nextDueDate(from recurrence: RecurrenceDescriptor, baseDate: Date) -> Date? {
        let base = startOfDayUTC(baseDate)
        guard let frequency = recurrence.frequency else {
            return nil
        }

        switch frequency {
        case .daily:
            return calendar.date(byAdding: .day, value: 1, to: base)
        case .weekday:
            return nextWeekday(after: base)
        case .weekly:
            return calendar.date(byAdding: .day, value: 7, to: base)
        case .monthly:
            return calendar.date(byAdding: .month, value: 1, to: base)
        case .yearly:
            return calendar.date(byAdding: .year, value: 1, to: base)
        case .customDays(let days):
            return calendar.date(byAdding: .day, value: days, to: base)
        }
    }

    private func nextWeekday(after base: Date) -> Date? {
        for offset in 1...7 {
            guard let candidate = calendar.date(byAdding: .day, value: offset, to: base) else {
                continue
            }
            let weekday = calendar.component(.weekday, from: candidate)
            if weekday >= 2 && weekday <= 6 {
                return candidate
            }
        }
        return nil
    }

    private func markdownFilesUnderVault(_ vaultURL: URL) -> [URL] {
        guard let enumerator = FileManager.default.enumerator(at: vaultURL,
                                                              includingPropertiesForKeys: [.isRegularFileKey],
                                                              options: [.skipsHiddenFiles]) else {
            return []
        }

        var results: [URL] = []
        for case let fileURL as URL in enumerator {
            guard fileURL.pathExtension.lowercased() == "md" else { continue }
            let isRegular = (try? fileURL.resourceValues(forKeys: [.isRegularFileKey]).isRegularFile) ?? false
            if isRegular {
                results.append(fileURL)
            }
        }
        return results
    }

    private func parseTasks(from fileURL: URL,
                            vaultURL: URL,
                            today: Date,
                            exclusionText: String?) -> [DropdownTaskItem] {
        guard Validation.isContained(fileURL, in: vaultURL),
              let content = try? String(contentsOf: fileURL, encoding: .utf8) else {
            return []
        }

        var results: [DropdownTaskItem] = []
        let normalizedExclusion = exclusionText.map(Validation.normalizeForSearch)
        let lines = content.components(separatedBy: .newlines)
        for (index, line) in lines.enumerated() {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard trimmed.hasPrefix("- [") else { continue }
            guard !trimmed.lowercased().hasPrefix("- [x]") else { continue }
            guard line.contains("📅") else { continue }

            guard let dueDate = parseDueDate(from: line) else {
                continue
            }
            guard dueDate <= today else {
                continue
            }

            let displayTitle = cleanedTaskTitle(from: line)
            if let normalizedExclusion, !normalizedExclusion.isEmpty,
               Validation.normalizeForSearch(line).contains(normalizedExclusion) {
                continue
            }

            let source = TaskSourceReference(fileURL: fileURL, lineNumber: index + 1, rawLine: line)
            let recurrence = parseRecurrence(from: line)
            let item = DropdownTaskItem(
                id: "\(fileURL.path)#\(index + 1)",
                title: displayTitle,
                dueDate: dueDate,
                isOverdue: dueDate < today,
                source: source,
                recurrence: recurrence
            )
            results.append(item)
        }

        return results
    }

    private func cleanedTaskTitle(from line: String) -> String {
        var title = line
        if let range = title.range(of: "- [ ]") {
            title.replaceSubrange(range, with: "")
        }

        if let dueRange = title.range(of: "📅") {
            title = String(title[..<dueRange.lowerBound])
        }

        if let recurRange = title.range(of: "🔁") {
            title = String(title[..<recurRange.lowerBound])
        }

        return title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func startOfDayUTC(_ date: Date) -> Date {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return calendar.date(from: components) ?? date
    }
}
