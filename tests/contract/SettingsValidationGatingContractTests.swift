import XCTest
@testable import ObsidianQuickNoteTask

@MainActor
final class SettingsValidationGatingContractTests: XCTestCase {
    private func makeTempDir() throws -> URL {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    private func makeControllers(suite: String) -> (StatusBarController, SettingsController) {
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        let store = DestinationStore(defaults: defaults, key: "destination")
        let settings = SettingsController(destinationStore: store)
        let status = StatusBarController(captureController: CaptureWindowController(destinationStore: store), settingsController: settings)
        return (status, settings)
    }

    func testCaptureDisabledWhenVaultMissing() {
        let (status, _) = makeControllers(suite: "test.contract.settings.gating.vault-missing.\(UUID().uuidString)")

        let state = status.currentAvailabilityState()

        XCTAssertFalse(state.quickNoteEnabled)
        XCTAssertFalse(state.taskEnabled)
        XCTAssertEqual(state.statusKind, .setupRequired)
    }

    func testCaptureDisabledWhenDefaultFolderMissing() throws {
        let (status, settings) = makeControllers(suite: "test.contract.settings.gating.folder-missing.\(UUID().uuidString)")
        try settings.selectVault(try makeTempDir())

        let state = status.currentAvailabilityState()

        XCTAssertFalse(state.quickNoteEnabled)
        XCTAssertFalse(state.taskEnabled)
        XCTAssertEqual(state.statusKind, .setupRequired)
    }

    func testCaptureDisabledWhenDefaultFolderOutsideVault() throws {
        let (status, settings) = makeControllers(suite: "test.contract.settings.gating.folder-outside.\(UUID().uuidString)")
        let vault = try makeTempDir()
        let outside = try makeTempDir()
        try settings.selectVault(vault)
        try settings.selectDefaultFolder(outside)

        let state = status.currentAvailabilityState()

        XCTAssertFalse(state.quickNoteEnabled)
        XCTAssertFalse(state.taskEnabled)
        XCTAssertEqual(state.statusKind, .recoveryRequired)
    }

    func testCaptureEnabledWhenVaultAndDefaultFolderAreValid() throws {
        let (status, settings) = makeControllers(suite: "test.contract.settings.gating.ready.\(UUID().uuidString)")
        let vault = try makeTempDir()
        let folder = vault.appendingPathComponent("Inbox", isDirectory: true)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        try settings.selectVault(vault)
        try settings.selectDefaultFolder(folder)

        let state = status.currentAvailabilityState()

        XCTAssertTrue(state.quickNoteEnabled)
        XCTAssertTrue(state.taskEnabled)
        XCTAssertEqual(state.statusKind, .ready)
    }

    func testCaptureDisabledWhenBothVaultAndFolderInvalid() throws {
        let (status, settings) = makeControllers(suite: "test.contract.settings.gating.both-invalid.\(UUID().uuidString)")
        let vault = try makeTempDir()
        let folder = vault.appendingPathComponent("Inbox", isDirectory: true)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)

        try settings.selectVault(vault)
        try settings.selectDefaultFolder(folder)
        try FileManager.default.removeItem(at: vault)

        let state = status.currentAvailabilityState()

        XCTAssertFalse(state.quickNoteEnabled)
        XCTAssertFalse(state.taskEnabled)
        XCTAssertEqual(state.statusKind, .recoveryRequired)
    }
}
