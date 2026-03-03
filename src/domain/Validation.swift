import Foundation

public enum ValidationError: Error, Equatable, LocalizedError {
    case emptyQuickNote
    case emptyTaskTitle
    case invalidDueDateFormat
    case vaultMissing
    case vaultInaccessible
    case defaultFolderMissing
    case defaultFolderInaccessible
    case defaultFolderOutsideVault
    case taskSourceOutsideVault

    public var errorDescription: String? {
        switch self {
        case .emptyQuickNote:
            return "Quick note text cannot be empty or whitespace."
        case .emptyTaskTitle:
            return "Task title cannot be empty or whitespace."
        case .invalidDueDateFormat:
            return "Due date must use YYYY-MM-DD format."
        case .vaultMissing:
            return "Vault is not configured."
        case .vaultInaccessible:
            return "Vault is inaccessible."
        case .defaultFolderMissing:
            return "Default folder is not configured."
        case .defaultFolderInaccessible:
            return "Default folder is inaccessible."
        case .defaultFolderOutsideVault:
            return "Default folder must be inside the selected vault."
        case .taskSourceOutsideVault:
            return "Task source must stay inside the selected vault."
        }
    }
}

public enum CaptureBlockingReason: Equatable {
    case none
    case vaultMissing
    case vaultInaccessible
    case folderMissing
    case folderInaccessible
    case folderOutsideVault
}

public struct ConfigurationValidationState: Equatable {
    public let vaultValid: Bool
    public let defaultFolderValid: Bool
    public let blockingReason: CaptureBlockingReason

    public init(vaultValid: Bool, defaultFolderValid: Bool, blockingReason: CaptureBlockingReason) {
        self.vaultValid = vaultValid
        self.defaultFolderValid = defaultFolderValid
        self.blockingReason = blockingReason
    }
}

public enum Validation {
    public static func validateQuickNote(_ text: String) throws -> String {
        let normalized = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalized.isEmpty else { throw ValidationError.emptyQuickNote }
        return normalized
    }

    public static func validateTaskTitle(_ title: String) throws -> String {
        let normalized = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalized.isEmpty else { throw ValidationError.emptyTaskTitle }
        return normalized
    }

    public static func parseOptionalDueDate(_ input: String?) throws -> Date? {
        guard let input, !input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return nil
        }
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"

        guard let date = formatter.date(from: input) else {
            throw ValidationError.invalidDueDateFormat
        }
        return date
    }

    public static func normalizeOptionalDueDate(selected: Date?, enabled: Bool) -> Date? {
        enabled ? selected : nil
    }

    public static func validateVaultAndDefaultFolder(vaultURL: URL?, defaultFolderURL: URL?) -> ConfigurationValidationState {
        guard let vaultURL else {
            return ConfigurationValidationState(vaultValid: false, defaultFolderValid: false, blockingReason: .vaultMissing)
        }

        guard isAccessibleDirectory(vaultURL) else {
            return ConfigurationValidationState(vaultValid: false, defaultFolderValid: false, blockingReason: .vaultInaccessible)
        }

        guard let defaultFolderURL else {
            return ConfigurationValidationState(vaultValid: true, defaultFolderValid: false, blockingReason: .folderMissing)
        }

        guard isAccessibleDirectory(defaultFolderURL) else {
            return ConfigurationValidationState(vaultValid: true, defaultFolderValid: false, blockingReason: .folderInaccessible)
        }

        guard isContained(defaultFolderURL, in: vaultURL) else {
            return ConfigurationValidationState(vaultValid: true, defaultFolderValid: false, blockingReason: .folderOutsideVault)
        }

        return ConfigurationValidationState(vaultValid: true, defaultFolderValid: true, blockingReason: .none)
    }

    public static func isAccessibleDirectory(_ url: URL) -> Bool {
        var isDirectory: ObjCBool = false
        let exists = FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory)
        return exists && isDirectory.boolValue
    }

    public static func isContained(_ candidate: URL, in root: URL) -> Bool {
        let candidatePath = candidate.standardizedFileURL.path
        let rootPath = root.standardizedFileURL.path
        return candidatePath == rootPath || candidatePath.hasPrefix(rootPath + "/")
    }

    public static func sanitizeExclusionText(_ value: String?) -> String {
        guard let value else { return "" }
        let cleanedScalars = value.unicodeScalars.filter { scalar in
            let isControl = CharacterSet.controlCharacters.contains(scalar)
            return !isControl || scalar == " " || scalar == "\t"
        }
        let cleaned = String(String.UnicodeScalarView(cleanedScalars))
        return cleaned.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }

    public static func validateTaskSource(fileURL: URL, vaultURL: URL) throws {
        guard isContained(fileURL, in: vaultURL) else {
            throw ValidationError.taskSourceOutsideVault
        }
    }

    public static func normalizeForSearch(_ value: String) -> String {
        value
            .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
            .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
}
