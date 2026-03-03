import XCTest
@testable import ObsidianQuickNoteTask

@MainActor
final class VisualPresentationContractTests: XCTestCase {
    private func makeControllers(suite: String) -> (StatusBarController, CaptureWindowController, SettingsController) {
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        let store = DestinationStore(defaults: defaults, key: "destination")
        let capture = CaptureWindowController(destinationStore: store)
        let settings = SettingsController(destinationStore: store)
        let status = StatusBarController(captureController: capture, settingsController: settings)
        return (status, capture, settings)
    }

    func testTypographyHierarchyConsistencyAcrossWindows() {
        let (_, capture, settings) = makeControllers(suite: "test.contract.visual.typo.\(UUID().uuidString)")
        let captureTypography = capture.visualProfile().typography
        let settingsTypography = settings.visualProfile().typography

        XCTAssertEqual(captureTypography, settingsTypography)
        XCTAssertGreaterThan(captureTypography.title, captureTypography.label)
        XCTAssertGreaterThanOrEqual(captureTypography.input, captureTypography.label)
    }

    func testSpacingRhythmConsistencyAcrossWindows() {
        let (_, capture, settings) = makeControllers(suite: "test.contract.visual.spacing.\(UUID().uuidString)")
        let captureSpacing = capture.visualProfile().spacing
        let settingsSpacing = settings.visualProfile().spacing

        XCTAssertEqual(captureSpacing, settingsSpacing)
        XCTAssertLessThanOrEqual(captureSpacing.actionGap, captureSpacing.sectionGap)
    }

    func testStateSignalingSupportsActiveDisabledSuccessAndError() {
        let (status, _, _) = makeControllers(suite: "test.contract.visual.states.\(UUID().uuidString)")

        XCTAssertEqual(status.visualState(for: .active).role, .active)
        XCTAssertEqual(status.visualState(for: .disabled).role, .disabled)
        XCTAssertEqual(status.visualState(for: .success).role, .success)
        XCTAssertEqual(status.visualState(for: .error).role, .error)
        XCTAssertFalse(status.visualState(for: .disabled).nonColorCue.isEmpty)
    }

    func testDisabledAvailabilityStateUsesNonColorCueInStatusText() {
        let (status, _, _) = makeControllers(suite: "test.contract.visual.disabled-cue.\(UUID().uuidString)")
        let state = status.currentAvailabilityState()

        XCTAssertFalse(state.quickNoteEnabled)
        XCTAssertEqual(state.visualRole, .disabled)
        XCTAssertTrue(state.statusMessage.contains("[Unavailable]"))
    }
}
