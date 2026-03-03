import Foundation

enum TaskFixtures {
    static func makeTemporaryVault(from fixtureFolder: URL) throws -> URL {
        let fileManager = FileManager.default
        let destination = fileManager.temporaryDirectory
            .appendingPathComponent("vault-fixture-\(UUID().uuidString)", isDirectory: true)
        try fileManager.createDirectory(at: destination, withIntermediateDirectories: true)

        let files = try fileManager.contentsOfDirectory(at: fixtureFolder, includingPropertiesForKeys: nil)
        for file in files where file.pathExtension.lowercased() == "md" {
            let target = destination.appendingPathComponent(file.lastPathComponent)
            try fileManager.copyItem(at: file, to: target)
        }
        return destination
    }
}
