import Foundation
#if canImport(AppKit)
import AppKit
#endif

public enum AppStatusKind: Equatable {
    case setupRequired
    case ready
    case recoveryRequired
}

#if canImport(AppKit)
extension StatusBarController: NSMenuDelegate {
    public func menuWillOpen(_ menu: NSMenu) {
        refreshMenuState()
    }
}
#endif

public struct CaptureAvailabilityState: Equatable {
    public let quickNoteEnabled: Bool
    public let taskEnabled: Bool
    public let newNoteEnabled: Bool
    public let statusKind: AppStatusKind
    public let statusMessage: String
    public let settingsTitle: String
    public let blockedReason: String?
    public let visualRole: UIStateRole

    public init(quickNoteEnabled: Bool,
                taskEnabled: Bool,
                newNoteEnabled: Bool,
                statusKind: AppStatusKind,
                statusMessage: String,
                settingsTitle: String,
                blockedReason: String?,
                visualRole: UIStateRole) {
        self.quickNoteEnabled = quickNoteEnabled
        self.taskEnabled = taskEnabled
        self.newNoteEnabled = newNoteEnabled
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
        case newNote
        case settings
        case github
    }

@MainActor
public final class StatusBarController: NSObject {
    #if canImport(AppKit)
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

    private final class DropdownTaskActionHandler: NSObject {
        var onToggle: (() -> Void)?
        var onOpenSource: (() -> Void)?

        @objc func handleToggle(_ sender: Any?) {
            onToggle?()
        }

        @objc func handleOpenSource(_ sender: Any?) {
            onOpenSource?()
        }
    }
    #endif

    private let captureController: CaptureWindowController
    private let settingsController: SettingsController
    private let taskScanner: VaultTaskScanner
    private let taskToggleService: TaskToggleService
    private let appVersionLabel: String
    private var cachedAvailabilityState: CaptureAvailabilityState
    private var currentDropdownTasks: [DropdownTaskItem]
    #if canImport(AppKit)
    private var activeModalActionHandler: InlineModalActionHandler?
    #endif
    #if canImport(AppKit)
    private var statusItem: NSStatusItem?
    private var menu: NSMenu?
    private var menuStatusItem: NSMenuItem?
    private var menuQuickNoteItem: NSMenuItem?
    private var menuTaskItem: NSMenuItem?
    private var menuNewNoteItem: NSMenuItem?
    private var menuTasksDividerTop: NSMenuItem?
    private var menuTasksDividerBottom: NSMenuItem?
    private var menuDropdownTaskItems: [NSMenuItem] = []
    private var menuDropdownTaskActionHandlers: [DropdownTaskActionHandler] = []
    private var menuDropdownTaskViewsByID: [String: NSView] = [:]
    private var menuSettingsItem: NSMenuItem?
    private var menuGithubItem: NSMenuItem?
    #endif

    public init(captureController: CaptureWindowController = .init(),
                settingsController: SettingsController = .init(),
                taskScanner: VaultTaskScanner = .init(),
                taskToggleService: TaskToggleService = .init()) {
        self.captureController = captureController
        self.settingsController = settingsController
        self.taskScanner = taskScanner
        self.taskToggleService = taskToggleService
        self.appVersionLabel = Self.resolveAppVersionLabel()
        self.cachedAvailabilityState = Self.availabilityState(for: settingsController.configurationState())
        self.currentDropdownTasks = []
        super.init()
    }

    public func bootstrap() {
        #if canImport(AppKit)
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        item.button?.title = ""
        item.button?.image = AppIconFactory.makeStatusBarIcon(
            statusColor: indicatorColor(for: cachedAvailabilityState),
            warningBadge: shouldShowWarningBadge(for: cachedAvailabilityState)
        )
        item.button?.toolTip = "Obsidian Quick Note Task"

        let menu = NSMenu()
        menu.delegate = self
        let statusEntry = NSMenuItem(title: "", action: nil, keyEquivalent: "")
        statusEntry.isEnabled = false
        menu.addItem(statusEntry)
        menu.addItem(.separator())
        let quickNoteEntry = NSMenuItem(title: "Quick Note", action: #selector(onQuickNote), keyEquivalent: "n")
        let taskEntry = NSMenuItem(title: "Task", action: #selector(onTask), keyEquivalent: "t")
        let newNoteEntry = NSMenuItem(title: "New note", action: #selector(onNewNote), keyEquivalent: "m")
        let settingsEntry = NSMenuItem(title: "Settings", action: #selector(onSettings), keyEquivalent: ",")
        let githubEntry = NSMenuItem(title: "Github", action: #selector(onGithub), keyEquivalent: "g")
        let tasksDividerTop = NSMenuItem.separator()
        let tasksDividerBottom = NSMenuItem.separator()
        menu.addItem(quickNoteEntry)
        menu.addItem(taskEntry)
        menu.addItem(newNoteEntry)
        menu.addItem(tasksDividerTop)
        menu.addItem(tasksDividerBottom)
        menu.addItem(settingsEntry)
        menu.addItem(githubEntry)
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
        menuNewNoteItem = newNoteEntry
        menuTasksDividerTop = tasksDividerTop
        menuTasksDividerBottom = tasksDividerBottom
        menuSettingsItem = settingsEntry
        menuGithubItem = githubEntry
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
        currentDropdownTasks = loadDropdownTasks()
        #if canImport(AppKit)
        statusItem?.button?.image = AppIconFactory.makeStatusBarIcon(
            statusColor: indicatorColor(for: state),
            warningBadge: shouldShowWarningBadge(for: state)
        )
        menuStatusItem?.title = "\(state.statusMessage) • \(appVersionLabel)"
        menuQuickNoteItem?.isEnabled = state.quickNoteEnabled
        menuTaskItem?.isEnabled = state.taskEnabled
        menuNewNoteItem?.isEnabled = state.newNoteEnabled
        menuSettingsItem?.title = state.settingsTitle
        rebuildDropdownTaskSection()
        #endif
    }

    public func dropdownTaskItemsForCurrentState() -> [DropdownTaskItem] {
        loadDropdownTasks()
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
        case .newNote:
            guard state.newNoteEnabled else {
                _ = captureController.rejectUnavailableAction(draft: "New note capture placeholder",
                                                              reason: state.blockedReason ?? state.statusMessage)
                return
            }
            let title = captureController.suggestedNewNoteTitlePrefix() + "New note"
            _ = captureController.submitStandaloneNote(title: title, content: "")
        case .settings:
            _ = settingsController.currentDestination()
        case .github:
            #if canImport(AppKit)
            if let url = URL(string: "https://github.com/blamouche/obsidian-quick-note-task") {
                _ = NSWorkspace.shared.open(url)
            }
            #endif
        }
    }

    private func loadDropdownTasks() -> [DropdownTaskItem] {
        guard let vaultURL = settingsController.currentVault() else {
            return []
        }
        let exclusion = settingsController.currentTaskExclusionText()
        return taskScanner.scanDueTasks(vaultURL: vaultURL, exclusionText: exclusion)
    }

    private static func availabilityState(for configuration: SettingsConfigurationState) -> CaptureAvailabilityState {
        switch configuration.blockingReason {
        case .none:
            return CaptureAvailabilityState(
                quickNoteEnabled: true,
                taskEnabled: true,
                newNoteEnabled: true,
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
                newNoteEnabled: false,
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
                newNoteEnabled: false,
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
                newNoteEnabled: false,
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
                newNoteEnabled: false,
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

    private static let dropdownDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter
    }()

    func sanitizedDropdownTaskTitle(_ title: String) -> String {
        let pattern = "https?://\\S+"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else {
            return title
        }

        let range = NSRange(location: 0, length: title.utf16.count)
        let withoutURLs = regex.stringByReplacingMatches(in: title, options: [], range: range, withTemplate: "")
        let collapsedWhitespace = withoutURLs.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        return collapsedWhitespace.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func dropdownLateIcon(for task: DropdownTaskItem) -> String {
        task.isOverdue ? "⚠︎" : ""
    }

    func dropdownRecurrenceIcon(for task: DropdownTaskItem) -> String {
        task.recurrence == nil ? "" : "↻"
    }

    private func recurrenceRuleForTaskUISelection(_ label: String) -> String {
        switch label {
        case "Every day":
            return "every day"
        case "Every weekday":
            return "every weekday"
        case "Every week":
            return "every week"
        case "Every month":
            return "every month"
        case "Every year":
            return "every year"
        case "Every 3 days":
            return "every 3 days"
        case "Every 2 months":
            return "every 2 months"
        default:
            return "every day"
        }
    }

    func dropdownMenuTitle(for task: DropdownTaskItem) -> String {
        let dueDateText = Self.dropdownDateFormatter.string(from: task.dueDate)
        let sanitizedTitle = sanitizedDropdownTaskTitle(task.title)
        return "\(sanitizedTitle) (\(dueDateText))"
    }

    #if canImport(AppKit)
    private func indicatorColor(for state: CaptureAvailabilityState) -> NSColor {
        state.quickNoteEnabled && state.taskEnabled ? .systemGreen : .systemRed
    }

    private func shouldShowWarningBadge(for state: CaptureAvailabilityState) -> Bool {
        !(state.quickNoteEnabled && state.taskEnabled)
    }

    private func rebuildDropdownTaskSection() {
        guard let menu, let menuTasksDividerTop, let menuTasksDividerBottom else {
            return
        }

        for item in menuDropdownTaskItems {
            menu.removeItem(item)
        }
        menuDropdownTaskItems.removeAll()
        menuDropdownTaskActionHandlers.removeAll()
        menuDropdownTaskViewsByID.removeAll()

        let hasVault = settingsController.currentVault() != nil
        let shouldShowSection = hasVault
        menuTasksDividerTop.isHidden = !shouldShowSection
        menuTasksDividerBottom.isHidden = !shouldShowSection

        guard shouldShowSection else {
            return
        }

        let insertionIndex = menu.index(of: menuTasksDividerBottom)
        guard insertionIndex >= 0 else {
            return
        }

        let headerItem = NSMenuItem(title: "Tasks", action: nil, keyEquivalent: "")
        headerItem.isEnabled = false
        menu.insertItem(headerItem, at: insertionIndex)
        menuDropdownTaskItems.append(headerItem)

        let listInsertionIndex = insertionIndex + 1

        if currentDropdownTasks.isEmpty {
            let emptyItem = NSMenuItem(title: "No due/overdue tasks", action: nil, keyEquivalent: "")
            emptyItem.isEnabled = false
            menu.insertItem(emptyItem, at: listInsertionIndex)
            menuDropdownTaskItems.append(emptyItem)
            return
        }

        var runningIndex = listInsertionIndex
        for task in currentDropdownTasks {
            let item = makeDropdownTaskMenuItem(for: task)
            menu.insertItem(item, at: runningIndex)
            menuDropdownTaskItems.append(item)
            runningIndex += 1
        }
    }

    @objc private func onToggleDropdownTask(_ sender: NSMenuItem) {
        guard let id = sender.representedObject as? String else {
            showError("Task update failed", detail: "Task reference not found.")
            return
        }
        handleTaskCompletion(for: id)
    }

    private func makeDropdownTaskMenuItem(for task: DropdownTaskItem) -> NSMenuItem {
        let item = NSMenuItem()
        item.isEnabled = false
        item.view = makeDropdownTaskView(for: task)
        return item
    }

    private func makeDropdownTaskView(for task: DropdownTaskItem) -> NSView {
        let rowHeight: CGFloat = 24
        let rowWidth: CGFloat = 500
        let rowView = NSView(frame: NSRect(x: 0, y: 0, width: rowWidth, height: rowHeight))

        let actionHandler = DropdownTaskActionHandler()
        actionHandler.onToggle = { [weak self] in
            self?.handleTaskCompletion(for: task.id)
        }
        actionHandler.onOpenSource = { [weak self] in
            self?.openTaskSourceInObsidian(for: task.id)
        }
        menuDropdownTaskActionHandlers.append(actionHandler)

        let toggleButton = NSButton(title: "☐", target: actionHandler, action: #selector(DropdownTaskActionHandler.handleToggle(_:)))
        toggleButton.isBordered = false
        toggleButton.bezelStyle = .inline
        toggleButton.font = NSFont.systemFont(ofSize: 13, weight: .regular)
        toggleButton.contentTintColor = task.isOverdue ? .systemRed : .labelColor
        toggleButton.toolTip = "Mark task as completed"
        toggleButton.frame = NSRect(x: 6, y: 1, width: 18, height: 22)
        toggleButton.identifier = NSUserInterfaceItemIdentifier("taskRowToggle")

        let lateLabel = NSTextField(labelWithString: dropdownLateIcon(for: task))
        lateLabel.font = NSFont.systemFont(ofSize: 13, weight: .regular)
        lateLabel.textColor = .systemRed
        lateLabel.frame = NSRect(x: 30, y: 4, width: 14, height: 16)

        let recurringLabel = NSTextField(labelWithString: dropdownRecurrenceIcon(for: task))
        recurringLabel.font = NSFont.systemFont(ofSize: 13, weight: .regular)
        recurringLabel.textColor = .secondaryLabelColor
        recurringLabel.frame = NSRect(x: 46, y: 4, width: 14, height: 16)

        let linkButton = NSButton(title: "↗", target: actionHandler, action: #selector(DropdownTaskActionHandler.handleOpenSource(_:)))
        linkButton.isBordered = false
        linkButton.bezelStyle = .inline
        linkButton.font = NSFont.systemFont(ofSize: 13, weight: .regular)
        linkButton.toolTip = "Open source note in Obsidian"
        linkButton.frame = NSRect(x: rowWidth - 24, y: 1, width: 18, height: 22)
        linkButton.identifier = NSUserInterfaceItemIdentifier("taskRowLink")

        let titleLabel = NSTextField(labelWithString: dropdownMenuTitle(for: task))
        titleLabel.font = NSFont.systemFont(ofSize: 13, weight: .regular)
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.frame = NSRect(x: 64, y: 4, width: rowWidth - 92, height: 16)
        titleLabel.identifier = NSUserInterfaceItemIdentifier("taskRowTitle")

        rowView.addSubview(toggleButton)
        rowView.addSubview(lateLabel)
        rowView.addSubview(recurringLabel)
        rowView.addSubview(titleLabel)
        rowView.addSubview(linkButton)
        menuDropdownTaskViewsByID[task.id] = rowView

        return rowView
    }

    private func handleTaskCompletion(for id: String) {
        guard let task = currentDropdownTasks.first(where: { $0.id == id }) else {
            showError("Task update failed", detail: "Task reference not found.")
            return
        }

        let result = taskToggleService.toggleComplete(task: task, vaultURL: settingsController.currentVault())
        switch result.errorType {
        case .none:
            markDropdownTaskAsCompleted(id: id)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                self?.refreshMenuState()
            }
        case .invalidRecurrence:
            markDropdownTaskAsCompleted(id: id)
            showError("Recurrence warning", detail: result.userMessage)
            openTaskSourceInObsidian(for: id)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                self?.refreshMenuState()
            }
        case .writeFailure, .staleReference:
            showError("Task update failed", detail: result.userMessage)
            refreshMenuState()
        }
    }

    private func markDropdownTaskAsCompleted(id: String) {
        guard let rowView = menuDropdownTaskViewsByID[id] else {
            return
        }

        if let toggleButton = rowView.subviews.first(where: { $0.identifier?.rawValue == "taskRowToggle" }) as? NSButton {
            toggleButton.title = "☒"
            toggleButton.isEnabled = false
        }

        if let linkButton = rowView.subviews.first(where: { $0.identifier?.rawValue == "taskRowLink" }) as? NSButton {
            linkButton.isEnabled = false
        }

        if let titleLabel = rowView.subviews.first(where: { $0.identifier?.rawValue == "taskRowTitle" }) as? NSTextField {
            let attributes: [NSAttributedString.Key: Any] = [
                .strikethroughStyle: NSUnderlineStyle.single.rawValue,
                .foregroundColor: NSColor.secondaryLabelColor
            ]
            titleLabel.attributedStringValue = NSAttributedString(string: titleLabel.stringValue, attributes: attributes)
        }
    }

    private func openTaskSourceInObsidian(for id: String) {
        guard let task = currentDropdownTasks.first(where: { $0.id == id }) else {
            showError("Open source failed", detail: "Task reference not found.")
            return
        }

        guard let vaultURL = settingsController.currentVault() else {
            showError("Open source failed", detail: "Vault is not configured.")
            return
        }

        guard let url = obsidianOpenURL(for: task, vaultURL: vaultURL) else {
            showError("Open source failed", detail: "Could not build Obsidian file link.")
            return
        }

        if !NSWorkspace.shared.open(url) {
            showError("Open source failed", detail: "Could not open source file in Obsidian.")
        }
    }

    private func obsidianOpenURL(for task: DropdownTaskItem, vaultURL: URL) -> URL? {
        let normalizedVaultPath = vaultURL.standardizedFileURL.path
        let normalizedFilePath = task.source.fileURL.standardizedFileURL.path

        guard normalizedFilePath.hasPrefix(normalizedVaultPath + "/") else {
            return nil
        }

        let relativePath = String(normalizedFilePath.dropFirst(normalizedVaultPath.count + 1))
        guard !relativePath.isEmpty else {
            return nil
        }

        var components = URLComponents()
        components.scheme = "obsidian"
        components.host = "open"
        components.queryItems = [
            URLQueryItem(name: "vault", value: vaultURL.lastPathComponent),
            URLQueryItem(name: "file", value: relativePath)
        ]
        return components.url
    }

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
        let container = WindowBackgroundView(frame: NSRect(x: 0, y: 0, width: width, height: height))
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
        textView.isRichText = false
        textView.importsGraphics = false
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticTextReplacementEnabled = false
        textView.isAutomaticSpellingCorrectionEnabled = false
        textView.smartInsertDeleteEnabled = false
        textView.textContainerInset = NSSize(width: 10, height: 10)
        textView.textContainer?.lineFragmentPadding = 6
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
        let width: CGFloat = 640
        let height: CGFloat = 430
        let inset = CGFloat(profile.spacing.windowPadding)
        let fieldGap = CGFloat(profile.spacing.fieldGap)
        let columnGap: CGFloat = 16
        let columnsWidth = width - (inset * 2)
        let columnWidth = (columnsWidth - columnGap) / 2
        let rightColumnX = inset + columnWidth + columnGap
        let panel = makeModalPanel(title: "New Task", width: width, height: height)
        let container = WindowBackgroundView(frame: NSRect(x: 0, y: 0, width: width, height: height))
        panel.contentView = container

        let titleLabel = makeTextLabel(
            "Task title",
            size: CGFloat(profile.typography.label),
            weight: .medium,
            color: .labelColor
        )
        titleLabel.frame = NSRect(x: inset, y: height - inset - 20, width: width - (inset * 2), height: 18)

        let titleFieldContainer = NSView(frame: NSRect(x: inset, y: titleLabel.frame.minY - fieldGap - 40, width: width - (inset * 2), height: 40))
        titleFieldContainer.wantsLayer = true
        titleFieldContainer.layer?.backgroundColor = NSColor.white.cgColor
        titleFieldContainer.layer?.cornerRadius = 9
        titleFieldContainer.layer?.borderWidth = 1
        titleFieldContainer.layer?.borderColor = NSColor.separatorColor.cgColor

        let titleField = NSTextField(frame: NSRect(x: 10, y: 6, width: titleFieldContainer.frame.width - 20, height: 28))
        titleField.font = NSFont.systemFont(ofSize: CGFloat(profile.typography.input), weight: .regular)
        titleField.placeholderString = "e.g. Review today's note"
        titleField.isBordered = false
        titleField.isBezeled = false
        titleField.drawsBackground = false
        titleField.focusRingType = .none
        titleFieldContainer.addSubview(titleField)

        let dueDateToggle = NSButton(checkboxWithTitle: "Add due date", target: nil, action: nil)
        dueDateToggle.font = NSFont.systemFont(ofSize: CGFloat(profile.typography.label), weight: .regular)
        dueDateToggle.frame = NSRect(x: inset, y: titleFieldContainer.frame.minY - CGFloat(profile.spacing.sectionGap) - 24, width: columnWidth, height: 22)

        let recurrenceToggle = NSButton(checkboxWithTitle: "Add recurrence", target: nil, action: nil)
        recurrenceToggle.font = NSFont.systemFont(ofSize: CGFloat(profile.typography.label), weight: .regular)
        recurrenceToggle.frame = NSRect(x: rightColumnX, y: dueDateToggle.frame.minY, width: columnWidth, height: 22)

        let calendarHeight: CGFloat = 170
        let dueDatePicker = NSDatePicker(frame: NSRect(
            x: inset,
            y: dueDateToggle.frame.minY - fieldGap - calendarHeight,
            width: columnWidth,
            height: calendarHeight
        ))
        dueDatePicker.datePickerStyle = .clockAndCalendar
        dueDatePicker.datePickerMode = .single
        dueDatePicker.datePickerElements = [.yearMonthDay]
        dueDatePicker.dateValue = Date()
        dueDatePicker.isEnabled = false

        let recurrencePicker = NSPopUpButton(frame: NSRect(
            x: rightColumnX,
            y: recurrenceToggle.frame.minY - fieldGap - 30,
            width: columnWidth,
            height: 30
        ), pullsDown: false)
        recurrencePicker.addItems(withTitles: [
            "Every day",
            "Every weekday",
            "Every week",
            "Every month",
            "Every year",
            "Every 3 days",
            "Every 2 months"
        ])
        recurrencePicker.selectItem(at: 0)
        recurrencePicker.isEnabled = false

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
        recurrenceToggle.target = self
        recurrenceToggle.action = #selector(onToggleRecurrence(_:))
        recurrenceToggle.identifier = NSUserInterfaceItemIdentifier("taskRecurrenceToggle")
        recurrencePicker.identifier = NSUserInterfaceItemIdentifier("taskRecurrencePicker")

        container.addSubview(titleLabel)
        container.addSubview(titleFieldContainer)
        container.addSubview(dueDateToggle)
        container.addSubview(recurrenceToggle)
        container.addSubview(dueDatePicker)
        container.addSubview(recurrencePicker)
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
            let recurrenceEnabled = recurrenceToggle.state == .on
            let recurrenceRule = recurrenceEnabled
                ? self.recurrenceRuleForTaskUISelection(recurrencePicker.selectedItem?.title ?? "Every day")
                : nil

            if self.captureController.submitTask(title: titleField.stringValue, dueDate: dueDate, recurrenceRule: recurrenceRule) {
                statusLabel.stringValue = "Added successfully. Closing..."
                statusLabel.textColor = NSColor.systemGreen
                addButton.isEnabled = false
                cancelButton.isEnabled = false
                titleField.isEnabled = false
                dueDateToggle.isEnabled = false
                dueDatePicker.isEnabled = false
                recurrenceToggle.isEnabled = false
                recurrencePicker.isEnabled = false
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

    @objc private func onNewNote() {
        let state = currentAvailabilityState()
        guard state.newNoteEnabled else {
            showError("Action unavailable", detail: state.blockedReason ?? state.statusMessage)
            return
        }

        let profile = captureController.visualProfile()
        let width: CGFloat = 640
        let height: CGFloat = 430
        let inset = CGFloat(profile.spacing.windowPadding)
        let fieldGap = CGFloat(profile.spacing.fieldGap)
        let panel = makeModalPanel(title: "New note", width: width, height: height)
        let container = WindowBackgroundView(frame: NSRect(x: 0, y: 0, width: width, height: height))
        panel.contentView = container

        let titleLabel = makeTextLabel(
            "Note title",
            size: CGFloat(profile.typography.label),
            weight: .medium,
            color: .labelColor
        )
        titleLabel.frame = NSRect(x: inset, y: height - inset - 20, width: width - (inset * 2), height: 18)

        let titleFieldContainer = NSView(frame: NSRect(x: inset, y: titleLabel.frame.minY - fieldGap - 40, width: width - (inset * 2), height: 40))
        titleFieldContainer.wantsLayer = true
        titleFieldContainer.layer?.backgroundColor = NSColor.white.cgColor
        titleFieldContainer.layer?.cornerRadius = 9
        titleFieldContainer.layer?.borderWidth = 1
        titleFieldContainer.layer?.borderColor = NSColor.separatorColor.cgColor

        let titleField = NSTextField(frame: NSRect(x: 10, y: 6, width: titleFieldContainer.frame.width - 20, height: 28))
        titleField.font = NSFont.systemFont(ofSize: CGFloat(profile.typography.input), weight: .regular)
        titleField.placeholderString = "yyyy-MM-dd - My note title"
        titleField.stringValue = captureController.suggestedNewNoteTitlePrefix()
        titleField.isBordered = false
        titleField.isBezeled = false
        titleField.drawsBackground = false
        titleField.focusRingType = .none
        titleFieldContainer.addSubview(titleField)

        let contentLabel = makeTextLabel(
            "Content",
            size: CGFloat(profile.typography.label),
            weight: .medium,
            color: .labelColor
        )
        contentLabel.frame = NSRect(x: inset, y: titleFieldContainer.frame.minY - CGFloat(profile.spacing.sectionGap) - 20, width: width - (inset * 2), height: 18)

        let buttonHeight: CGFloat = 30
        let statusHeight: CGFloat = 18
        let buttonsY = inset
        let statusY = buttonsY + buttonHeight + 10
        let editorY = statusY + statusHeight + 10
        let editorHeight = contentLabel.frame.minY - fieldGap - editorY
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
        textView.isRichText = false
        textView.importsGraphics = false
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticTextReplacementEnabled = false
        textView.isAutomaticSpellingCorrectionEnabled = false
        textView.smartInsertDeleteEnabled = false
        textView.textContainerInset = NSSize(width: 10, height: 10)
        textView.textContainer?.lineFragmentPadding = 6
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
        container.addSubview(titleFieldContainer)
        container.addSubview(contentLabel)
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
            if self.captureController.submitStandaloneNote(title: titleField.stringValue, content: textView.string) {
                statusLabel.stringValue = "Added successfully. Closing..."
                statusLabel.textColor = NSColor.systemGreen
                addButton.isEnabled = false
                cancelButton.isEnabled = false
                titleField.isEnabled = false
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

    @objc private func onToggleRecurrence(_ sender: NSButton) {
        guard
            let container = sender.superview,
            let picker = container.subviews.first(where: { $0.identifier?.rawValue == "taskRecurrencePicker" }) as? NSPopUpButton
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

    @objc private func onGithub() {
        guard let url = URL(string: "https://github.com/blamouche/obsidian-quick-note-task") else {
            showError("Open GitHub failed", detail: "Invalid repository URL.")
            return
        }

        if !NSWorkspace.shared.open(url) {
            showError("Open GitHub failed", detail: "Could not open GitHub repository.")
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
