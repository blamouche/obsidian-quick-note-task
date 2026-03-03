import XCTest
@testable import ObsidianQuickNoteTask

final class UIStyleTests: XCTestCase {
    func testTypographyHierarchyIsConsistent() {
        let scale = UIStyle.typography

        XCTAssertGreaterThan(scale.title, scale.label)
        XCTAssertGreaterThan(scale.label, scale.secondaryAction)
        XCTAssertGreaterThanOrEqual(scale.input, scale.label)
    }

    func testSpacingRhythmIsConsistent() {
        let spacing = UIStyle.spacing

        XCTAssertGreaterThanOrEqual(spacing.windowPadding, spacing.sectionGap)
        XCTAssertGreaterThanOrEqual(spacing.sectionGap, spacing.fieldGap)
        XCTAssertLessThanOrEqual(spacing.actionGap, spacing.sectionGap)
    }

    func testDisabledStateHasNonColorCue() {
        let disabled = UIStyle.stateStyle(for: .disabled)

        XCTAssertEqual(disabled.role, .disabled)
        XCTAssertFalse(disabled.nonColorCue.isEmpty)
    }

    func testFolderAffordanceRemovesDecorativeIconAndKeepsActionLabel() {
        let style = UIStyle.folderAffordance

        XCTAssertFalse(style.iconVisible)
        XCTAssertFalse(style.actionLabel.isEmpty)
    }
}
