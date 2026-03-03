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
}
