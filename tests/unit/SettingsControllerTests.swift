import XCTest
@testable import ObsidianQuickNoteTask

final class SettingsControllerTests: XCTestCase {
    private func makeTempDir() throws -> URL {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    func testDestinationReadinessReturnsNotConfiguredWhenNoDestinationSaved() {
        let suiteName = "test.settings.readiness.none.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let store = DestinationStore(defaults: defaults, key: "destination")
        let sut = SettingsController(destinationStore: store)

        XCTAssertEqual(sut.destinationReadiness(), .notConfigured)
    }

    func testDestinationReadinessReturnsConfiguredValidForExistingDirectory() throws {
        let suiteName = "test.settings.readiness.valid.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let store = DestinationStore(defaults: defaults, key: "destination")
        let sut = SettingsController(destinationStore: store)
        let dir = try makeTempDir()

        try sut.selectDestination(dir)

        XCTAssertEqual(sut.destinationReadiness(), .configuredValid(dir))
    }

    func testDestinationReadinessReturnsConfiguredInvalidWhenDirectoryIsMissing() throws {
        let suiteName = "test.settings.readiness.invalid.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let store = DestinationStore(defaults: defaults, key: "destination")
        let sut = SettingsController(destinationStore: store)
        let dir = try makeTempDir()

        try sut.selectDestination(dir)
        try FileManager.default.removeItem(at: dir)

        XCTAssertEqual(sut.destinationReadiness(), .configuredInvalid(dir))
    }
}
