import XCTest
@testable import ObsidianQuickNoteTask

@MainActor
final class MenuAvailabilityContractTests: XCTestCase {
    private func makeTempDir() throws -> URL {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    private func makeControllers(suite: String) -> (StatusBarController, CaptureWindowController, SettingsController) {
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        let store = DestinationStore(defaults: defaults, key: "destination")
        let capture = CaptureWindowController(destinationStore: store)
        let settings = SettingsController(destinationStore: store)
        let status = StatusBarController(captureController: capture, settingsController: settings)
        return (status, capture, settings)
    }

    func testNotConfiguredStateDisablesActionsAndPromotesSetup() {
        let (status, _, _) = makeControllers(suite: "test.contract.menu.notconfigured.\(UUID().uuidString)")
        let state = status.currentAvailabilityState()

        XCTAssertFalse(state.quickNoteEnabled)
        XCTAssertFalse(state.taskEnabled)
        XCTAssertFalse(state.newNoteEnabled)
        XCTAssertEqual(state.statusKind, .setupRequired)
        XCTAssertEqual(state.settingsTitle, "Configure Settings...")
    }

    func testReadyStateEnablesCaptureActions() throws {
        let (status, _, settings) = makeControllers(suite: "test.contract.menu.ready.\(UUID().uuidString)")
        let vault = try makeTempDir()
        let folder = vault.appendingPathComponent("Inbox", isDirectory: true)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        try settings.selectVault(vault)
        try settings.selectDefaultFolder(folder)
        let state = status.currentAvailabilityState()

        XCTAssertTrue(state.quickNoteEnabled)
        XCTAssertTrue(state.taskEnabled)
        XCTAssertTrue(state.newNoteEnabled)
        XCTAssertEqual(state.statusKind, .ready)
    }

    func testRecoveryStateDisablesActionsAndPromotesReconfiguration() throws {
        let (status, _, settings) = makeControllers(suite: "test.contract.menu.recovery.\(UUID().uuidString)")
        let vault = try makeTempDir()
        let folder = vault.appendingPathComponent("Inbox", isDirectory: true)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        try settings.selectVault(vault)
        try settings.selectDefaultFolder(folder)
        try FileManager.default.removeItem(at: folder)
        let state = status.currentAvailabilityState()

        XCTAssertFalse(state.quickNoteEnabled)
        XCTAssertFalse(state.taskEnabled)
        XCTAssertFalse(state.newNoteEnabled)
        XCTAssertEqual(state.statusKind, .recoveryRequired)
        XCTAssertEqual(state.settingsTitle, "Reconfigure Settings...")
    }

    func testDisabledActionBlocksKeyboardEquivalentPath() {
        let (status, capture, _) = makeControllers(suite: "test.contract.menu.blockshortcut.\(UUID().uuidString)")

        status.handle(.quickNote)

        XCTAssertNotNil(capture.lastErrorMessage)
        XCTAssertTrue(capture.lastErrorMessage?.contains("Vault") ?? false)
    }
}
