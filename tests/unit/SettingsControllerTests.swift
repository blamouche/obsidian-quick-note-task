import XCTest
@testable import ObsidianQuickNoteTask

final class SettingsControllerTests: XCTestCase {
    private func makeTempDir() throws -> URL {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    private func makeStore(_ suiteName: String) -> DestinationStore {
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        return DestinationStore(defaults: defaults, key: "destination")
    }

    func testConfigurationStateInvalidBothWhenNoVaultAndNoDefaultFolder() {
        let suiteName = "test.settings.state.none.\(UUID().uuidString)"
        let store = makeStore(suiteName)
        let sut = SettingsController(destinationStore: store)

        let state = sut.configurationState()

        XCTAssertEqual(state.status, .invalidBoth)
        XCTAssertFalse(state.canCapture)
        XCTAssertEqual(state.blockingReason, .vaultMissing)
    }

    func testConfigurationStateValidWhenVaultAndDefaultFolderConfiguredInsideVault() throws {
        let suiteName = "test.settings.state.valid.\(UUID().uuidString)"
        let store = makeStore(suiteName)
        let sut = SettingsController(destinationStore: store)
        let vault = try makeTempDir()
        let folder = vault.appendingPathComponent("Inbox", isDirectory: true)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)

        try sut.selectVault(vault)
        try sut.selectDefaultFolder(folder)

        let state = sut.configurationState()

        XCTAssertEqual(state.status, .valid)
        XCTAssertTrue(state.canCapture)
        XCTAssertEqual(state.vaultURL, vault)
        XCTAssertEqual(state.defaultFolderURL, folder)
    }

    func testConfigurationStateInvalidFolderWhenDefaultFolderIsOutsideVault() throws {
        let suiteName = "test.settings.state.outside.\(UUID().uuidString)"
        let store = makeStore(suiteName)
        let sut = SettingsController(destinationStore: store)
        let vault = try makeTempDir()
        let outside = try makeTempDir()

        try sut.selectVault(vault)
        try sut.selectDefaultFolder(outside)

        let state = sut.configurationState()

        XCTAssertEqual(state.status, .invalidFolder)
        XCTAssertFalse(state.canCapture)
        XCTAssertEqual(state.blockingReason, .folderOutsideVault)
    }

    func testDestinationReadinessConfiguredValidWhenConfigurationIsValid() throws {
        let suiteName = "test.settings.readiness.valid.\(UUID().uuidString)"
        let store = makeStore(suiteName)
        let sut = SettingsController(destinationStore: store)
        let vault = try makeTempDir()
        let folder = vault.appendingPathComponent("Tasks", isDirectory: true)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)

        try sut.selectVault(vault)
        try sut.selectDefaultFolder(folder)

        XCTAssertEqual(sut.destinationReadiness(), .configuredValid(folder))
    }

    func testDestinationReadinessConfiguredInvalidWhenFolderMissing() throws {
        let suiteName = "test.settings.readiness.invalid.\(UUID().uuidString)"
        let store = makeStore(suiteName)
        let sut = SettingsController(destinationStore: store)
        let vault = try makeTempDir()

        try sut.selectVault(vault)

        switch sut.destinationReadiness() {
        case .configuredInvalid:
            XCTAssertTrue(true)
        default:
            XCTFail("Expected configuredInvalid when folder is missing")
        }
    }

    func testCurrentDestinationUsesDefaultFolderReference() throws {
        let suiteName = "test.settings.destination.default-folder.\(UUID().uuidString)"
        let store = makeStore(suiteName)
        let sut = SettingsController(destinationStore: store)
        let vault = try makeTempDir()
        let folder = vault.appendingPathComponent("Daily", isDirectory: true)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)

        try sut.selectVault(vault)
        try sut.selectDestination(folder)

        XCTAssertEqual(sut.currentDestination(), folder)
    }
}
