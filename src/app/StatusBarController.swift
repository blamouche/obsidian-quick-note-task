import Foundation
#if canImport(AppKit)
import AppKit
import QuartzCore
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
    #if canImport(AppKit)
    private final class GradientBackgroundView: NSVisualEffectView {
        private let tintLayer = CALayer()

        override init(frame frameRect: NSRect) {
            super.init(frame: frameRect)
            material = .hudWindow
            blendingMode = .behindWindow
            state = .active
            isEmphasized = false
            wantsLayer = true
            layer?.masksToBounds = true

            tintLayer.backgroundColor = NSColor.systemPurple.withAlphaComponent(0.08).cgColor
            layer?.addSublayer(tintLayer)
        }

        required init?(coder: NSCoder) {
            nil
        }

        override func layout() {
            super.layout()
            tintLayer.frame = bounds
        }
    }

    private final class InlineModalActionHandler: NSObject {
        var onPrimary: (() -> Void)?
        var onSecondary: (() -> Void)?

        @objc func handlePrimary(_ sender: Any?) {
            onPrimary?()
        }

        @objc func handleSecondary(_ sender: Any?) {
            onSecondary?()
        }
    }
    #endif

    private let captureController: CaptureWindowController
    private let settingsController: SettingsController
    private let appVersionLabel: String
    private var cachedAvailabilityState: CaptureAvailabilityState
    #if canImport(AppKit)
    private var activeModalActionHandler: InlineModalActionHandler?
    #endif
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
        self.appVersionLabel = Self.resolveAppVersionLabel()
        self.cachedAvailabilityState = Self.availabilityState(for: settingsController.configurationState())
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
        let newState = Self.availabilityState(for: settingsController.configurationState())
        cachedAvailabilityState = newState
        return newState
    }

    public func refreshMenuState() {
        let state = currentAvailabilityState()
        #if canImport(AppKit)
        menuStatusItem?.title = "\(state.statusMessage) • \(appVersionLabel)"
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

    private static func availabilityState(for configuration: SettingsConfigurationState) -> CaptureAvailabilityState {
        switch configuration.blockingReason {
        case .none:
            return CaptureAvailabilityState(
                quickNoteEnabled: true,
                taskEnabled: true,
                statusKind: .ready,
                statusMessage: "[Available] Ready: vault and folder are configured.",
                settingsTitle: "Settings...",
                blockedReason: nil,
                visualRole: .active
            )
        case .vaultMissing:
            return CaptureAvailabilityState(
                quickNoteEnabled: false,
                taskEnabled: false,
                statusKind: .setupRequired,
                statusMessage: "[Unavailable] Setup required: choose an Obsidian vault.",
                settingsTitle: "Configure Settings...",
                blockedReason: configuration.message,
                visualRole: .disabled
            )
        case .vaultInaccessible:
            return CaptureAvailabilityState(
                quickNoteEnabled: false,
                taskEnabled: false,
                statusKind: .recoveryRequired,
                statusMessage: "[Unavailable] Vault unavailable: reconfiguration required.",
                settingsTitle: "Reconfigure Settings...",
                blockedReason: configuration.message,
                visualRole: .disabled
            )
        case .folderMissing:
            return CaptureAvailabilityState(
                quickNoteEnabled: false,
                taskEnabled: false,
                statusKind: .setupRequired,
                statusMessage: "[Unavailable] Setup required: choose a default folder.",
                settingsTitle: "Configure Settings...",
                blockedReason: configuration.message,
                visualRole: .disabled
            )
        case .folderInaccessible, .folderOutsideVault:
            return CaptureAvailabilityState(
                quickNoteEnabled: false,
                taskEnabled: false,
                statusKind: .recoveryRequired,
                statusMessage: "[Unavailable] Default folder invalid: reconfiguration required.",
                settingsTitle: "Reconfigure Settings...",
                blockedReason: configuration.message,
                visualRole: .disabled
            )
        }
    }

    private static func resolveAppVersionLabel() -> String {
        let shortVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        let buildVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String

        if let shortVersion, !shortVersion.isEmpty {
            if let buildVersion, !buildVersion.isEmpty, buildVersion != shortVersion {
                return "v\(shortVersion) (\(buildVersion))"
            }
            return "v\(shortVersion)"
        }

        if let buildVersion, !buildVersion.isEmpty {
            return "v\(buildVersion)"
        }

        return "vdev"
    }

    #if canImport(AppKit)
    @objc private func onQuickNote() {
        let state = currentAvailabilityState()
        guard state.quickNoteEnabled else {
            showError("Action unavailable", detail: state.blockedReason ?? state.statusMessage)
            return
        }

        let profile = captureController.visualProfile()
        let width: CGFloat = 520
        let height: CGFloat = 320
        let inset = CGFloat(profile.spacing.windowPadding)
        let panel = makeModalPanel(title: "New Quick Note", width: width, height: height)
        let container = GradientBackgroundView(frame: NSRect(x: 0, y: 0, width: width, height: height))
        panel.contentView = container

        let titleLabel = makeTextLabel(
            "Quick input",
            size: CGFloat(profile.typography.title + 2),
            weight: .semibold,
            color: .labelColor
        )
        titleLabel.frame = NSRect(x: inset, y: height - inset - 28, width: width - (inset * 2), height: 26)

        let subtitleLabel = makeTextLabel(
            "Add a note with improved readability.",
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

        let buttonHeight: CGFloat = 30
        let statusHeight: CGFloat = 18
        let buttonsY = inset
        let statusY = buttonsY + buttonHeight + 10
        let editorY = statusY + statusHeight + 10
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

        let statusLabel = makeTextLabel(
            "",
            size: CGFloat(profile.typography.label),
            weight: .regular,
            color: .secondaryLabelColor
        )
        statusLabel.frame = NSRect(x: inset, y: statusY, width: width - (inset * 2), height: statusHeight)

        let addButton = NSButton(title: "Add", target: nil, action: nil)
        addButton.bezelStyle = .rounded
        addButton.keyEquivalent = "\r"
        addButton.frame = NSRect(x: width - inset - 100, y: buttonsY, width: 100, height: buttonHeight)

        let cancelButton = NSButton(title: "Cancel", target: nil, action: nil)
        cancelButton.bezelStyle = .rounded
        cancelButton.keyEquivalent = "\u{1b}"
        cancelButton.frame = NSRect(x: addButton.frame.minX - 110, y: buttonsY, width: 100, height: buttonHeight)

        scrollView.documentView = textView
        container.addSubview(titleLabel)
        container.addSubview(subtitleLabel)
        container.addSubview(scrollView)
        container.addSubview(statusLabel)
        container.addSubview(cancelButton)
        container.addSubview(addButton)
        let actionHandler = InlineModalActionHandler()
        activeModalActionHandler = actionHandler

        actionHandler.onSecondary = { [weak self, weak panel] in
            guard let self, let panel else { return }
            NSApp.stopModal(withCode: .cancel)
            panel.orderOut(nil)
            self.activeModalActionHandler = nil
        }

        actionHandler.onPrimary = { [weak self, weak panel, weak addButton, weak cancelButton] in
            guard let self, let panel, let addButton, let cancelButton else { return }
            if self.captureController.submitQuickNote(textView.string) {
                statusLabel.stringValue = "Added successfully. Closing..."
                statusLabel.textColor = NSColor.systemGreen
                addButton.isEnabled = false
                cancelButton.isEnabled = false
                textView.isEditable = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    NSApp.stopModal(withCode: .OK)
                    panel.orderOut(nil)
                    self.activeModalActionHandler = nil
                }
            } else {
                statusLabel.stringValue = self.captureController.lastErrorMessage ?? "Unknown error"
                statusLabel.textColor = NSColor.systemRed
            }
        }

        addButton.target = actionHandler
        addButton.action = #selector(InlineModalActionHandler.handlePrimary(_:))
        cancelButton.target = actionHandler
        cancelButton.action = #selector(InlineModalActionHandler.handleSecondary(_:))

        NSApp.activate(ignoringOtherApps: true)
        panel.makeKeyAndOrderFront(nil)
        _ = NSApp.runModal(for: panel)
    }

    @objc private func onTask() {
        let state = currentAvailabilityState()
        guard state.taskEnabled else {
            showError("Action unavailable", detail: state.blockedReason ?? state.statusMessage)
            return
        }

        let profile = captureController.visualProfile()
        let width: CGFloat = 500
        let height: CGFloat = 430
        let inset = CGFloat(profile.spacing.windowPadding)
        let fieldGap = CGFloat(profile.spacing.fieldGap)
        let panel = makeModalPanel(title: "New Task", width: width, height: height)
        let container = GradientBackgroundView(frame: NSRect(x: 0, y: 0, width: width, height: height))
        panel.contentView = container

        let titleLabel = makeTextLabel(
            "Task title",
            size: CGFloat(profile.typography.label),
            weight: .medium,
            color: .labelColor
        )
        titleLabel.frame = NSRect(x: inset, y: height - inset - 20, width: width - (inset * 2), height: 18)

        let titleField = NSTextField(frame: NSRect(x: inset, y: titleLabel.frame.minY - fieldGap - 28, width: width - (inset * 2), height: 28))
        titleField.font = NSFont.systemFont(ofSize: CGFloat(profile.typography.input), weight: .regular)
        titleField.placeholderString = "e.g. Review today's note"
        titleField.bezelStyle = .roundedBezel

        let dueDateToggle = NSButton(checkboxWithTitle: "Add due date", target: nil, action: nil)
        dueDateToggle.font = NSFont.systemFont(ofSize: CGFloat(profile.typography.label), weight: .regular)
        dueDateToggle.frame = NSRect(x: inset, y: titleField.frame.minY - CGFloat(profile.spacing.sectionGap) - 24, width: width - (inset * 2), height: 22)

        let calendarHeight: CGFloat = 170
        let dueDatePicker = NSDatePicker(frame: NSRect(
            x: inset,
            y: dueDateToggle.frame.minY - fieldGap - calendarHeight,
            width: width - (inset * 2),
            height: calendarHeight
        ))
        dueDatePicker.datePickerStyle = .clockAndCalendar
        dueDatePicker.datePickerMode = .single
        dueDatePicker.datePickerElements = [.yearMonthDay]
        dueDatePicker.dateValue = Date()
        dueDatePicker.isEnabled = false

        let statusLabel = makeTextLabel(
            "",
            size: CGFloat(profile.typography.label),
            weight: .regular,
            color: .secondaryLabelColor
        )
        statusLabel.frame = NSRect(x: inset, y: inset + 40, width: width - (inset * 2), height: 18)

        let addButton = NSButton(title: "Add", target: nil, action: nil)
        addButton.bezelStyle = .rounded
        addButton.keyEquivalent = "\r"
        addButton.frame = NSRect(x: width - inset - 100, y: inset, width: 100, height: 30)

        let cancelButton = NSButton(title: "Cancel", target: nil, action: nil)
        cancelButton.bezelStyle = .rounded
        cancelButton.keyEquivalent = "\u{1b}"
        cancelButton.frame = NSRect(x: addButton.frame.minX - 110, y: inset, width: 100, height: 30)

        dueDateToggle.target = self
        dueDateToggle.action = #selector(onToggleDueDate(_:))
        dueDateToggle.identifier = NSUserInterfaceItemIdentifier("taskDueDateToggle")
        dueDatePicker.identifier = NSUserInterfaceItemIdentifier("taskDueDatePicker")

        container.addSubview(titleLabel)
        container.addSubview(titleField)
        container.addSubview(dueDateToggle)
        container.addSubview(dueDatePicker)
        container.addSubview(statusLabel)
        container.addSubview(cancelButton)
        container.addSubview(addButton)

        let actionHandler = InlineModalActionHandler()
        activeModalActionHandler = actionHandler

        actionHandler.onSecondary = { [weak self, weak panel] in
            guard let self, let panel else { return }
            NSApp.stopModal(withCode: .cancel)
            panel.orderOut(nil)
            self.activeModalActionHandler = nil
        }

        actionHandler.onPrimary = { [weak self, weak panel, weak addButton, weak cancelButton] in
            guard let self, let panel, let addButton, let cancelButton else { return }
            let dueDateEnabled = dueDateToggle.state == .on
            let dueDate = Validation.normalizeOptionalDueDate(selected: dueDatePicker.dateValue, enabled: dueDateEnabled)

            if self.captureController.submitTask(title: titleField.stringValue, dueDate: dueDate) {
                statusLabel.stringValue = "Added successfully. Closing..."
                statusLabel.textColor = NSColor.systemGreen
                addButton.isEnabled = false
                cancelButton.isEnabled = false
                titleField.isEnabled = false
                dueDateToggle.isEnabled = false
                dueDatePicker.isEnabled = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    NSApp.stopModal(withCode: .OK)
                    panel.orderOut(nil)
                    self.activeModalActionHandler = nil
                }
            } else {
                statusLabel.stringValue = self.captureController.lastErrorMessage ?? "Unknown error"
                statusLabel.textColor = NSColor.systemRed
            }
        }

        addButton.target = actionHandler
        addButton.action = #selector(InlineModalActionHandler.handlePrimary(_:))
        cancelButton.target = actionHandler
        cancelButton.action = #selector(InlineModalActionHandler.handleSecondary(_:))

        NSApp.activate(ignoringOtherApps: true)
        panel.makeKeyAndOrderFront(nil)
        _ = NSApp.runModal(for: panel)
    }

    private func makeModalPanel(title: String, width: CGFloat, height: CGFloat) -> NSPanel {
        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: width, height: height),
            styleMask: [.titled],
            backing: .buffered,
            defer: false
        )
        panel.title = title
        panel.isFloatingPanel = true
        panel.level = .modalPanel
        panel.center()
        return panel
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
        settingsController.presentSettingsWindow { [weak self] in
            self?.refreshMenuState()
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
