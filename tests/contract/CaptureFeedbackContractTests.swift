import XCTest
@testable import ObsidianQuickNoteTask

final class CaptureFeedbackContractTests: XCTestCase {
    private func makeTempDir() throws -> URL {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    private func makeStore(suite: String) -> DestinationStore {
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        return DestinationStore(defaults: defaults, key: "destination")
    }

    func testBlockedFeedbackWhenDestinationMissingForQuickNote() {
        let store = makeStore(suite: "test.contract.feedback.blocked.note.\(UUID().uuidString)")
        let sut = CaptureWindowController(destinationStore: store)

        let success = sut.submitQuickNote("draft content")

        XCTAssertFalse(success)
        XCTAssertEqual(sut.lastErrorMessage, "Destination folder is not configured.")
        XCTAssertEqual(sut.preservedDraft, "draft content")
    }

    func testBlockedFeedbackWhenDestinationMissingForTask() {
        let store = makeStore(suite: "test.contract.feedback.blocked.task.\(UUID().uuidString)")
        let sut = CaptureWindowController(destinationStore: store)

        let success = sut.submitTask(title: "draft task", dueDate: nil)

        XCTAssertFalse(success)
        XCTAssertEqual(sut.lastErrorMessage, "Destination folder is not configured.")
        XCTAssertEqual(sut.preservedDraft, "draft task")
    }

    func testSuccessFeedbackContainsOutputFileContext() throws {
        let suite = "test.contract.feedback.success.\(UUID().uuidString)"
        let store = makeStore(suite: suite)
        let settings = SettingsController(destinationStore: store)
        try settings.selectDestination(try makeTempDir())
        let sut = CaptureWindowController(destinationStore: store)

        let success = sut.submitQuickNote("hello")

        XCTAssertTrue(success)
        XCTAssertNil(sut.lastErrorMessage)
        XCTAssertNotNil(sut.lastOutputFile)
        XCTAssertFalse(sut.lastOutputFile?.path.isEmpty ?? true)
    }

    func testValidationFailurePreservesDraft() {
        let store = makeStore(suite: "test.contract.feedback.validation.\(UUID().uuidString)")
        let sut = CaptureWindowController(destinationStore: store)

        let success = sut.submitTask(title: "   ", dueDate: nil)

        XCTAssertFalse(success)
        XCTAssertEqual(sut.lastErrorMessage, ValidationError.emptyTaskTitle.errorDescription)
        XCTAssertEqual(sut.preservedDraft, "   ")
    }
}
