import Foundation
#if canImport(AppKit)
import AppKit
import QuartzCore

public final class WindowBackgroundView: NSVisualEffectView {
    private let tintLayer = CALayer()

    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        material = .hudWindow
        blendingMode = .behindWindow
        state = .active
        isEmphasized = false
        wantsLayer = true
        layer?.masksToBounds = true

        tintLayer.backgroundColor = NSColor.systemPurple.withAlphaComponent(0.05).cgColor
        layer?.addSublayer(tintLayer)
    }

    required init?(coder: NSCoder) {
        nil
    }

    public override func layout() {
        super.layout()
        tintLayer.frame = bounds
    }
}
#endif
