import Foundation

public enum DailyNoteWriterError: Error, LocalizedError {
    case invalidDestination
    case unableToCreateFile
    case unableToReadFile
    case unableToWriteFile

    public var errorDescription: String? {
        switch self {
        case .invalidDestination:
            return "Destination folder is invalid or inaccessible."
        case .unableToCreateFile:
            return "Unable to create daily note file."
        case .unableToReadFile:
            return "Unable to read daily note file."
        case .unableToWriteFile:
            return "Unable to append content to daily note file."
        }
    }
}

public final class DailyNoteWriter {
    private let resolver: DailyNotePathResolver
    private let formatter: MarkdownFormatter

    public init(resolver: DailyNotePathResolver = .init(), formatter: MarkdownFormatter = .init()) {
        self.resolver = resolver
        self.formatter = formatter
    }

    public func appendQuickNote(text: String, destinationDirectory: URL, date: Date) throws -> URL {
        let normalized = try Validation.validateQuickNote(text)
        let rendered = formatter.formatQuickNote(text: normalized)
        return try appendRendered(rendered, destinationDirectory: destinationDirectory, date: date)
    }

    public func appendTask(title: String, dueDate: Date?, destinationDirectory: URL, date: Date) throws -> URL {
        let normalizedTitle = try Validation.validateTaskTitle(title)
        let rendered = formatter.formatTask(title: normalizedTitle, dueDate: dueDate)
        return try appendRendered(rendered, destinationDirectory: destinationDirectory, date: date)
    }

    private func appendRendered(_ rendered: String, destinationDirectory: URL, date: Date) throws -> URL {
        var isDirectory: ObjCBool = false
        guard FileManager.default.fileExists(atPath: destinationDirectory.path, isDirectory: &isDirectory), isDirectory.boolValue else {
            throw DailyNoteWriterError.invalidDestination
        }

        let targetURL = resolver.fileURL(baseDirectory: destinationDirectory, date: date)

        if !FileManager.default.fileExists(atPath: targetURL.path) {
            guard FileManager.default.createFile(atPath: targetURL.path, contents: Data(), attributes: nil) else {
                throw DailyNoteWriterError.unableToCreateFile
            }
        }

        let existing: String
        do {
            existing = try String(contentsOf: targetURL, encoding: .utf8)
        } catch {
            throw DailyNoteWriterError.unableToReadFile
        }

        let payload = existing.trimmingCharacters(in: .newlines).isEmpty ? rendered : formatter.separator + rendered

        guard let data = payload.data(using: .utf8) else {
            throw DailyNoteWriterError.unableToWriteFile
        }

        do {
            let handle = try FileHandle(forWritingTo: targetURL)
            defer { try? handle.close() }
            try handle.seekToEnd()
            try handle.write(contentsOf: data)
        } catch {
            throw DailyNoteWriterError.unableToWriteFile
        }

        return targetURL
    }
}
