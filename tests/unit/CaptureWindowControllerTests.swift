import XCTest
@testable import ObsidianQuickNoteTask

final class CaptureWindowControllerTests: XCTestCase {
    private final class TestLogger: Logging {
        var infoMessages: [String] = []
        var errorMessages: [String] = []

        func info(_ message: String) {
            infoMessages.append(message)
        }

        func error(_ message: String) {
            errorMessages.append(message)
        }

        func redact(_ raw: String) -> String {
            "<redacted len=\(raw.count)>"
        }
    }

    private func makeController(defaultsSuite: String, logger: Logging) -> CaptureWindowController {
        let defaults = UserDefaults(suiteName: defaultsSuite)!
        defaults.removePersistentDomain(forName: defaultsSuite)
        let store = DestinationStore(defaults: defaults, key: "destination")
        return CaptureWindowController(destinationStore: store,
                                       writer: DailyNoteWriter(),
                                       dateProvider: SystemDateProvider(),
                                       logger: logger)
    }

    func testSubmitQuickNotePreservesDraftWhenDestinationMissing() {
        let logger = TestLogger()
        let sut = makeController(defaultsSuite: "test.capture.missing.\(UUID().uuidString)", logger: logger)

        let result = sut.submitQuickNote("draft")

        XCTAssertFalse(result)
        XCTAssertEqual(sut.preservedDraft, "draft")
        XCTAssertEqual(sut.lastErrorMessage, "Destination folder is not configured.")
        XCTAssertEqual(logger.errorMessages.count, 1)
        XCTAssertTrue(logger.errorMessages[0].contains("<redacted len=5>"))
    }

    func testRejectUnavailableActionStoresReasonAndDraft() {
        let logger = TestLogger()
        let sut = makeController(defaultsSuite: "test.capture.reject.\(UUID().uuidString)", logger: logger)

        let result = sut.rejectUnavailableAction(draft: "blocked", reason: "Configure first")

        XCTAssertFalse(result)
        XCTAssertEqual(sut.lastErrorMessage, "Configure first")
        XCTAssertEqual(sut.preservedDraft, "blocked")
        XCTAssertEqual(logger.errorMessages.count, 1)
    }

    func testSubmitTaskPreservesDraftWhenValidationFails() {
        let logger = TestLogger()
        let sut = makeController(defaultsSuite: "test.capture.validation.\(UUID().uuidString)", logger: logger)

        let result = sut.submitTask(title: "   ", dueDate: nil)

        XCTAssertFalse(result)
        XCTAssertEqual(sut.preservedDraft, "   ")
        XCTAssertEqual(sut.lastErrorMessage, ValidationError.emptyTaskTitle.errorDescription)
        XCTAssertEqual(logger.errorMessages.count, 1)
    }
}
