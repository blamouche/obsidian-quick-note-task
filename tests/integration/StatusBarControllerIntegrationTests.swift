import XCTest
@testable import ObsidianQuickNoteTask

@MainActor
final class StatusBarControllerIntegrationTests: XCTestCase {
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

    func testFirstRunStateDisablesCaptureActions() {
        let (status, _, _) = makeControllers(suite: "test.status.first.\(UUID().uuidString)")

        let state = status.currentAvailabilityState()

        XCTAssertEqual(state.statusKind, .setupRequired)
        XCTAssertFalse(state.quickNoteEnabled)
        XCTAssertFalse(state.taskEnabled)
    }

    func testStateBecomesEnabledAfterSuccessfulSettingsSelection() throws {
        let (status, _, settings) = makeControllers(suite: "test.status.enable.\(UUID().uuidString)")
        let dir = try makeTempDir()

        try settings.selectDestination(dir)
        status.refreshMenuState()
        let state = status.currentAvailabilityState()

        XCTAssertEqual(state.statusKind, .ready)
        XCTAssertTrue(state.quickNoteEnabled)
        XCTAssertTrue(state.taskEnabled)
    }

    func testInvalidDestinationAfterPriorValidSetupRequiresRecovery() throws {
        let (status, _, settings) = makeControllers(suite: "test.status.invalid.\(UUID().uuidString)")
        let dir = try makeTempDir()
        try settings.selectDestination(dir)
        try FileManager.default.removeItem(at: dir)

        let state = status.currentAvailabilityState()

        XCTAssertEqual(state.statusKind, .recoveryRequired)
        XCTAssertFalse(state.quickNoteEnabled)
        XCTAssertFalse(state.taskEnabled)
        XCTAssertTrue(state.statusMessage.contains("indisponible"))
    }

    func testBlockedActionSetsActionableErrorAndRetryWorksAfterReconfigure() throws {
        let (status, capture, settings) = makeControllers(suite: "test.status.retry.\(UUID().uuidString)")
        let oldDir = try makeTempDir()
        try settings.selectDestination(oldDir)
        try FileManager.default.removeItem(at: oldDir)

        status.handle(.quickNote)
        XCTAssertNotNil(capture.lastErrorMessage)
        XCTAssertTrue(capture.lastErrorMessage?.contains("Reconfigure") ?? false)
        XCTAssertEqual(capture.preservedDraft, "Quick capture placeholder")

        let newDir = try makeTempDir()
        try settings.selectDestination(newDir)
        status.handle(.quickNote)

        XCTAssertNil(capture.lastErrorMessage)
        XCTAssertNotNil(capture.lastOutputFile)
    }

    func testQuickNoteVisualProfileProvidesReadableHierarchy() {
        let (_, capture, _) = makeControllers(suite: "test.status.visual.quicknote.\(UUID().uuidString)")
        let profile = capture.visualProfile()

        XCTAssertGreaterThan(profile.typography.title, profile.typography.label)
        XCTAssertGreaterThanOrEqual(profile.typography.input, profile.typography.label)
        XCTAssertGreaterThan(profile.spacing.windowPadding, 0)
    }

    func testTaskVisualProfileKeepsReadableControlDensity() {
        let (_, capture, _) = makeControllers(suite: "test.status.visual.task.\(UUID().uuidString)")
        let profile = capture.visualProfile()

        XCTAssertGreaterThan(profile.spacing.sectionGap, 0)
        XCTAssertGreaterThan(profile.spacing.fieldGap, 0)
        XCTAssertLessThanOrEqual(profile.spacing.actionGap, profile.spacing.sectionGap)
    }

    func testDisabledStateReadabilityIncludesNonColorCue() {
        let (status, _, _) = makeControllers(suite: "test.status.visual.disabledcue.\(UUID().uuidString)")
        let state = status.currentAvailabilityState()

        XCTAssertEqual(state.visualRole, .disabled)
        XCTAssertTrue(state.statusMessage.contains("[Indisponible]"))
    }

    func testSettingsDestinationActionRemainsExplicitWithoutDecorativeIcon() {
        let (_, _, settings) = makeControllers(suite: "test.status.visual.folderlabel.\(UUID().uuidString)")
        let profile = settings.visualProfile()

        XCTAssertFalse(profile.folderAffordance.iconVisible)
        XCTAssertFalse(profile.folderAffordance.actionLabel.isEmpty)
    }
}
