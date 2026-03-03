import Foundation
#if canImport(AppKit)
import AppKit
#endif

public struct SettingsVisualProfile: Equatable {
    public let typography: TypographyScale
    public let spacing: SpacingScale
    public let folderAffordance: FolderAffordanceStyle

    public init(typography: TypographyScale,
                spacing: SpacingScale,
                folderAffordance: FolderAffordanceStyle) {
        self.typography = typography
        self.spacing = spacing
        self.folderAffordance = folderAffordance
    }
}

public enum DestinationReadiness: Equatable {
    case notConfigured
    case configuredValid(URL)
    case configuredInvalid(URL)
}

public enum SettingsOverallStatus: Equatable {
    case valid
    case invalidVault
    case invalidFolder
    case invalidBoth
}

public struct SettingsConfigurationState: Equatable {
    public let vaultURL: URL?
    public let defaultFolderURL: URL?
    public let status: SettingsOverallStatus
    public let blockingReason: CaptureBlockingReason
    public let message: String
    public let canCapture: Bool

    public init(vaultURL: URL?,
                defaultFolderURL: URL?,
                status: SettingsOverallStatus,
                blockingReason: CaptureBlockingReason,
                message: String,
                canCapture: Bool) {
        self.vaultURL = vaultURL
        self.defaultFolderURL = defaultFolderURL
        self.status = status
        self.blockingReason = blockingReason
        self.message = message
        self.canCapture = canCapture
    }
}

public final class SettingsController: NSObject {
    private let destinationStore: DestinationStore

    #if canImport(AppKit)
    private weak var settingsWindow: NSWindow?
    private weak var vaultPathLabel: NSTextField?
    private weak var defaultFolderPathLabel: NSTextField?
    private weak var statusLabel: NSTextField?
    private var refreshHandler: (() -> Void)?
    #endif

    public init(destinationStore: DestinationStore = .init()) {
        self.destinationStore = destinationStore
        super.init()
    }

    public func selectDestination(_ url: URL) throws {
        try selectDefaultFolder(url)
    }

    public func currentDestination() -> URL? {
        currentDefaultFolder()
    }

    public func selectVault(_ url: URL) throws {
        try destinationStore.saveVaultURL(url)
    }

    public func selectDefaultFolder(_ url: URL) throws {
        try destinationStore.saveDefaultFolderURL(url)
    }

    public func currentVault() -> URL? {
        destinationStore.loadVaultURL()
    }

    public func currentDefaultFolder() -> URL? {
        destinationStore.loadDefaultFolderURL()
    }

    public func configurationState() -> SettingsConfigurationState {
        let vault = currentVault()
        let folder = currentDefaultFolder()
        let validation = Validation.validateVaultAndDefaultFolder(vaultURL: vault, defaultFolderURL: folder)

        switch validation.blockingReason {
        case .none:
            return SettingsConfigurationState(
                vaultURL: vault,
                defaultFolderURL: folder,
                status: .valid,
                blockingReason: .none,
                message: "Ready: vault and default folder are configured.",
                canCapture: true
            )
        case .vaultMissing, .vaultInaccessible:
            let message = validation.blockingReason == .vaultMissing
                ? "Vault not configured. Choose your Obsidian vault in Settings."
                : "Vault inaccessible. Re-select your Obsidian vault in Settings."
            let status: SettingsOverallStatus = (folder == nil) ? .invalidBoth : .invalidVault
            return SettingsConfigurationState(
                vaultURL: vault,
                defaultFolderURL: folder,
                status: status,
                blockingReason: validation.blockingReason,
                message: message,
                canCapture: false
            )
        case .folderMissing, .folderInaccessible, .folderOutsideVault:
            let message: String
            switch validation.blockingReason {
            case .folderMissing:
                message = "Default folder not configured. Choose it in Settings."
            case .folderInaccessible:
                message = "Default folder inaccessible. Re-select it in Settings."
            case .folderOutsideVault:
                message = "Default folder must be inside the selected vault."
            default:
                message = "Default folder configuration is invalid."
            }
            return SettingsConfigurationState(
                vaultURL: vault,
                defaultFolderURL: folder,
                status: .invalidFolder,
                blockingReason: validation.blockingReason,
                message: message,
                canCapture: false
            )
        }
    }

    public func destinationReadiness() -> DestinationReadiness {
        let state = configurationState()
        guard let destination = state.defaultFolderURL else {
            if let vault = state.vaultURL {
                return .configuredInvalid(vault)
            }
            return .notConfigured
        }
        return state.canCapture ? .configuredValid(destination) : .configuredInvalid(destination)
    }

    public func visualProfile() -> SettingsVisualProfile {
        SettingsVisualProfile(
            typography: UIStyle.typography,
            spacing: UIStyle.spacing,
            folderAffordance: UIStyle.folderAffordance
        )
    }

    #if canImport(AppKit)
    @MainActor
    public func presentSettingsWindow(onConfigurationUpdated: (() -> Void)? = nil) {
        refreshHandler = onConfigurationUpdated

        if let existingWindow = settingsWindow {
            updateWindowStateLabels()
            existingWindow.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let profile = visualProfile()
        let width: CGFloat = 640
        let height: CGFloat = 320
        let inset = CGFloat(profile.spacing.windowPadding)

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: width, height: height),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "Settings"
        window.center()
        window.isReleasedWhenClosed = false

        let content = NSView(frame: window.contentRect(forFrameRect: window.frame))

        let titleLabel = makeLabel(
            "Configuration",
            size: CGFloat(profile.typography.title),
            weight: .semibold,
            color: .labelColor
        )
        titleLabel.frame = NSRect(x: inset, y: height - inset - 30, width: width - inset * 2, height: 24)

        let vaultTitle = makeLabel("Obsidian Vault", size: CGFloat(profile.typography.label), weight: .medium, color: .labelColor)
        vaultTitle.frame = NSRect(x: inset, y: titleLabel.frame.minY - CGFloat(profile.spacing.sectionGap) - 22, width: 180, height: 20)

        let vaultPath = makeLabel("Not configured", size: CGFloat(profile.typography.label), weight: .regular, color: .secondaryLabelColor)
        vaultPath.frame = NSRect(x: inset, y: vaultTitle.frame.minY - CGFloat(profile.spacing.fieldGap) - 18, width: width - inset * 2 - 130, height: 18)
        vaultPath.lineBreakMode = .byTruncatingMiddle

        let chooseVaultButton = NSButton(title: "Choose Vault...", target: self, action: #selector(onChooseVault))
        chooseVaultButton.bezelStyle = .rounded
        chooseVaultButton.frame = NSRect(x: width - inset - 120, y: vaultPath.frame.minY - 6, width: 120, height: 30)

        let folderTitle = makeLabel("Default Note Folder", size: CGFloat(profile.typography.label), weight: .medium, color: .labelColor)
        folderTitle.frame = NSRect(x: inset, y: vaultPath.frame.minY - CGFloat(profile.spacing.sectionGap) - 22, width: 220, height: 20)

        let folderPath = makeLabel("Not configured", size: CGFloat(profile.typography.label), weight: .regular, color: .secondaryLabelColor)
        folderPath.frame = NSRect(x: inset, y: folderTitle.frame.minY - CGFloat(profile.spacing.fieldGap) - 18, width: width - inset * 2 - 130, height: 18)
        folderPath.lineBreakMode = .byTruncatingMiddle

        let chooseFolderButton = NSButton(title: "Choose Folder...", target: self, action: #selector(onChooseDefaultFolder))
        chooseFolderButton.bezelStyle = .rounded
        chooseFolderButton.frame = NSRect(x: width - inset - 120, y: folderPath.frame.minY - 6, width: 120, height: 30)

        let statusLabel = makeLabel("", size: CGFloat(profile.typography.label), weight: .regular, color: .secondaryLabelColor)
        statusLabel.frame = NSRect(x: inset, y: inset, width: width - inset * 2, height: 20)

        content.addSubview(titleLabel)
        content.addSubview(vaultTitle)
        content.addSubview(vaultPath)
        content.addSubview(chooseVaultButton)
        content.addSubview(folderTitle)
        content.addSubview(folderPath)
        content.addSubview(chooseFolderButton)
        content.addSubview(statusLabel)

        window.contentView = content
        window.delegate = self

        self.settingsWindow = window
        self.vaultPathLabel = vaultPath
        self.defaultFolderPathLabel = folderPath
        self.statusLabel = statusLabel

        updateWindowStateLabels()
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc private func onChooseVault() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.canCreateDirectories = false
        panel.allowsMultipleSelection = false
        panel.prompt = "Choose Vault"
        panel.message = "Select your local Obsidian vault folder."

        if panel.runModal() == .OK, let url = panel.url {
            do {
                try selectVault(url)
                updateWindowStateLabels()
                refreshHandler?()
            } catch {
                statusLabel?.stringValue = error.localizedDescription
                statusLabel?.textColor = .systemRed
            }
        }
    }

    @objc private func onChooseDefaultFolder() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.canCreateDirectories = true
        panel.allowsMultipleSelection = false
        panel.prompt = visualProfile().folderAffordance.actionLabel
        panel.message = "Select the default folder where new notes and tasks will be created."

        if panel.runModal() == .OK, let url = panel.url {
            do {
                try selectDefaultFolder(url)
                updateWindowStateLabels()
                refreshHandler?()
            } catch {
                statusLabel?.stringValue = error.localizedDescription
                statusLabel?.textColor = .systemRed
            }
        }
    }

    private func updateWindowStateLabels() {
        let state = configurationState()
        vaultPathLabel?.stringValue = state.vaultURL?.path ?? "Not configured"
        defaultFolderPathLabel?.stringValue = state.defaultFolderURL?.path ?? "Not configured"
        statusLabel?.stringValue = state.message
        statusLabel?.textColor = state.canCapture ? .systemGreen : .systemOrange
    }

    private func makeLabel(_ text: String,
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
    #endif
}

#if canImport(AppKit)
extension SettingsController: NSWindowDelegate {
    public func windowWillClose(_ notification: Notification) {
        settingsWindow = nil
        vaultPathLabel = nil
        defaultFolderPathLabel = nil
        statusLabel = nil
    }
}
#endif
