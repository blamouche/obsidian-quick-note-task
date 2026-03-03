import XCTest
@testable import ObsidianQuickNoteTask

final class DailyNotePathResolverTests: XCTestCase {
    func testFileNameFollowsExpectedPattern() {
        let resolver = DailyNotePathResolver()
        let calendar = Calendar(identifier: .gregorian)
        let components = DateComponents(calendar: calendar, year: 2026, month: 3, day: 3)
        let date = calendar.date(from: components)!

        XCTAssertEqual(resolver.fileName(for: date, calendar: calendar), "2026-03-03 - Note.md")
    }
}
