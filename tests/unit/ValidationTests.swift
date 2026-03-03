import XCTest
@testable import ObsidianQuickNoteTask

final class ValidationTests: XCTestCase {
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
}
