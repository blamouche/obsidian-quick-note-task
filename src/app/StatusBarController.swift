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
    public let visualRole: UIStateRole

    public init(quickNoteEnabled: Bool,
                taskEnabled: Bool,
                statusKind: AppStatusKind,
                statusMessage: String,
                settingsTitle: String,
                blockedReason: String?,
                visualRole: UIStateRole) {
        self.quickNoteEnabled = quickNoteEnabled
        self.taskEnabled = taskEnabled
        self.statusKind = statusKind
        self.statusMessage = statusMessage
        self.settingsTitle = settingsTitle
        self.blockedReason = blockedReason
        self.visualRole = visualRole
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

    public func visualState(for role: UIStateRole) -> VisualStateStyle {
        UIStyle.stateStyle(for: role)
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
                statusMessage: "[Indisponible] Configuration requise: choisis un dossier Obsidian.",
                settingsTitle: "Configurer la destination...",
                blockedReason: "Configure d'abord un dossier de destination dans Settings.",
                visualRole: .disabled
            )
        case let .configuredValid(url):
            return CaptureAvailabilityState(
                quickNoteEnabled: true,
                taskEnabled: true,
                statusKind: .ready,
                statusMessage: "[Disponible] Pret: destination active (\(url.lastPathComponent)).",
                settingsTitle: "Settings",
                blockedReason: nil,
                visualRole: .active
            )
        case .configuredInvalid:
            return CaptureAvailabilityState(
                quickNoteEnabled: false,
                taskEnabled: false,
                statusKind: .recoveryRequired,
                statusMessage: "[Indisponible] Destination indisponible: reconfiguration necessaire.",
                settingsTitle: "Reconfigurer la destination...",
                blockedReason: "La destination actuelle est indisponible. Reconfigure le dossier.",
                visualRole: .disabled
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
        configureAlertWithoutIcon(alert)
        let profile = captureController.visualProfile()
        alert.messageText = "Nouvelle Quick Note"
        alert.informativeText = "Capture claire et rapide"
        alert.addButton(withTitle: "Ajouter")
        alert.addButton(withTitle: "Annuler")

        let width: CGFloat = 520
        let height: CGFloat = 256
        let inset = CGFloat(profile.spacing.windowPadding)
        let container = NSView(frame: NSRect(x: 0, y: 0, width: width, height: height))

        let titleLabel = makeTextLabel(
            "Saisie rapide",
            size: CGFloat(profile.typography.title + 2),
            weight: .semibold,
            color: .labelColor
        )
        titleLabel.frame = NSRect(x: inset, y: height - inset - 28, width: width - (inset * 2), height: 26)

        let subtitleLabel = makeTextLabel(
            "Ajoute une note avec une lisibilite renforcee.",
            size: CGFloat(profile.typography.label),
            weight: .regular,
            color: .secondaryLabelColor
        )
        subtitleLabel.frame = NSRect(
            x: inset,
            y: titleLabel.frame.minY - CGFloat(profile.spacing.fieldGap) - 18,
            width: width - (inset * 2),
            height: 18
        )

        let editorY = inset
        let editorHeight = subtitleLabel.frame.minY - CGFloat(profile.spacing.sectionGap) - editorY
        let scrollView = NSScrollView(frame: NSRect(
            x: inset,
            y: editorY,
            width: width - (inset * 2),
            height: editorHeight
        ))
        scrollView.hasVerticalScroller = true
        scrollView.borderType = .bezelBorder
        scrollView.wantsLayer = true
        scrollView.layer?.cornerRadius = 10
        scrollView.layer?.borderWidth = 1
        scrollView.layer?.borderColor = NSColor.separatorColor.cgColor

        let textView = NSTextView(frame: NSRect(x: 0, y: 0, width: scrollView.frame.width, height: scrollView.frame.height))
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.autoresizingMask = [.width]
        textView.font = NSFont.systemFont(ofSize: CGFloat(profile.typography.input), weight: .regular)
        textView.string = ""
        textView.insertionPointColor = .controlAccentColor

        scrollView.documentView = textView
        container.addSubview(titleLabel)
        container.addSubview(subtitleLabel)
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
        configureAlertWithoutIcon(alert)
        let profile = captureController.visualProfile()
        alert.messageText = "Nouvelle Task"
        alert.informativeText = "Structure claire et compacte"
        alert.addButton(withTitle: "Ajouter")
        alert.addButton(withTitle: "Annuler")

        let width: CGFloat = 500
        let height: CGFloat = 210
        let inset = CGFloat(profile.spacing.windowPadding)
        let fieldGap = CGFloat(profile.spacing.fieldGap)
        let container = NSView(frame: NSRect(x: 0, y: 0, width: width, height: height))

        let titleLabel = makeTextLabel(
            "Titre de la task",
            size: CGFloat(profile.typography.label),
            weight: .medium,
            color: .labelColor
        )
        titleLabel.frame = NSRect(x: inset, y: height - inset - 20, width: width - (inset * 2), height: 18)

        let titleField = NSTextField(frame: NSRect(x: inset, y: titleLabel.frame.minY - fieldGap - 28, width: width - (inset * 2), height: 28))
        titleField.font = NSFont.systemFont(ofSize: CGFloat(profile.typography.input), weight: .regular)
        titleField.placeholderString = "Ex: Relire la note du jour"
        titleField.bezelStyle = .roundedBezel

        let dueDateToggle = NSButton(checkboxWithTitle: "Ajouter une echeance", target: nil, action: nil)
        dueDateToggle.font = NSFont.systemFont(ofSize: CGFloat(profile.typography.label), weight: .regular)
        dueDateToggle.frame = NSRect(x: inset, y: titleField.frame.minY - CGFloat(profile.spacing.sectionGap) - 24, width: width - (inset * 2), height: 22)

        let dueDatePicker = NSDatePicker(frame: NSRect(x: inset + 4, y: dueDateToggle.frame.minY - fieldGap - 30, width: 240, height: 28))
        dueDatePicker.datePickerStyle = .textFieldAndStepper
        dueDatePicker.datePickerElements = [.yearMonthDay]
        dueDatePicker.dateValue = Date()
        dueDatePicker.isEnabled = false

        dueDateToggle.target = self
        dueDateToggle.action = #selector(onToggleDueDate(_:))
        dueDateToggle.identifier = NSUserInterfaceItemIdentifier("taskDueDateToggle")
        dueDatePicker.identifier = NSUserInterfaceItemIdentifier("taskDueDatePicker")

        container.addSubview(titleLabel)
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
        panel.prompt = settingsController.visualProfile().folderAffordance.actionLabel
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
        configureAlertWithoutIcon(alert)
        alert.alertStyle = .informational
        let cue = visualState(for: .success).nonColorCue
        alert.messageText = cue.isEmpty ? title : "[\(cue)] \(title)"
        alert.informativeText = detail
        alert.runModal()
    }

    private func showError(_ title: String, detail: String) {
        let alert = NSAlert()
        configureAlertWithoutIcon(alert)
        alert.alertStyle = .warning
        let cue = visualState(for: .error).nonColorCue
        alert.messageText = cue.isEmpty ? title : "[\(cue)] \(title)"
        alert.informativeText = detail
        alert.runModal()
    }

    private func makeTextLabel(_ text: String,
                               size: CGFloat,
                               weight: NSFont.Weight,
                               color: NSColor) -> NSTextField {
        let label = NSTextField(labelWithString: text)
        label.font = NSFont.systemFont(ofSize: size, weight: weight)
        label.textColor = color
        label.isBordered = false
        label.drawsBackground = false
        return label
    }

    private func configureAlertWithoutIcon(_ alert: NSAlert) {
        alert.icon = NSImage(size: NSSize(width: 1, height: 1))
    }
    #endif
}
