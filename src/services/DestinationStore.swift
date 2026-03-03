import Foundation

public enum DestinationStoreError: Error, LocalizedError {
    case invalidDirectory
    case unableToPersist

    public var errorDescription: String? {
        switch self {
        case .invalidDirectory:
            return "Selected destination is not a valid local directory."
        case .unableToPersist:
            return "Unable to persist destination folder."
        }
    }
}

public final class DestinationStore {
    private let defaults: UserDefaults
    private let key: String

    public init(defaults: UserDefaults = .standard, key: String = "obsidian.destination.bookmark") {
        self.defaults = defaults
        self.key = key
    }

    public func saveDestination(url: URL) throws {
        let isDirectory = (try? url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false
        guard url.isFileURL, isDirectory else {
            throw DestinationStoreError.invalidDirectory
        }

        do {
            #if os(macOS)
            let bookmark = try url.bookmarkData(options: .withSecurityScope,
                                                includingResourceValuesForKeys: nil,
                                                relativeTo: nil)
            defaults.set(bookmark, forKey: key)
            #else
            defaults.set(url.path.data(using: .utf8), forKey: key)
            #endif
        } catch {
            throw DestinationStoreError.unableToPersist
        }
    }

    public func loadDestinationURL() -> URL? {
        guard let data = defaults.data(forKey: key) else {
            return nil
        }

        #if os(macOS)
        var stale = false
        return try? URL(resolvingBookmarkData: data,
                        options: [.withSecurityScope],
                        relativeTo: nil,
                        bookmarkDataIsStale: &stale)
        #else
        guard let path = String(data: data, encoding: .utf8) else { return nil }
        return URL(fileURLWithPath: path)
        #endif
    }

    public func clear() {
        defaults.removeObject(forKey: key)
    }
}
