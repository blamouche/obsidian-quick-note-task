import XCTest
@testable import ObsidianQuickNoteTask

final class TaskSyncIntegrationTests: XCTestCase {
    private func makeTempDir() throws -> URL {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    func testToggleCompleteMarksSourceLineAndRemovesFromScan() throws {
        let vault = try makeTempDir()
        let file = vault.appendingPathComponent("tasks.md")
        try "- [ ] Task A 📅 2026-03-03".data(using: .utf8)?.write(to: file)
        let fixedDate = ISO8601DateFormatter().date(from: "2026-03-03T10:00:00Z")!
        let scanner = VaultTaskScanner(dateProvider: FixedDateProvider(fixedDate))
        let toggle = TaskToggleService(scanner: scanner)

        let before = scanner.scanDueTasks(vaultURL: vault, exclusionText: nil)
        XCTAssertEqual(before.count, 1)

        let result = toggle.toggleComplete(task: before[0], vaultURL: vault)
        XCTAssertTrue(result.completionUpdated)

        let content = try String(contentsOf: file, encoding: .utf8)
        XCTAssertTrue(content.contains("- [x] Task A"))
        let after = scanner.scanDueTasks(vaultURL: vault, exclusionText: nil)
        XCTAssertTrue(after.isEmpty)
    }

    func testToggleRecurringTaskCreatesNextOccurrence() throws {
        let vault = try makeTempDir()
        let file = vault.appendingPathComponent("tasks.md")
        try "- [ ] Recur 📅 2026-03-03 🔁 every day".data(using: .utf8)?.write(to: file)
        let fixedDate = ISO8601DateFormatter().date(from: "2026-03-03T10:00:00Z")!
        let scanner = VaultTaskScanner(dateProvider: FixedDateProvider(fixedDate))
        let toggle = TaskToggleService(scanner: scanner)

        let task = scanner.scanDueTasks(vaultURL: vault, exclusionText: nil)[0]
        let result = toggle.toggleComplete(task: task, vaultURL: vault)

        XCTAssertTrue(result.completionUpdated)
        XCTAssertTrue(result.recurrenceRescheduled)

        let content = try String(contentsOf: file, encoding: .utf8)
        XCTAssertTrue(content.contains("- [x] Recur 📅 2026-03-03 🔁 every day"))
        XCTAssertTrue(content.contains("- [ ] Recur 📅 2026-03-04 🔁 every day"))
    }

    func testToggleRecurringTaskInsertsNextOccurrenceJustBelowSourceLine() throws {
        let vault = try makeTempDir()
        let file = vault.appendingPathComponent("tasks.md")
        try """
- [ ] Recur 📅 2026-03-03 🔁 every day
- [ ] Another task 📅 2026-03-03
""".data(using: .utf8)?.write(to: file)
        let fixedDate = ISO8601DateFormatter().date(from: "2026-03-03T10:00:00Z")!
        let scanner = VaultTaskScanner(dateProvider: FixedDateProvider(fixedDate))
        let toggle = TaskToggleService(scanner: scanner)

        let task = scanner.scanDueTasks(vaultURL: vault, exclusionText: nil).first { $0.title == "Recur" }!
        let result = toggle.toggleComplete(task: task, vaultURL: vault)
        XCTAssertTrue(result.completionUpdated)
        XCTAssertTrue(result.recurrenceRescheduled)

        let lines = try String(contentsOf: file, encoding: .utf8).components(separatedBy: .newlines)
        XCTAssertEqual(lines[0], "- [x] Recur 📅 2026-03-03 🔁 every day")
        XCTAssertEqual(lines[1], "- [ ] Recur 📅 2026-03-04 🔁 every day")
        XCTAssertEqual(lines[2], "- [ ] Another task 📅 2026-03-03")
    }

    func testToggleWeekdayRecurringTaskSkipsWeekend() throws {
        let vault = try makeTempDir()
        let file = vault.appendingPathComponent("tasks.md")
        try "- [ ] Recur weekday 📅 2026-03-06 🔁 every weekday".data(using: .utf8)?.write(to: file)
        let fixedDate = ISO8601DateFormatter().date(from: "2026-03-06T10:00:00Z")!
        let scanner = VaultTaskScanner(dateProvider: FixedDateProvider(fixedDate))
        let toggle = TaskToggleService(scanner: scanner)

        let task = scanner.scanDueTasks(vaultURL: vault, exclusionText: nil)[0]
        let result = toggle.toggleComplete(task: task, vaultURL: vault)

        XCTAssertTrue(result.completionUpdated)
        XCTAssertTrue(result.recurrenceRescheduled)

        let content = try String(contentsOf: file, encoding: .utf8)
        XCTAssertTrue(content.contains("- [x] Recur weekday 📅 2026-03-06 🔁 every weekday"))
        XCTAssertTrue(content.contains("- [ ] Recur weekday 📅 2026-03-09 🔁 every weekday"))
    }

    func testToggleRecurringTaskNormalizesRuleAndRemovesEmbeddedOldDateMetadata() throws {
        let vault = try makeTempDir()
        let file = vault.appendingPathComponent("tasks.md")
        try "- [ ] Check tomorrow's agenda 📅 2026-03-04 🔁 every weekday 🏁 delete 📅 2026-03-04"
            .data(using: .utf8)?
            .write(to: file)
        let fixedDate = ISO8601DateFormatter().date(from: "2026-03-04T10:00:00Z")!
        let scanner = VaultTaskScanner(dateProvider: FixedDateProvider(fixedDate))
        let toggle = TaskToggleService(scanner: scanner)

        let task = try XCTUnwrap(scanner.scanDueTasks(vaultURL: vault, exclusionText: nil).first)
        let result = toggle.toggleComplete(task: task, vaultURL: vault)

        XCTAssertTrue(result.completionUpdated)
        XCTAssertTrue(result.recurrenceRescheduled)

        let lines = try String(contentsOf: file, encoding: .utf8).components(separatedBy: .newlines)
        XCTAssertEqual(lines[0], "- [x] Check tomorrow's agenda 📅 2026-03-04 🔁 every weekday 🏁 delete 📅 2026-03-04")
        XCTAssertEqual(lines[1], "- [ ] Check tomorrow's agenda 📅 2026-03-05 🔁 every weekday")
    }

    func testToggleWithInvalidRecurrenceKeepsCompletionAndWarns() throws {
        let vault = try makeTempDir()
        let file = vault.appendingPathComponent("tasks.md")
        try "- [ ] Weird recur 📅 2026-03-03 🔁 every someday".data(using: .utf8)?.write(to: file)
        let fixedDate = ISO8601DateFormatter().date(from: "2026-03-03T10:00:00Z")!
        let scanner = VaultTaskScanner(dateProvider: FixedDateProvider(fixedDate))
        let toggle = TaskToggleService(scanner: scanner)

        let task = scanner.scanDueTasks(vaultURL: vault, exclusionText: nil)[0]
        let result = toggle.toggleComplete(task: task, vaultURL: vault)

        XCTAssertTrue(result.completionUpdated)
        XCTAssertFalse(result.recurrenceRescheduled)
        XCTAssertEqual(result.errorType, .invalidRecurrence)

        let content = try String(contentsOf: file, encoding: .utf8)
        XCTAssertTrue(content.contains("- [x] Weird recur"))
    }

    func testToggleWriteFailureKeepsTaskUnchecked() throws {
        let vault = try makeTempDir()
        let file = vault.appendingPathComponent("tasks.md")
        try "- [ ] Failing task 📅 2026-03-03".data(using: .utf8)?.write(to: file)
        let fixedDate = ISO8601DateFormatter().date(from: "2026-03-03T10:00:00Z")!
        let scanner = VaultTaskScanner(dateProvider: FixedDateProvider(fixedDate))
        let toggle = TaskToggleService(scanner: scanner)

        let task = scanner.scanDueTasks(vaultURL: vault, exclusionText: nil)[0]
        try FileManager.default.removeItem(at: file)

        let result = toggle.toggleComplete(task: task, vaultURL: vault)
        XCTAssertFalse(result.completionUpdated)
        XCTAssertEqual(result.errorType, .writeFailure)
    }
}
