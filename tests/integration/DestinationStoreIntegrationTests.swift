import XCTest
@testable import ObsidianQuickNoteTask

final class DestinationStoreIntegrationTests: XCTestCase {
    private func makeTempDir() throws -> URL {
        let base = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: base, withIntermediateDirectories: true)
        return base
    }

    func testPersistsDestinationAcrossStoreInstances() throws {
        let suiteName = "test.destination.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let dir = try makeTempDir()
        let first = DestinationStore(defaults: defaults, key: "destination")
        try first.saveDestination(url: dir)

        let second = DestinationStore(defaults: defaults, key: "destination")
        let loaded = second.loadDestinationURL()

        XCTAssertNotNil(loaded)
        XCTAssertEqual(loaded?.path, dir.path)
    }

    func testRejectsInaccessibleDestinationInput() throws {
        let suiteName = "test.destination.invalid.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        FileManager.default.createFile(atPath: fileURL.path, contents: Data(), attributes: nil)

        let store = DestinationStore(defaults: defaults, key: "destination")
        XCTAssertThrowsError(try store.saveDestination(url: fileURL))
    }
}
