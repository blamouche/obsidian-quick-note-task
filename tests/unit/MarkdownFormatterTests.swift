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
}
