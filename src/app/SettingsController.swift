import Foundation

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
}
