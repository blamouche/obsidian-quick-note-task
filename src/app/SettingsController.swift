import Foundation

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

public final class SettingsController {
    private let destinationStore: DestinationStore

    public init(destinationStore: DestinationStore = .init()) {
        self.destinationStore = destinationStore
    }

    public func selectDestination(_ url: URL) throws {
        try destinationStore.saveDestination(url: url)
    }

    public func currentDestination() -> URL? {
        destinationStore.loadDestinationURL()
    }

    public func destinationReadiness() -> DestinationReadiness {
        guard let destination = destinationStore.loadDestinationURL() else {
            return .notConfigured
        }

        var isDirectory: ObjCBool = false
        let exists = FileManager.default.fileExists(atPath: destination.path, isDirectory: &isDirectory)
        if exists, isDirectory.boolValue {
            return .configuredValid(destination)
        }

        return .configuredInvalid(destination)
    }

    public func visualProfile() -> SettingsVisualProfile {
        SettingsVisualProfile(
            typography: UIStyle.typography,
            spacing: UIStyle.spacing,
            folderAffordance: UIStyle.folderAffordance
        )
    }
}
