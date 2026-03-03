import XCTest
@testable import ObsidianQuickNoteTask

final class FolderAffordanceContractTests: XCTestCase {
    private func makeControllers(suite: String) -> (CaptureWindowController, SettingsController, DestinationStore) {
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        let store = DestinationStore(defaults: defaults, key: "destination")
        return (CaptureWindowController(destinationStore: store),
                SettingsController(destinationStore: store),
                store)
    }

    private func makeTempDir() throws -> URL {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    func testDecorativeFolderIconIsAbsentInSettingsAndCaptureProfiles() {
        let (capture, settings, _) = makeControllers(suite: "test.contract.folder.icon.\(UUID().uuidString)")

        XCTAssertFalse(capture.visualProfile().folderAffordance.iconVisible)
        XCTAssertFalse(settings.visualProfile().folderAffordance.iconVisible)
    }

    func testFolderActionRemainsExplicitAfterIconRemoval() {
        let (capture, settings, _) = makeControllers(suite: "test.contract.folder.label.\(UUID().uuidString)")

        XCTAssertFalse(capture.visualProfile().folderAffordance.actionLabel.isEmpty)
        XCTAssertFalse(settings.visualProfile().folderAffordance.actionLabel.isEmpty)
    }

    func testDestinationSelectionFlowIsUnchanged() throws {
        let (_, settings, store) = makeControllers(suite: "test.contract.folder.flow.\(UUID().uuidString)")
        let destination = try makeTempDir()

        try settings.selectDestination(destination)
        let loaded = store.loadDestinationURL()

        XCTAssertEqual(loaded, destination)
    }
}
