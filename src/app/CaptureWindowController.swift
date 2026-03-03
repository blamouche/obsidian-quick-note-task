import Foundation

public final class CaptureWindowController {
    private let destinationStore: DestinationStore
    private let writer: DailyNoteWriter
    private let dateProvider: DateProviding

    public private(set) var lastErrorMessage: String?
    public private(set) var lastOutputFile: URL?
    public private(set) var preservedDraft: String?

    public init(destinationStore: DestinationStore = .init(),
                writer: DailyNoteWriter = .init(),
                dateProvider: DateProviding = SystemDateProvider()) {
        self.destinationStore = destinationStore
        self.writer = writer
        self.dateProvider = dateProvider
    }

    @discardableResult
    public func submitQuickNote(_ text: String) -> Bool {
        guard let destination = destinationStore.loadDestinationURL() else {
            lastErrorMessage = "Destination folder is not configured."
            preservedDraft = text
            return false
        }

        do {
            let file = try writer.appendQuickNote(text: text,
                                                  destinationDirectory: destination,
                                                  date: dateProvider.now())
            lastOutputFile = file
            lastErrorMessage = nil
            preservedDraft = nil
            return true
        } catch {
            lastErrorMessage = error.localizedDescription
            preservedDraft = text
            return false
        }
    }

    @discardableResult
    public func submitTask(title: String, dueDateInput: String?) -> Bool {
        guard let destination = destinationStore.loadDestinationURL() else {
            lastErrorMessage = "Destination folder is not configured."
            preservedDraft = title
            return false
        }

        do {
            let dueDate = try Validation.parseOptionalDueDate(dueDateInput)
            let file = try writer.appendTask(title: title,
                                             dueDate: dueDate,
                                             destinationDirectory: destination,
                                             date: dateProvider.now())
            lastOutputFile = file
            lastErrorMessage = nil
            preservedDraft = nil
            return true
        } catch {
            lastErrorMessage = error.localizedDescription
            preservedDraft = title
            return false
        }
    }
}
