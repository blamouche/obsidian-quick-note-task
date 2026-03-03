import Foundation
#if canImport(AppKit)
import AppKit
#endif

#if canImport(AppKit)
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

    public static func makeStatusBarIcon(size: CGFloat = 18,
                                         statusColor: NSColor? = nil,
                                         warningBadge: Bool = false) -> NSImage {
        let image = NSImage(size: NSSize(width: size, height: size))
        image.lockFocus()
        defer { image.unlockFocus() }

        let iconStrokeColor: NSColor = (statusColor == nil) ? .labelColor : .white

        let rect = NSRect(x: 1.5, y: 1.5, width: size - 3, height: size - 3)
        let box = NSBezierPath(roundedRect: rect, xRadius: 3.0, yRadius: 3.0)
        iconStrokeColor.setStroke()
        box.lineWidth = 1.5
        box.stroke()

        let check = NSBezierPath()
        check.move(to: NSPoint(x: size * 0.30, y: size * 0.51))
        check.line(to: NSPoint(x: size * 0.46, y: size * 0.35))
        check.line(to: NSPoint(x: size * 0.73, y: size * 0.62))
        check.lineWidth = 1.7
        check.lineCapStyle = .round
        check.lineJoinStyle = .round
        iconStrokeColor.setStroke()
        check.stroke()

        if let statusColor {
            let dotSize = max(5, size * 0.28)
            let dotRect = NSRect(x: size - dotSize - 0.5, y: size - dotSize - 0.5, width: dotSize, height: dotSize)
            let dot = NSBezierPath(ovalIn: dotRect)
            statusColor.setFill()
            dot.fill()

            NSColor.windowBackgroundColor.setStroke()
            dot.lineWidth = 0.8
            dot.stroke()

            if warningBadge {
                let mark = NSBezierPath()
                let centerX = dotRect.midX
                let topY = dotRect.maxY - (dotSize * 0.25)
                let bottomY = dotRect.minY + (dotSize * 0.35)
                mark.move(to: NSPoint(x: centerX, y: topY))
                mark.line(to: NSPoint(x: centerX, y: bottomY))
                NSColor.white.setStroke()
                mark.lineWidth = max(1.0, dotSize * 0.16)
                mark.lineCapStyle = .round
                mark.stroke()

                let point = NSBezierPath(ovalIn: NSRect(x: centerX - (dotSize * 0.08),
                                                        y: dotRect.minY + (dotSize * 0.15),
                                                        width: dotSize * 0.16,
                                                        height: dotSize * 0.16))
                NSColor.white.setFill()
                point.fill()
            }
        }

        image.isTemplate = false
        return image
    }
}
#endif
