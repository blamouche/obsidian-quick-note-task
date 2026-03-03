import Foundation
#if canImport(AppKit)
import AppKit
#endif

#if canImport(AppKit)
@MainActor
public enum AppIconFactory {
    public static func makeAppIcon(size: CGFloat = 1024) -> NSImage {
        let image = NSImage(size: NSSize(width: size, height: size))
        image.lockFocus()
        defer { image.unlockFocus() }

        let outerRect = NSRect(x: 0, y: 0, width: size, height: size)
        let outerPath = NSBezierPath(roundedRect: outerRect, xRadius: size * 0.19, yRadius: size * 0.19)

        let gradient = NSGradient(colors: [
            NSColor(calibratedRed: 0.43, green: 0.82, blue: 0.90, alpha: 1.0),
            NSColor(calibratedRed: 0.66, green: 0.32, blue: 0.91, alpha: 1.0)
        ])!
        gradient.draw(in: outerPath, angle: 315)

        let innerInset = size * 0.22
        let innerRect = outerRect.insetBy(dx: innerInset, dy: innerInset)
        let innerPath = NSBezierPath(roundedRect: innerRect, xRadius: size * 0.08, yRadius: size * 0.08)
        NSColor.white.setStroke()
        innerPath.lineWidth = size * 0.045
        innerPath.stroke()

        let check = NSBezierPath()
        check.move(to: NSPoint(x: size * 0.36, y: size * 0.50))
        check.line(to: NSPoint(x: size * 0.47, y: size * 0.39))
        check.line(to: NSPoint(x: size * 0.66, y: size * 0.58))
        NSColor.white.setStroke()
        check.lineWidth = size * 0.08
        check.lineCapStyle = .round
        check.lineJoinStyle = .round
        check.stroke()

        return image
    }

    public static func makeStatusBarIcon(size: CGFloat = 18) -> NSImage {
        let image = NSImage(size: NSSize(width: size, height: size))
        image.lockFocus()
        defer { image.unlockFocus() }

        let rect = NSRect(x: 1.5, y: 1.5, width: size - 3, height: size - 3)
        let box = NSBezierPath(roundedRect: rect, xRadius: 3.0, yRadius: 3.0)
        NSColor.labelColor.setStroke()
        box.lineWidth = 1.5
        box.stroke()

        let check = NSBezierPath()
        check.move(to: NSPoint(x: size * 0.30, y: size * 0.51))
        check.line(to: NSPoint(x: size * 0.46, y: size * 0.35))
        check.line(to: NSPoint(x: size * 0.73, y: size * 0.62))
        check.lineWidth = 1.7
        check.lineCapStyle = .round
        check.lineJoinStyle = .round
        NSColor.labelColor.setStroke()
        check.stroke()

        image.isTemplate = true
        return image
    }
}
#endif
