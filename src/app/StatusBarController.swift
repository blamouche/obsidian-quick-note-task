import Foundation
#if canImport(AppKit)
import AppKit
#endif

public enum StatusAction {
    case quickNote
    case task
    case settings
}

@MainActor
public final class StatusBarController: NSObject {
    private let captureController: CaptureWindowController
    private let settingsController: SettingsController
    #if canImport(AppKit)
    private var statusItem: NSStatusItem?
    #endif

    public init(captureController: CaptureWindowController = .init(),
                settingsController: SettingsController = .init()) {
        self.captureController = captureController
        self.settingsController = settingsController
        super.init()
    }

    public func bootstrap() {
        #if canImport(AppKit)
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        item.button?.title = ""
        item.button?.image = AppIconFactory.makeStatusBarIcon()
        item.button?.toolTip = "Obsidian Quick Note Task"

        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Quick Note", action: #selector(onQuickNote), keyEquivalent: "n"))
        menu.addItem(NSMenuItem(title: "Task", action: #selector(onTask), keyEquivalent: "t"))
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Settings", action: #selector(onSettings), keyEquivalent: ","))
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(onQuit), keyEquivalent: "q"))

        for item in menu.items {
            item.target = self
        }

        item.menu = menu
        statusItem = item
        #endif
    }

    public func handle(_ action: StatusAction) {
        switch action {
        case .quickNote:
            _ = captureController.submitQuickNote("Quick capture placeholder")
        case .task:
            _ = captureController.submitTask(title: "Task capture placeholder", dueDate: nil)
        case .settings:
            _ = settingsController.currentDestination()
        }
    }

    #if canImport(AppKit)
    @objc private func onQuickNote() {
        let alert = NSAlert()
        alert.messageText = "Quick Note"
        alert.informativeText = "Saisis un texte brut à ajouter dans la note du jour."
        alert.addButton(withTitle: "Add")
        alert.addButton(withTitle: "Cancel")

        let container = NSView(frame: NSRect(x: 0, y: 0, width: 420, height: 150))
        let scrollView = NSScrollView(frame: NSRect(x: 0, y: 0, width: 420, height: 150))
        scrollView.hasVerticalScroller = true
        scrollView.borderType = .bezelBorder

        let textView = NSTextView(frame: NSRect(x: 0, y: 0, width: 420, height: 150))
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.autoresizingMask = [.width]
        textView.font = NSFont.systemFont(ofSize: 13)
        textView.string = ""

        scrollView.documentView = textView
        container.addSubview(scrollView)
        alert.accessoryView = container

        let response = alert.runModal()
        guard response == .alertFirstButtonReturn else { return }

        if captureController.submitQuickNote(textView.string) {
            showInfo("Quick note ajoutée", detail: captureController.lastOutputFile?.path ?? "")
        } else {
            showError("Échec de l'ajout", detail: captureController.lastErrorMessage ?? "Erreur inconnue")
        }
    }

    @objc private func onTask() {
        let alert = NSAlert()
        alert.messageText = "Task"
        alert.informativeText = "Titre obligatoire, échéance optionnelle via sélecteur."
        alert.addButton(withTitle: "Add")
        alert.addButton(withTitle: "Cancel")

        let container = NSView(frame: NSRect(x: 0, y: 0, width: 360, height: 98))
        let titleField = NSTextField(frame: NSRect(x: 0, y: 72, width: 360, height: 24))
        titleField.placeholderString = "Titre de la task"
        let dueDateToggle = NSButton(checkboxWithTitle: "Ajouter une échéance", target: nil, action: nil)
        dueDateToggle.frame = NSRect(x: 0, y: 42, width: 200, height: 22)

        let dueDatePicker = NSDatePicker(frame: NSRect(x: 0, y: 8, width: 220, height: 28))
        dueDatePicker.datePickerStyle = .textFieldAndStepper
        dueDatePicker.datePickerElements = [.yearMonthDay]
        dueDatePicker.dateValue = Date()
        dueDatePicker.isEnabled = false

        dueDateToggle.target = self
        dueDateToggle.action = #selector(onToggleDueDate(_:))
        dueDateToggle.identifier = NSUserInterfaceItemIdentifier("taskDueDateToggle")
        dueDatePicker.identifier = NSUserInterfaceItemIdentifier("taskDueDatePicker")

        container.addSubview(titleField)
        container.addSubview(dueDateToggle)
        container.addSubview(dueDatePicker)
        alert.accessoryView = container

        let response = alert.runModal()
        guard response == .alertFirstButtonReturn else { return }
        let dueDateEnabled = dueDateToggle.state == .on
        let dueDate = Validation.normalizeOptionalDueDate(selected: dueDatePicker.dateValue, enabled: dueDateEnabled)

        if captureController.submitTask(title: titleField.stringValue, dueDate: dueDate) {
            showInfo("Task ajoutée", detail: captureController.lastOutputFile?.path ?? "")
        } else {
            showError("Échec de l'ajout", detail: captureController.lastErrorMessage ?? "Erreur inconnue")
        }
    }

    @objc private func onToggleDueDate(_ sender: NSButton) {
        guard
            let container = sender.superview,
            let picker = container.subviews.first(where: { $0.identifier?.rawValue == "taskDueDatePicker" }) as? NSDatePicker
        else {
            return
        }
        picker.isEnabled = (sender.state == .on)
    }

    @objc private func onSettings() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.canCreateDirectories = true
        panel.allowsMultipleSelection = false
        panel.prompt = "Choisir"
        panel.message = "Sélectionne le dossier Obsidian de destination."

        if panel.runModal() == .OK, let url = panel.url {
            do {
                try settingsController.selectDestination(url)
                showInfo("Destination enregistrée", detail: url.path)
            } catch {
                showError("Impossible d'enregistrer la destination", detail: error.localizedDescription)
            }
        }
    }

    @objc private func onQuit() {
        NSApp.terminate(nil)
    }

    private func showInfo(_ title: String, detail: String) {
        let alert = NSAlert()
        alert.alertStyle = .informational
        alert.messageText = title
        alert.informativeText = detail
        alert.runModal()
    }

    private func showError(_ title: String, detail: String) {
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = title
        alert.informativeText = detail
        alert.runModal()
    }
    #endif
}
