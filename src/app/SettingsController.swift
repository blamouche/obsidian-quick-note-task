import Foundation

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
}
