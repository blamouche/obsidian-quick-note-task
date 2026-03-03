import AppKit
import ObsidianQuickNoteTask

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var controller: StatusBarController?

    @MainActor
    func applicationDidFinishLaunching(_ notification: Notification) {
        let controller = StatusBarController()
        controller.bootstrap()
        self.controller = controller
    }
}

let app = NSApplication.shared
app.applicationIconImage = AppIconFactory.makeAppIcon()
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
