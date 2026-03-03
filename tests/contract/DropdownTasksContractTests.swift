import XCTest
@testable import ObsidianQuickNoteTask

@MainActor
final class DropdownTasksContractTests: XCTestCase {
    private func makeTempDir() throws -> URL {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    private func makeControllers(suite: String, scanner: VaultTaskScanner) -> (StatusBarController, SettingsController) {
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        let store = DestinationStore(defaults: defaults, key: "destination")
        let settings = SettingsController(destinationStore: store)
        let status = StatusBarController(settingsController: settings, taskScanner: scanner)
        return (status, settings)
    }

    func testNoVaultConfiguredReturnsNoDropdownTasks() {
        let fixedDate = ISO8601DateFormatter().date(from: "2026-03-03T10:00:00Z")!
        let scanner = VaultTaskScanner(dateProvider: FixedDateProvider(fixedDate))
        let (status, _) = makeControllers(suite: "test.contract.dropdown.novault.\(UUID().uuidString)", scanner: scanner)

        XCTAssertTrue(status.dropdownTaskItemsForCurrentState().isEmpty)
    }

    func testConfiguredVaultReturnsOnlyEligibleTasks() throws {
        let fixedDate = ISO8601DateFormatter().date(from: "2026-03-03T10:00:00Z")!
        let scanner = VaultTaskScanner(dateProvider: FixedDateProvider(fixedDate))
        let (status, settings) = makeControllers(suite: "test.contract.dropdown.eligible.\(UUID().uuidString)", scanner: scanner)
        let vault = try makeTempDir()
        let folder = vault.appendingPathComponent("Inbox", isDirectory: true)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        try "- [ ] Today 📅 2026-03-03\n- [ ] Future 📅 2026-03-04".data(using: .utf8)?.write(to: vault.appendingPathComponent("tasks.md"))

        try settings.selectVault(vault)
        try settings.selectDefaultFolder(folder)

        let tasks = status.dropdownTaskItemsForCurrentState()
        XCTAssertEqual(tasks.map(\.title), ["Today"])
    }

    func testToggleContractCompletesTaskAndRemovesFromEligibility() throws {
        let fixedDate = ISO8601DateFormatter().date(from: "2026-03-03T10:00:00Z")!
        let scanner = VaultTaskScanner(dateProvider: FixedDateProvider(fixedDate))
        let vault = try makeTempDir()
        let file = vault.appendingPathComponent("tasks.md")
        try "- [ ] Contract Task 📅 2026-03-03".data(using: .utf8)?.write(to: file)

        let task = scanner.scanDueTasks(vaultURL: vault, exclusionText: nil).first!
        let toggle = TaskToggleService(scanner: scanner)
        let result = toggle.toggleComplete(task: task, vaultURL: vault)

        XCTAssertTrue(result.completionUpdated)
        XCTAssertEqual(result.errorType, .none)
        XCTAssertTrue(scanner.scanDueTasks(vaultURL: vault, exclusionText: nil).isEmpty)
    }

    func testToggleContractReturnsWriteFailureWhenVaultMissing() throws {
        let fixedDate = ISO8601DateFormatter().date(from: "2026-03-03T10:00:00Z")!
        let scanner = VaultTaskScanner(dateProvider: FixedDateProvider(fixedDate))
        let vault = try makeTempDir()
        let file = vault.appendingPathComponent("tasks.md")
        try "- [ ] Contract Task 📅 2026-03-03".data(using: .utf8)?.write(to: file)

        let task = scanner.scanDueTasks(vaultURL: vault, exclusionText: nil).first!
        let toggle = TaskToggleService(scanner: scanner)
        let result = toggle.toggleComplete(task: task, vaultURL: nil)

        XCTAssertFalse(result.completionUpdated)
        XCTAssertEqual(result.errorType, .writeFailure)
    }
}
