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
            sources: ["main.swift", "AppDelegate.swift", "PillView.swift"]
        )
    ]
)