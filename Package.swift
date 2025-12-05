// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SpotBar",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "SpotBar",
            targets: ["SpotBar"]
        )
    ],
    targets: [
        .executableTarget(
            name: "SpotBar",
            dependencies: []
        )
    ]
)
