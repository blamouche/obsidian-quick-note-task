import Foundation
#if canImport(AppKit)
import AppKit
#endif

public enum AppStatusKind: Equatable {
    case setupRequired
    case ready
    case recoveryRequired
}

public struct CaptureAvailabilityState: Equatable {
    public let quickNoteEnabled: Bool
    public let taskEnabled: Bool
    public let statusKind: AppStatusKind
    public let statusMessage: String
    public let settingsTitle: String
    public let blockedReason: String?

    public init(quickNoteEnabled: Bool,
                taskEnabled: Bool,
                statusKind: AppStatusKind,
                statusMessage: String,
                settingsTitle: String,
                blockedReason: String?) {
        self.quickNoteEnabled = quickNoteEnabled
        self.taskEnabled = taskEnabled
        self.statusKind = statusKind
        self.statusMessage = statusMessage
        self.settingsTitle = settingsTitle
        self.blockedReason = blockedReason
    }
}

public enum StatusAction {
    case quickNote
    case task
    case settings
}

@MainActor
public final class StatusBarController: NSObject {
    private let captureController: CaptureWindowController
    private let settingsController: SettingsController
    private var cachedAvailabilityState: CaptureAvailabilityState
    #if canImport(AppKit)
    private var statusItem: NSStatusItem?
    private var menu: NSMenu?
    private var menuStatusItem: NSMenuItem?
    private var menuQuickNoteItem: NSMenuItem?
    private var menuTaskItem: NSMenuItem?
    private var menuSettingsItem: NSMenuItem?
    #endif

    public init(captureController: CaptureWindowController = .init(),
                settingsController: SettingsController = .init()) {
        self.captureController = captureController
        self.settingsController = settingsController
        self.cachedAvailabilityState = Self.availabilityState(for: settingsController.destinationReadiness())
        super.init()
    }

    public func bootstrap() {
        #if canImport(AppKit)
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        item.button?.title = ""
        item.button?.image = AppIconFactory.makeStatusBarIcon()
        item.button?.toolTip = "Obsidian Quick Note Task"

        let menu = NSMenu()
        let statusEntry = NSMenuItem(title: "", action: nil, keyEquivalent: "")
        statusEntry.isEnabled = false
        menu.addItem(statusEntry)
        menu.addItem(.separator())
        let quickNoteEntry = NSMenuItem(title: "Quick Note", action: #selector(onQuickNote), keyEquivalent: "n")
        let taskEntry = NSMenuItem(title: "Task", action: #selector(onTask), keyEquivalent: "t")
        let settingsEntry = NSMenuItem(title: "Settings", action: #selector(onSettings), keyEquivalent: ",")
        menu.addItem(quickNoteEntry)
        menu.addItem(taskEntry)
        menu.addItem(.separator())
        menu.addItem(settingsEntry)
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(onQuit), keyEquivalent: "q"))

        for item in menu.items {
            item.target = self
        }

        item.menu = menu
        statusItem = item
        self.menu = menu
        menuStatusItem = statusEntry
        menuQuickNoteItem = quickNoteEntry
        menuTaskItem = taskEntry
        menuSettingsItem = settingsEntry
        refreshMenuState()
        #endif
    }

    public func currentAvailabilityState() -> CaptureAvailabilityState {
        let newState = Self.availabilityState(for: settingsController.destinationReadiness())
        cachedAvailabilityState = newState
        return newState
    }

    public func refreshMenuState() {
        let state = currentAvailabilityState()
        #if canImport(AppKit)
        menuStatusItem?.title = state.statusMessage
        menuQuickNoteItem?.isEnabled = state.quickNoteEnabled
        menuTaskItem?.isEnabled = state.taskEnabled
        menuSettingsItem?.title = state.settingsTitle
        #endif
    }

    public func handle(_ action: StatusAction) {
        let state = currentAvailabilityState()
        switch action {
        case .quickNote:
            guard state.quickNoteEnabled else {
                _ = captureController.rejectUnavailableAction(draft: "Quick capture placeholder",
                                                              reason: state.blockedReason ?? state.statusMessage)
                return
            }
            _ = captureController.submitQuickNote("Quick capture placeholder")
        case .task:
            guard state.taskEnabled else {
                _ = captureController.rejectUnavailableAction(draft: "Task capture placeholder",
                                                              reason: state.blockedReason ?? state.statusMessage)
                return
            }
            _ = captureController.submitTask(title: "Task capture placeholder", dueDate: nil)
        case .settings:
            _ = settingsController.currentDestination()
        }
    }

    private static func availabilityState(for readiness: DestinationReadiness) -> CaptureAvailabilityState {
        switch readiness {
        case .notConfigured:
            return CaptureAvailabilityState(
                quickNoteEnabled: false,
                taskEnabled: false,
                statusKind: .setupRequired,
                statusMessage: "Configuration requise: choisis un dossier Obsidian.",
                settingsTitle: "Configurer la destination...",
                blockedReason: "Configure d'abord un dossier de destination dans Settings."
            )
        case let .configuredValid(url):
            return CaptureAvailabilityState(
                quickNoteEnabled: true,
                taskEnabled: true,
                statusKind: .ready,
                statusMessage: "Prêt: destination active (\(url.lastPathComponent)).",
                settingsTitle: "Settings",
                blockedReason: nil
            )
        case .configuredInvalid:
            return CaptureAvailabilityState(
                quickNoteEnabled: false,
                taskEnabled: false,
                statusKind: .recoveryRequired,
                statusMessage: "Destination indisponible: reconfiguration nécessaire.",
                settingsTitle: "Reconfigurer la destination...",
                blockedReason: "La destination actuelle est indisponible. Reconfigure le dossier."
            )
        }
    }

    #if canImport(AppKit)
    @objc private func onQuickNote() {
        let state = currentAvailabilityState()
        guard state.quickNoteEnabled else {
            showError("Action indisponible", detail: state.blockedReason ?? state.statusMessage)
            return
        }

        let alert = NSAlert()
        alert.messageText = "Quick Note"
        alert.informativeText = "Capture rapide: saisis puis valide."
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
            showInfo("Ajout réussi", detail: captureController.lastOutputFile?.path ?? "")
        } else {
            showError("Échec de l'ajout", detail: captureController.lastErrorMessage ?? "Erreur inconnue")
        }
    }

    @objc private func onTask() {
        let state = currentAvailabilityState()
        guard state.taskEnabled else {
            showError("Action indisponible", detail: state.blockedReason ?? state.statusMessage)
            return
        }

        let alert = NSAlert()
        alert.messageText = "Task"
        alert.informativeText = "Titre requis, échéance optionnelle."
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
            showInfo("Ajout réussi", detail: captureController.lastOutputFile?.path ?? "")
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
                refreshMenuState()
            } catch {
                showError("Impossible d'enregistrer la destination", detail: error.localizedDescription)
            }
        } else {
            refreshMenuState()
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
