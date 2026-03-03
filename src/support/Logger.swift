import Foundation

public protocol Logging {
    func info(_ message: String)
    func error(_ message: String)
    func redact(_ raw: String) -> String
}

public final class Logger: Logging {
    public init() {}

    public func info(_ message: String) {
        print("[INFO] \(message)")
    }

    public func error(_ message: String) {
        fputs("[ERROR] \(message)\n", stderr)
    }

    public func redact(_ raw: String) -> String {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "<empty>" }
        let normalized = trimmed.replacingOccurrences(of: "\n", with: " ")
        if normalized.hasPrefix("- [") {
            return "<redacted task len=\(normalized.count)>"
        }
        if normalized.contains("📅") || normalized.contains("🔁") {
            return "<redacted dated-content len=\(normalized.count)>"
        }
        return "<redacted len=\(normalized.count)>"
    }
}
