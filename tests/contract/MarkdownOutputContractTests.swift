import XCTest
@testable import ObsidianQuickNoteTask

final class MarkdownOutputContractTests: XCTestCase {
    func testTaskContractStartsWithUncheckedBox() {
        let formatter = MarkdownFormatter()
        let output = formatter.formatTask(title: "Relire notes", dueDate: nil)
        XCTAssertTrue(output.hasPrefix("- [ ] "))
    }

    func testTaskContractDueDateSerialization() {
        let formatter = MarkdownFormatter()
        let calendar = Calendar(identifier: .gregorian)
        let date = calendar.date(from: DateComponents(year: 2026, month: 3, day: 7))!
        let output = formatter.formatTask(title: "Relire notes", dueDate: date)
        XCTAssertTrue(output.contains("📅 2026-03-07"))
    }

    func testTaskContractDueDateRemainsOptional() {
        let formatter = MarkdownFormatter()
        let output = formatter.formatTask(title: "Task sans date", dueDate: nil)
        XCTAssertFalse(output.contains("📅"))
    }

    func testTaskContractDatePickerSourcedDateSerialization() {
        let formatter = MarkdownFormatter()
        let calendar = Calendar(identifier: .gregorian)
        let date = calendar.date(from: DateComponents(year: 2026, month: 3, day: 10))!
        let output = formatter.formatTask(title: "Task picker", dueDate: date)
        XCTAssertTrue(output.hasPrefix("- [ ] "))
        XCTAssertTrue(output.contains("📅 2026-03-10"))
    }

    func testQuickNoteContractContainsHeader() {
        let formatter = MarkdownFormatter()
        let output = formatter.formatQuickNote(text: "texte")
        XCTAssertTrue(output.hasPrefix("### Quick Note"))
    }
}
