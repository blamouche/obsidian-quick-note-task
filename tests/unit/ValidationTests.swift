import XCTest
@testable import ObsidianQuickNoteTask

final class ValidationTests: XCTestCase {
    private func makeTempDir() throws -> URL {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    func testQuickNoteRejectsEmptyText() {
        XCTAssertThrowsError(try Validation.validateQuickNote("   \n")) { error in
            XCTAssertEqual(error as? ValidationError, .emptyQuickNote)
        }
    }

    func testTaskTitleRejectsEmptyText() {
        XCTAssertThrowsError(try Validation.validateTaskTitle("   \n")) { error in
            XCTAssertEqual(error as? ValidationError, .emptyTaskTitle)
        }
    }

    func testDueDateParsesExpectedISODate() throws {
        let parsed = try Validation.parseOptionalDueDate("2026-03-05")
        XCTAssertNotNil(parsed)
    }

    func testDueDateRejectsInvalidFormat() {
        XCTAssertThrowsError(try Validation.parseOptionalDueDate("05/03/2026")) { error in
            XCTAssertEqual(error as? ValidationError, .invalidDueDateFormat)
        }
    }

    func testNormalizeOptionalDueDateReturnsNilWhenDisabled() {
        let date = Calendar(identifier: .gregorian).date(from: DateComponents(year: 2026, month: 3, day: 9))
        let normalized = Validation.normalizeOptionalDueDate(selected: date, enabled: false)
        XCTAssertNil(normalized)
    }

    func testNormalizeOptionalDueDateReturnsDateWhenEnabled() {
        let date = Calendar(identifier: .gregorian).date(from: DateComponents(year: 2026, month: 3, day: 9))
        let normalized = Validation.normalizeOptionalDueDate(selected: date, enabled: true)
        XCTAssertEqual(normalized, date)
    }

    func testConfigurationValidationFailsWhenVaultMissing() {
        let state = Validation.validateVaultAndDefaultFolder(vaultURL: nil, defaultFolderURL: nil)

        XCTAssertFalse(state.vaultValid)
        XCTAssertEqual(state.blockingReason, .vaultMissing)
    }

    func testConfigurationValidationFailsWhenFolderOutsideVault() throws {
        let vault = try makeTempDir()
        let outside = try makeTempDir()

        let state = Validation.validateVaultAndDefaultFolder(vaultURL: vault, defaultFolderURL: outside)

        XCTAssertTrue(state.vaultValid)
        XCTAssertFalse(state.defaultFolderValid)
        XCTAssertEqual(state.blockingReason, .folderOutsideVault)
    }

    func testConfigurationValidationSucceedsWhenFolderInsideVault() throws {
        let vault = try makeTempDir()
        let folder = vault.appendingPathComponent("Inbox", isDirectory: true)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)

        let state = Validation.validateVaultAndDefaultFolder(vaultURL: vault, defaultFolderURL: folder)

        XCTAssertTrue(state.vaultValid)
        XCTAssertTrue(state.defaultFolderValid)
        XCTAssertEqual(state.blockingReason, .none)
    }

    func testSanitizeExclusionTextRemovesControlCharacters() {
        let sanitized = Validation.sanitizeExclusionText("#snooze\u{0007}")
        XCTAssertEqual(sanitized, "#snooze")
    }

    func testValidateTaskSourceFailsOutsideVault() throws {
        let vault = try makeTempDir()
        let outside = try makeTempDir()
        let file = outside.appendingPathComponent("task.md")
        FileManager.default.createFile(atPath: file.path, contents: Data(), attributes: nil)

        XCTAssertThrowsError(try Validation.validateTaskSource(fileURL: file, vaultURL: vault)) { error in
            XCTAssertEqual(error as? ValidationError, .taskSourceOutsideVault)
        }
    }
}
