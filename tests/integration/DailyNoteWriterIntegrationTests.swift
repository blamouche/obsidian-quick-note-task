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
}
