import XCTest
@testable import ObsidianQuickNoteTask

final class DailyNoteWriterIntegrationTests: XCTestCase {
    private func makeTempDir() throws -> URL {
        let base = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: base, withIntermediateDirectories: true)
        return base
    }

    func testCreatesDailyFileWhenMissingForQuickNote() throws {
        let dir = try makeTempDir()
        let writer = DailyNoteWriter()
        let date = Calendar(identifier: .gregorian).date(from: DateComponents(year: 2026, month: 3, day: 3))!

        let target = try writer.appendQuickNote(text: "Premiere note", destinationDirectory: dir, date: date)

        XCTAssertTrue(FileManager.default.fileExists(atPath: target.path))
        let content = try String(contentsOf: target, encoding: .utf8)
        XCTAssertEqual(content, "### Quick Note\nPremiere note")
    }

    func testAppendsAtEndWithVisualSeparator() throws {
        let dir = try makeTempDir()
        let writer = DailyNoteWriter()
        let date = Calendar(identifier: .gregorian).date(from: DateComponents(year: 2026, month: 3, day: 3))!

        _ = try writer.appendQuickNote(text: "Note A", destinationDirectory: dir, date: date)
        let target = try writer.appendQuickNote(text: "Note B", destinationDirectory: dir, date: date)

        let content = try String(contentsOf: target, encoding: .utf8)
        XCTAssertTrue(content.contains("Note A\n\n---\n\n### Quick Note\nNote B"))
    }

    func testTaskIsAppendedFromPipeline() throws {
        let dir = try makeTempDir()
        let writer = DailyNoteWriter()
        let date = Calendar(identifier: .gregorian).date(from: DateComponents(year: 2026, month: 3, day: 3))!

        let target = try writer.appendTask(title: "Faire revue", dueDate: nil, destinationDirectory: dir, date: date)
        let content = try String(contentsOf: target, encoding: .utf8)
        XCTAssertTrue(content.contains("- [ ] Faire revue"))
    }

    func testTaskWithSelectedDueDateIsAppended() throws {
        let dir = try makeTempDir()
        let writer = DailyNoteWriter()
        let calendar = Calendar(identifier: .gregorian)
        let currentDate = calendar.date(from: DateComponents(year: 2026, month: 3, day: 3))!
        let dueDate = calendar.date(from: DateComponents(year: 2026, month: 3, day: 10))!

        let target = try writer.appendTask(title: "Task date picker", dueDate: dueDate, destinationDirectory: dir, date: currentDate)
        let content = try String(contentsOf: target, encoding: .utf8)
        XCTAssertTrue(content.contains("- [ ] Task date picker 📅 2026-03-10"))
    }

    func testTaskUsesUpdatedSelectedDueDateBeforeSubmit() throws {
        let dir = try makeTempDir()
        let writer = DailyNoteWriter()
        let calendar = Calendar(identifier: .gregorian)
        let currentDate = calendar.date(from: DateComponents(year: 2026, month: 3, day: 3))!
        let firstSelectedDate = calendar.date(from: DateComponents(year: 2026, month: 3, day: 10))!
        let finalSelectedDate = calendar.date(from: DateComponents(year: 2026, month: 3, day: 11))!

        _ = try writer.appendTask(title: "Task initial date", dueDate: firstSelectedDate, destinationDirectory: dir, date: currentDate)
        let target = try writer.appendTask(title: "Task updated date", dueDate: finalSelectedDate, destinationDirectory: dir, date: currentDate)

        let content = try String(contentsOf: target, encoding: .utf8)
        XCTAssertTrue(content.contains("- [ ] Task updated date 📅 2026-03-11"))
    }

    func testTaskAppendBehaviorUnchangedWhenDueDatePresent() throws {
        let dir = try makeTempDir()
        let writer = DailyNoteWriter()
        let calendar = Calendar(identifier: .gregorian)
        let currentDate = calendar.date(from: DateComponents(year: 2026, month: 3, day: 3))!
        let dueDate = calendar.date(from: DateComponents(year: 2026, month: 3, day: 12))!

        _ = try writer.appendQuickNote(text: "Before task", destinationDirectory: dir, date: currentDate)
        let target = try writer.appendTask(title: "Task after note", dueDate: dueDate, destinationDirectory: dir, date: currentDate)

        let content = try String(contentsOf: target, encoding: .utf8)
        XCTAssertTrue(content.contains("Before task\n\n---\n\n- [ ] Task after note 📅 2026-03-12"))
    }
}
