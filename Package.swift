// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "ObsidianQuickNoteTask",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(name: "ObsidianQuickNoteTask", targets: ["ObsidianQuickNoteTask"]),
        .executable(name: "ObsidianQuickNoteTaskApp", targets: ["ObsidianQuickNoteTaskApp"])
    ],
    targets: [
        .target(
            name: "ObsidianQuickNoteTask",
            path: "src"
        ),
        .executableTarget(
            name: "ObsidianQuickNoteTaskApp",
            dependencies: ["ObsidianQuickNoteTask"],
            path: "app"
        ),
        .testTarget(
            name: "ObsidianQuickNoteTaskTests",
            dependencies: ["ObsidianQuickNoteTask"],
            path: "tests"
        )
    ]
)
