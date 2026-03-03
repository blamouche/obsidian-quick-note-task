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
        item.button?.title = "📝"
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
            _ = captureController.submitTask(title: "Task capture placeholder", dueDateInput: nil)
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

        let input = NSTextField(frame: NSRect(x: 0, y: 0, width: 360, height: 24))
        input.placeholderString = "Ex: idée, rappel, phrase..."
        alert.accessoryView = input

        let response = alert.runModal()
        guard response == .alertFirstButtonReturn else { return }

        if captureController.submitQuickNote(input.stringValue) {
            showInfo("Quick note ajoutée", detail: captureController.lastOutputFile?.path ?? "")
        } else {
            showError("Échec de l'ajout", detail: captureController.lastErrorMessage ?? "Erreur inconnue")
        }
    }

    @objc private func onTask() {
        let alert = NSAlert()
        alert.messageText = "Task"
        alert.informativeText = "Titre obligatoire, échéance optionnelle (YYYY-MM-DD)."
        alert.addButton(withTitle: "Add")
        alert.addButton(withTitle: "Cancel")

        let container = NSView(frame: NSRect(x: 0, y: 0, width: 360, height: 64))
        let titleField = NSTextField(frame: NSRect(x: 0, y: 36, width: 360, height: 24))
        titleField.placeholderString = "Titre de la task"
        let dueDateField = NSTextField(frame: NSRect(x: 0, y: 4, width: 360, height: 24))
        dueDateField.placeholderString = "Échéance optionnelle: YYYY-MM-DD"
        container.addSubview(titleField)
        container.addSubview(dueDateField)
        alert.accessoryView = container

        let response = alert.runModal()
        guard response == .alertFirstButtonReturn else { return }
        let dueDateInput = dueDateField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        let dueDate = dueDateInput.isEmpty ? nil : dueDateInput

        if captureController.submitTask(title: titleField.stringValue, dueDateInput: dueDate) {
            showInfo("Task ajoutée", detail: captureController.lastOutputFile?.path ?? "")
        } else {
            showError("Échec de l'ajout", detail: captureController.lastErrorMessage ?? "Erreur inconnue")
        }
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
