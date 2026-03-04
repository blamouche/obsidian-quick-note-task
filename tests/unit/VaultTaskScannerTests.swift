import XCTest
@testable import ObsidianQuickNoteTask

final class VaultTaskScannerTests: XCTestCase {
    private func makeVaultWithContent(_ content: String) throws -> URL {
        let vault = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: vault, withIntermediateDirectories: true)
        let file = vault.appendingPathComponent("tasks.md")
        try content.data(using: .utf8)?.write(to: file)
        return vault
    }

    func testScanIncludesOnlyUncheckedDueTodayOrOverdue() throws {
        let content = """
- [ ] Overdue 📅 2026-03-01
- [ ] Today 📅 2026-03-03
- [ ] Future 📅 2026-03-04
- [x] Done 📅 2026-03-01
- [ ] No date
"""
        let vault = try makeVaultWithContent(content)
        let fixedDate = ISO8601DateFormatter().date(from: "2026-03-03T10:00:00Z")!
        let scanner = VaultTaskScanner(dateProvider: FixedDateProvider(fixedDate))

        let tasks = scanner.scanDueTasks(vaultURL: vault, exclusionText: nil)
        let titles = tasks.map(\.title)

        XCTAssertEqual(titles.count, 2)
        XCTAssertTrue(titles.contains("Overdue"))
        XCTAssertTrue(titles.contains("Today"))
    }

    func testScanExcludesTasksWithoutDueDateMarker() throws {
        let content = """
- [ ] No due date task
- [ ] Dated task 📅 2026-03-03
"""
        let vault = try makeVaultWithContent(content)
        let fixedDate = ISO8601DateFormatter().date(from: "2026-03-03T10:00:00Z")!
        let scanner = VaultTaskScanner(dateProvider: FixedDateProvider(fixedDate))

        let tasks = scanner.scanDueTasks(vaultURL: vault, exclusionText: nil)

        XCTAssertEqual(tasks.count, 1)
        XCTAssertEqual(tasks.first?.title, "Dated task")
    }

    func testScanAppliesExclusionFilterCaseInsensitive() throws {
        let content = """
- [ ] Keep me 📅 2026-03-03
- [ ] Skip #SNOOZE task 📅 2026-03-03
"""
        let vault = try makeVaultWithContent(content)
        let fixedDate = ISO8601DateFormatter().date(from: "2026-03-03T10:00:00Z")!
        let scanner = VaultTaskScanner(dateProvider: FixedDateProvider(fixedDate))

        let tasks = scanner.scanDueTasks(vaultURL: vault, exclusionText: "#snooze")

        XCTAssertEqual(tasks.count, 1)
        XCTAssertEqual(tasks.first?.title, "Keep me")
    }

    func testScanAppliesExclusionFilterOnFullTaskLine() throws {
        let content = """
- [ ] Keep me 📅 2026-03-03
- [ ] Recurring task 📅 2026-03-03 🔁 every day
"""
        let vault = try makeVaultWithContent(content)
        let fixedDate = ISO8601DateFormatter().date(from: "2026-03-03T10:00:00Z")!
        let scanner = VaultTaskScanner(dateProvider: FixedDateProvider(fixedDate))

        let tasks = scanner.scanDueTasks(vaultURL: vault, exclusionText: "every day")

        XCTAssertEqual(tasks.count, 1)
        XCTAssertEqual(tasks.first?.title, "Keep me")
    }

    func testRecurrenceParsingAndNextDate() {
        let scanner = VaultTaskScanner()
        let recurrence = scanner.parseRecurrence(from: "- [ ] Task 📅 2026-03-03 🔁 every week")

        XCTAssertNotNil(recurrence)
        XCTAssertEqual(recurrence?.frequency, .weekly)

        let baseDate = ISO8601DateFormatter().date(from: "2026-03-03T00:00:00Z")!
        let nextDate = scanner.nextDueDate(from: recurrence!, baseDate: baseDate)
        let expected = ISO8601DateFormatter().date(from: "2026-03-10T00:00:00Z")!
        XCTAssertEqual(nextDate, expected)
    }

    func testWeekdayRecurrenceSkipsWeekend() {
        let scanner = VaultTaskScanner()
        let recurrence = scanner.parseRecurrence(from: "- [ ] Task 📅 2026-03-06 🔁 every weekday")

        XCTAssertNotNil(recurrence)
        XCTAssertEqual(recurrence?.frequency, .weekday)

        let friday = ISO8601DateFormatter().date(from: "2026-03-06T00:00:00Z")!
        let nextDate = scanner.nextDueDate(from: recurrence!, baseDate: friday)
        let expectedMonday = ISO8601DateFormatter().date(from: "2026-03-09T00:00:00Z")!
        XCTAssertEqual(nextDate, expectedMonday)
    }

    func testWeekdayRecurrenceParsingHandlesSpacingAndPluralVariants() {
        let scanner = VaultTaskScanner()

        let withExtraSpaces = scanner.parseRecurrence(from: "- [ ] Task 📅 2026-03-06 🔁 every   weekday")
        XCTAssertEqual(withExtraSpaces?.frequency, .weekday)

        let pluralVariant = scanner.parseRecurrence(from: "- [ ] Task 📅 2026-03-06 🔁 every weekdays")
        XCTAssertEqual(pluralVariant?.frequency, .weekday)
    }
}
