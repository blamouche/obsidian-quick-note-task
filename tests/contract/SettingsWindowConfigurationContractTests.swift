import XCTest
@testable import ObsidianQuickNoteTask

final class SettingsWindowConfigurationContractTests: XCTestCase {
    private func makeStore(_ suite: String) -> DestinationStore {
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        return DestinationStore(defaults: defaults, key: "destination")
    }

    private func makeTempDir() throws -> URL {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    func testSettingsExposesVaultAndDefaultFolderConfigurations() {
        let store = makeStore("test.contract.settings.sections.\(UUID().uuidString)")
        let sut = SettingsController(destinationStore: store)

        XCTAssertNil(sut.currentVault())
        XCTAssertNil(sut.currentDefaultFolder())
    }

    func testVaultSelectionPersistsAndIsDisplayedAsCurrentValue() throws {
        let store = makeStore("test.contract.settings.vault.persist.\(UUID().uuidString)")
        let sut = SettingsController(destinationStore: store)
        let vault = try makeTempDir()

        try sut.selectVault(vault)

        XCTAssertEqual(sut.currentVault(), vault)
    }

    func testDefaultFolderSelectionPersistsAndIsDisplayedAsCurrentValue() throws {
        let store = makeStore("test.contract.settings.folder.persist.\(UUID().uuidString)")
        let sut = SettingsController(destinationStore: store)
        let vault = try makeTempDir()
        let folder = vault.appendingPathComponent("Inbox", isDirectory: true)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)

        try sut.selectVault(vault)
        try sut.selectDefaultFolder(folder)

        XCTAssertEqual(sut.currentDefaultFolder(), folder)
    }

    func testVaultUpdateDoesNotOverwriteDefaultFolder() throws {
        let store = makeStore("test.contract.settings.independent.vault.\(UUID().uuidString)")
        let sut = SettingsController(destinationStore: store)
        let vaultA = try makeTempDir()
        let folderA = vaultA.appendingPathComponent("Inbox", isDirectory: true)
        try FileManager.default.createDirectory(at: folderA, withIntermediateDirectories: true)

        try sut.selectVault(vaultA)
        try sut.selectDefaultFolder(folderA)

        let vaultB = try makeTempDir()
        try sut.selectVault(vaultB)

        XCTAssertEqual(sut.currentVault(), vaultB)
        XCTAssertEqual(sut.currentDefaultFolder(), folderA)
    }

    func testDefaultFolderUpdateDoesNotOverwriteVault() throws {
        let store = makeStore("test.contract.settings.independent.folder.\(UUID().uuidString)")
        let sut = SettingsController(destinationStore: store)
        let vault = try makeTempDir()
        let folderA = vault.appendingPathComponent("Inbox", isDirectory: true)
        let folderB = vault.appendingPathComponent("Tasks", isDirectory: true)
        try FileManager.default.createDirectory(at: folderA, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: folderB, withIntermediateDirectories: true)

        try sut.selectVault(vault)
        try sut.selectDefaultFolder(folderA)
        try sut.selectDefaultFolder(folderB)

        XCTAssertEqual(sut.currentVault(), vault)
        XCTAssertEqual(sut.currentDefaultFolder(), folderB)
    }
}
