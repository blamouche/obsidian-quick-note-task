import Foundation

public enum DailyNoteWriterError: Error, LocalizedError {
    case invalidDestination
    case invalidVaultScope
    case staleTaskReference
    case unableToCreateFile
    case unableToReadFile
    case unableToWriteFile

    public var errorDescription: String? {
        switch self {
        case .invalidDestination:
            return "Destination folder is invalid or inaccessible."
        case .invalidVaultScope:
            return "Operation is outside the configured vault scope."
        case .staleTaskReference:
            return "Task reference is stale and no longer matches markdown content."
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

    public func appendTask(title: String,
                           dueDate: Date?,
                           recurrenceRule: String? = nil,
                           destinationDirectory: URL,
                           date: Date) throws -> URL {
        let normalizedTitle = try Validation.validateTaskTitle(title)
        let rendered = formatter.formatTask(title: normalizedTitle, dueDate: dueDate, recurrenceRule: recurrenceRule)
        return try appendRendered(rendered, destinationDirectory: destinationDirectory, date: date)
    }

    public func replaceTaskLine(fileURL: URL,
                                vaultRoot: URL,
                                lineNumber: Int,
                                expectedRawLine: String,
                                replacementLine: String) throws {
        guard Validation.isContained(fileURL, in: vaultRoot) else {
            throw DailyNoteWriterError.invalidVaultScope
        }

        let existing: String
        do {
            existing = try String(contentsOf: fileURL, encoding: .utf8)
        } catch {
            throw DailyNoteWriterError.unableToReadFile
        }

        var lines = existing.components(separatedBy: .newlines)
        let index = lineNumber - 1
        guard index >= 0, index < lines.count else {
            throw DailyNoteWriterError.staleTaskReference
        }

        if lines[index] != expectedRawLine {
            if let fallbackIndex = lines.firstIndex(of: expectedRawLine) {
                lines[fallbackIndex] = replacementLine
            } else {
                throw DailyNoteWriterError.staleTaskReference
            }
        } else {
            lines[index] = replacementLine
        }

        let payload = lines.joined(separator: "\n")
        guard let data = payload.data(using: .utf8) else {
            throw DailyNoteWriterError.unableToWriteFile
        }

        do {
            try data.write(to: fileURL, options: .atomic)
        } catch {
            throw DailyNoteWriterError.unableToWriteFile
        }
    }

    public func appendTaskLine(fileURL: URL,
                               vaultRoot: URL,
                               line: String) throws {
        guard Validation.isContained(fileURL, in: vaultRoot) else {
            throw DailyNoteWriterError.invalidVaultScope
        }

        let existing: String
        do {
            existing = try String(contentsOf: fileURL, encoding: .utf8)
        } catch {
            throw DailyNoteWriterError.unableToReadFile
        }

        let payload: String
        if existing.trimmingCharacters(in: .newlines).isEmpty {
            payload = line
        } else {
            payload = existing + "\n" + line
        }

        guard let data = payload.data(using: .utf8) else {
            throw DailyNoteWriterError.unableToWriteFile
        }

        do {
            try data.write(to: fileURL, options: .atomic)
        } catch {
            throw DailyNoteWriterError.unableToWriteFile
        }
    }

    public func insertTaskLineAfter(fileURL: URL,
                                    vaultRoot: URL,
                                    lineNumber: Int,
                                    expectedRawLine: String,
                                    lineToInsert: String) throws {
        guard Validation.isContained(fileURL, in: vaultRoot) else {
            throw DailyNoteWriterError.invalidVaultScope
        }

        let existing: String
        do {
            existing = try String(contentsOf: fileURL, encoding: .utf8)
        } catch {
            throw DailyNoteWriterError.unableToReadFile
        }

        var lines = existing.components(separatedBy: .newlines)
        let index = lineNumber - 1

        let insertionBaseIndex: Int
        if index >= 0, index < lines.count, lines[index] == expectedRawLine {
            insertionBaseIndex = index
        } else if let fallbackIndex = lines.firstIndex(of: expectedRawLine) {
            insertionBaseIndex = fallbackIndex
        } else {
            throw DailyNoteWriterError.staleTaskReference
        }

        let insertionIndex = min(insertionBaseIndex + 1, lines.count)
        lines.insert(lineToInsert, at: insertionIndex)

        let payload = lines.joined(separator: "\n")
        guard let data = payload.data(using: .utf8) else {
            throw DailyNoteWriterError.unableToWriteFile
        }

        do {
            try data.write(to: fileURL, options: .atomic)
        } catch {
            throw DailyNoteWriterError.unableToWriteFile
        }
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
