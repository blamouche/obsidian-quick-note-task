import Foundation

public final class CaptureWindowController {
    private let destinationStore: DestinationStore
    private let writer: DailyNoteWriter
    private let dateProvider: DateProviding
    private let logger: Logging

    public private(set) var lastErrorMessage: String?
    public private(set) var lastOutputFile: URL?
    public private(set) var preservedDraft: String?

    public init(destinationStore: DestinationStore = .init(),
                writer: DailyNoteWriter = .init(),
                dateProvider: DateProviding = SystemDateProvider(),
                logger: Logging = Logger()) {
        self.destinationStore = destinationStore
        self.writer = writer
        self.dateProvider = dateProvider
        self.logger = logger
    }

    @discardableResult
    public func submitQuickNote(_ text: String) -> Bool {
        guard let destination = destinationStore.loadDestinationURL() else {
            lastErrorMessage = "Destination folder is not configured."
            preservedDraft = text
            logger.error("Quick note blocked: destination not configured, draft=\(logger.redact(text))")
            return false
        }

        do {
            let file = try writer.appendQuickNote(text: text,
                                                  destinationDirectory: destination,
                                                  date: dateProvider.now())
            lastOutputFile = file
            lastErrorMessage = nil
            preservedDraft = nil
            logger.info("Quick note appended to \(file.path)")
            return true
        } catch {
            lastErrorMessage = error.localizedDescription
            preservedDraft = text
            logger.error("Quick note append failed: \(error.localizedDescription), draft=\(logger.redact(text))")
            return false
        }
    }

    @discardableResult
    public func submitTask(title: String, dueDate: Date?) -> Bool {
        guard let destination = destinationStore.loadDestinationURL() else {
            lastErrorMessage = "Destination folder is not configured."
            preservedDraft = title
            logger.error("Task blocked: destination not configured, draft=\(logger.redact(title))")
            return false
        }

        do {
            let file = try writer.appendTask(title: title,
                                             dueDate: dueDate,
                                             destinationDirectory: destination,
                                             date: dateProvider.now())
            lastOutputFile = file
            lastErrorMessage = nil
            preservedDraft = nil
            logger.info("Task appended to \(file.path)")
            return true
        } catch {
            lastErrorMessage = error.localizedDescription
            preservedDraft = title
            logger.error("Task append failed: \(error.localizedDescription), draft=\(logger.redact(title))")
            return false
        }
    }

    @discardableResult
    public func submitTask(title: String, dueDateInput: String?) -> Bool {
        do {
            let parsed = try Validation.parseOptionalDueDate(dueDateInput)
            return submitTask(title: title, dueDate: parsed)
        } catch {
            lastErrorMessage = error.localizedDescription
            preservedDraft = title
            logger.error("Task validation failed: \(error.localizedDescription), draft=\(logger.redact(title))")
            return false
        }
    }

    @discardableResult
    public func rejectUnavailableAction(draft: String?, reason: String) -> Bool {
        lastErrorMessage = reason
        preservedDraft = draft
        logger.error("Capture action blocked: \(reason), draft=\(logger.redact(draft ?? ""))")
        return false
    }
}
