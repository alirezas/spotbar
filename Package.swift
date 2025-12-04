// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "SpotBar",
    platforms: [
        .macOS(.v10_12)
    ],
    targets: [
        .executableTarget(
            name: "SpotBar",
            path: ".",
            exclude: ["Info.plist", "README.md", "AGENTS.md", "SpotBar.app"],
            sources: ["main.swift", "AppDelegate.swift", "MarqueeController.swift"]
        )
    ]
)