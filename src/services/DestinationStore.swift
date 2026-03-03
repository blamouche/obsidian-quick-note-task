import Foundation

public enum DestinationStoreError: Error, LocalizedError {
    case invalidDirectory
    case invalidFilter
    case unableToPersist

    public var errorDescription: String? {
        switch self {
        case .invalidDirectory:
            return "Selected destination is not a valid local directory."
        case .invalidFilter:
            return "Task exclusion filter is invalid."
        case .unableToPersist:
            return "Unable to persist destination folder."
        }
    }
}

public final class DestinationStore {
    private let defaults: UserDefaults
    private let key: String
    private let vaultKey: String
    private let defaultFolderKey: String
    private let taskExclusionTextKey: String

    public init(defaults: UserDefaults = .standard,
                key: String = "obsidian.destination.bookmark",
                vaultKey: String = "obsidian.vault.bookmark",
                defaultFolderKey: String = "obsidian.default-folder.bookmark",
                taskExclusionTextKey: String = "obsidian.task-exclusion-text") {
        self.defaults = defaults
        self.key = key
        self.vaultKey = vaultKey
        self.defaultFolderKey = defaultFolderKey
        self.taskExclusionTextKey = taskExclusionTextKey
    }

    public func saveDestination(url: URL) throws {
        try saveDefaultFolderURL(url)
    }

    public func saveVaultURL(_ url: URL) throws {
        try saveBookmark(url: url, key: vaultKey)
    }

    public func saveDefaultFolderURL(_ url: URL) throws {
        try saveBookmark(url: url, key: defaultFolderKey)
    }

    public func loadVaultURL() -> URL? {
        loadBookmark(forKey: vaultKey)
    }

    public func loadDefaultFolderURL() -> URL? {
        loadBookmark(forKey: defaultFolderKey) ?? loadBookmark(forKey: key)
    }

    public func loadDestinationURL() -> URL? {
        loadDefaultFolderURL()
    }

    public func saveTaskExclusionText(_ value: String?) throws {
        let sanitized = Validation.sanitizeExclusionText(value)
        if sanitized.count > 256 {
            throw DestinationStoreError.invalidFilter
        }

        if sanitized.isEmpty {
            defaults.removeObject(forKey: taskExclusionTextKey)
            return
        }

        defaults.set(sanitized, forKey: taskExclusionTextKey)
    }

    public func loadTaskExclusionText() -> String? {
        defaults.string(forKey: taskExclusionTextKey)
    }

    public func clear() {
        defaults.removeObject(forKey: key)
        defaults.removeObject(forKey: vaultKey)
        defaults.removeObject(forKey: defaultFolderKey)
        defaults.removeObject(forKey: taskExclusionTextKey)
    }

    private func saveBookmark(url: URL, key: String) throws {
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

    private func loadBookmark(forKey key: String) -> URL? {
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
}
