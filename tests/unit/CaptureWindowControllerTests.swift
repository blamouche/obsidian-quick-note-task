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

    private func makeController(defaultsSuite: String,
                                logger: Logging,
                                dateProvider: DateProviding = SystemDateProvider()) -> CaptureWindowController {
        let defaults = UserDefaults(suiteName: defaultsSuite)!
        defaults.removePersistentDomain(forName: defaultsSuite)
        let store = DestinationStore(defaults: defaults, key: "destination")
        return CaptureWindowController(destinationStore: store,
                                       writer: DailyNoteWriter(),
                                       dateProvider: dateProvider,
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

    func testSuggestedNewNoteTitlePrefixUsesDateProvider() {
        let logger = TestLogger()
        let fixedDate = ISO8601DateFormatter().date(from: "2026-03-09T10:00:00Z")!
        let sut = makeController(defaultsSuite: "test.capture.prefix.\(UUID().uuidString)",
                                 logger: logger,
                                 dateProvider: FixedDateProvider(fixedDate))

        let prefix = sut.suggestedNewNoteTitlePrefix()

        XCTAssertEqual(prefix, "2026-03-09 - ")
    }

    func testSubmitStandaloneNoteCreatesFileInConfiguredFolder() throws {
        let logger = TestLogger()
        let suite = "test.capture.standalone.create.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        let store = DestinationStore(defaults: defaults, key: "destination")
        let folder = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        try store.saveDefaultFolderURL(folder)
        let sut = CaptureWindowController(destinationStore: store,
                                          writer: DailyNoteWriter(),
                                          dateProvider: SystemDateProvider(),
                                          logger: logger)

        let ok = sut.submitStandaloneNote(title: "2026-03-09 - Sprint/Planning", content: "Hello")

        XCTAssertTrue(ok)
        let output = try XCTUnwrap(sut.lastOutputFile)
        XCTAssertTrue(output.path.hasPrefix(folder.path))
        XCTAssertEqual(output.pathExtension, "md")
        XCTAssertTrue(output.lastPathComponent.contains("2026-03-09 - Sprint-Planning"))
        XCTAssertEqual(try String(contentsOf: output, encoding: .utf8), "Hello")
    }
}
