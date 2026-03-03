import AppKit
import ObsidianQuickNoteTask

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let controller = StatusBarController()

    func applicationDidFinishLaunching(_ notification: Notification) {
        controller.bootstrap()
    }
}

let app = NSApplication.shared
app.applicationIconImage = AppIconFactory.makeAppIcon()
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
