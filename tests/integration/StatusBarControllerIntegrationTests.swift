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

    private func configureValidSettings(_ settings: SettingsController) throws -> URL {
        let vault = try makeTempDir()
        let folder = vault.appendingPathComponent("Inbox", isDirectory: true)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        try settings.selectVault(vault)
        try settings.selectDefaultFolder(folder)
        return folder
    }

    func testFirstRunStateDisablesCaptureActions() {
        let (status, _, _) = makeControllers(suite: "test.status.first.\(UUID().uuidString)")

        let state = status.currentAvailabilityState()

        XCTAssertEqual(state.statusKind, .setupRequired)
        XCTAssertFalse(state.quickNoteEnabled)
        XCTAssertFalse(state.taskEnabled)
        XCTAssertTrue(state.statusMessage.contains("Setup required"))
    }

    func testStateBecomesEnabledAfterSuccessfulSettingsSelection() throws {
        let (status, _, settings) = makeControllers(suite: "test.status.enable.\(UUID().uuidString)")

        _ = try configureValidSettings(settings)
        status.refreshMenuState()
        let state = status.currentAvailabilityState()

        XCTAssertEqual(state.statusKind, .ready)
        XCTAssertTrue(state.quickNoteEnabled)
        XCTAssertTrue(state.taskEnabled)
    }

    func testInvalidDestinationAfterPriorValidSetupRequiresRecovery() throws {
        let (status, _, settings) = makeControllers(suite: "test.status.invalid.\(UUID().uuidString)")
        let folder = try configureValidSettings(settings)
        try FileManager.default.removeItem(at: folder)

        let state = status.currentAvailabilityState()

        XCTAssertEqual(state.statusKind, .recoveryRequired)
        XCTAssertFalse(state.quickNoteEnabled)
        XCTAssertFalse(state.taskEnabled)
        XCTAssertTrue(state.statusMessage.contains("Default folder invalid"))
    }

    func testBlockedActionSetsActionableErrorAndRetryWorksAfterReconfigure() throws {
        let (status, capture, settings) = makeControllers(suite: "test.status.retry.\(UUID().uuidString)")
        _ = try configureValidSettings(settings)

        // Invalidate folder by moving to outside vault.
        let outside = try makeTempDir()
        try settings.selectDefaultFolder(outside)

        status.handle(.quickNote)
        XCTAssertNotNil(capture.lastErrorMessage)
        XCTAssertTrue(capture.lastErrorMessage?.contains("inside the selected vault") ?? false)
        XCTAssertEqual(capture.preservedDraft, "Quick capture placeholder")

        _ = try configureValidSettings(settings)
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
        XCTAssertTrue(state.statusMessage.contains("[Unavailable]"))
    }

    func testSettingsDestinationActionRemainsExplicitWithoutDecorativeIcon() {
        let (_, _, settings) = makeControllers(suite: "test.status.visual.folderlabel.\(UUID().uuidString)")
        let profile = settings.visualProfile()

        XCTAssertFalse(profile.folderAffordance.iconVisible)
        XCTAssertFalse(profile.folderAffordance.actionLabel.isEmpty)
    }

    func testDropdownTasksReflectExclusionFilterChanges() throws {
        let fixedDate = ISO8601DateFormatter().date(from: "2026-03-03T10:00:00Z")!
        let scanner = VaultTaskScanner(dateProvider: FixedDateProvider(fixedDate))
        let suite = "test.status.dropdown.exclusion.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        let store = DestinationStore(defaults: defaults, key: "destination")
        let capture = CaptureWindowController(destinationStore: store)
        let settings = SettingsController(destinationStore: store)
        let status = StatusBarController(captureController: capture, settingsController: settings, taskScanner: scanner)

        let vault = try makeTempDir()
        let folder = vault.appendingPathComponent("Inbox", isDirectory: true)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        try "- [ ] Keep 📅 2026-03-03\n- [ ] Snoozed #snooze 📅 2026-03-03"
            .data(using: .utf8)?
            .write(to: vault.appendingPathComponent("tasks.md"))
        try settings.selectVault(vault)
        try settings.selectDefaultFolder(folder)

        XCTAssertEqual(status.dropdownTaskItemsForCurrentState().count, 2)

        try settings.setTaskExclusionText("#snooze")

        XCTAssertEqual(status.dropdownTaskItemsForCurrentState().count, 1)
        XCTAssertEqual(status.dropdownTaskItemsForCurrentState().first?.title, "Keep")
    }

    func testDropdownMenuTitleShowsRecurringPictoForRecurringTask() throws {
        let fixedDate = ISO8601DateFormatter().date(from: "2026-03-03T10:00:00Z")!
        let scanner = VaultTaskScanner(dateProvider: FixedDateProvider(fixedDate))
        let suite = "test.status.dropdown.recurringpicto.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        let store = DestinationStore(defaults: defaults, key: "destination")
        let capture = CaptureWindowController(destinationStore: store)
        let settings = SettingsController(destinationStore: store)
        let status = StatusBarController(captureController: capture, settingsController: settings, taskScanner: scanner)

        let vault = try makeTempDir()
        let folder = vault.appendingPathComponent("Inbox", isDirectory: true)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        try "- [ ] Recur 📅 2026-03-03 🔁 every day"
            .data(using: .utf8)?
            .write(to: vault.appendingPathComponent("tasks.md"))
        try settings.selectVault(vault)
        try settings.selectDefaultFolder(folder)

        let task = try XCTUnwrap(status.dropdownTaskItemsForCurrentState().first)
        let recurrenceIcon = status.dropdownRecurrenceIcon(for: task)

        XCTAssertEqual(recurrenceIcon, "↻")
    }

    func testDropdownMenuTitleMasksURLsFromTaskTitle() throws {
        let fixedDate = ISO8601DateFormatter().date(from: "2026-03-03T10:00:00Z")!
        let scanner = VaultTaskScanner(dateProvider: FixedDateProvider(fixedDate))
        let suite = "test.status.dropdown.urlmask.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        let store = DestinationStore(defaults: defaults, key: "destination")
        let capture = CaptureWindowController(destinationStore: store)
        let settings = SettingsController(destinationStore: store)
        let status = StatusBarController(captureController: capture, settingsController: settings, taskScanner: scanner)

        let vault = try makeTempDir()
        let folder = vault.appendingPathComponent("Inbox", isDirectory: true)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        try "- [ ] Fix bug https://example.com/ticket/123 📅 2026-03-03"
            .data(using: .utf8)?
            .write(to: vault.appendingPathComponent("tasks.md"))
        try settings.selectVault(vault)
        try settings.selectDefaultFolder(folder)

        let task = try XCTUnwrap(status.dropdownTaskItemsForCurrentState().first)
        let menuTitle = status.dropdownMenuTitle(for: task)

        XCTAssertFalse(menuTitle.contains("http://"))
        XCTAssertFalse(menuTitle.contains("https://"))
    }

    func testDropdownLateIconShownForOverdueTask() throws {
        let fixedDate = ISO8601DateFormatter().date(from: "2026-03-03T10:00:00Z")!
        let scanner = VaultTaskScanner(dateProvider: FixedDateProvider(fixedDate))
        let suite = "test.status.dropdown.lateicon.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        let store = DestinationStore(defaults: defaults, key: "destination")
        let capture = CaptureWindowController(destinationStore: store)
        let settings = SettingsController(destinationStore: store)
        let status = StatusBarController(captureController: capture, settingsController: settings, taskScanner: scanner)

        let vault = try makeTempDir()
        let folder = vault.appendingPathComponent("Inbox", isDirectory: true)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        try "- [ ] Late task 📅 2026-03-02"
            .data(using: .utf8)?
            .write(to: vault.appendingPathComponent("tasks.md"))
        try settings.selectVault(vault)
        try settings.selectDefaultFolder(folder)

        let task = try XCTUnwrap(status.dropdownTaskItemsForCurrentState().first)
        XCTAssertEqual(status.dropdownLateIcon(for: task), "⚠︎")
    }
}
