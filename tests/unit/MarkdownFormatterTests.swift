import XCTest
@testable import ObsidianQuickNoteTask

final class MarkdownFormatterTests: XCTestCase {
    func testQuickNoteBlockFormatting() {
        let formatter = MarkdownFormatter()
        let output = formatter.formatQuickNote(text: "Une note rapide")
        XCTAssertEqual(output, "### Quick Note\nUne note rapide")
    }

    func testTaskFormattingWithoutDueDate() {
        let formatter = MarkdownFormatter()
        let output = formatter.formatTask(title: "Planifier sprint", dueDate: nil)
        XCTAssertEqual(output, "- [ ] Planifier sprint")
    }

    func testTaskFormattingWithDueDate() {
        let formatter = MarkdownFormatter()
        let calendar = Calendar(identifier: .gregorian)
        let date = calendar.date(from: DateComponents(year: 2026, month: 3, day: 5))!
        let output = formatter.formatTask(title: "Planifier sprint", dueDate: date)
        XCTAssertEqual(output, "- [ ] Planifier sprint 📅 2026-03-05")
    }

    func testTaskFormattingKeepsStablePrefixForCompatibility() {
        let formatter = MarkdownFormatter()
        let output = formatter.formatTask(title: "Compat task", dueDate: nil)
        XCTAssertTrue(output.hasPrefix("- [ ] "))
    }

    func testRecurrenceRuleParsingComputesNextDate() {
        let scanner = VaultTaskScanner()
        let recurrence = scanner.parseRecurrence(from: "- [ ] Task 📅 2026-03-03 🔁 every month")
        let baseDate = ISO8601DateFormatter().date(from: "2026-03-03T00:00:00Z")!
        let nextDate = scanner.nextDueDate(from: recurrence!, baseDate: baseDate)
        let expected = ISO8601DateFormatter().date(from: "2026-04-03T00:00:00Z")

        XCTAssertEqual(recurrence?.frequency, .monthly)
        XCTAssertEqual(nextDate, expected)
    }
}
