// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "Observatory",
    platforms: [
        .macOS(.v10_13)
    ],
    products: [
        .library(name: "Observatory", targets: ["Observatory"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Quick/Nimble.git", from: "11.0.0"),
        .package(url: "https://github.com/Quick/Quick.git", from: "5.0.0"),
    ],
    targets: [
        .target(
            name: "Observatory",
            path: "source/Observatory",
            exclude: ["Test", "Testing"]
        ),
        .testTarget(
            name: "Observatory-Test",
            dependencies: ["Observatory", "Quick", "Nimble"],
            path: "source/Observatory",
            exclude: ["Keyboard", "Observer", "Shortcut"]
            // sources: ["Test", "Testing"] // Since tools 5.3 this alone doesn't work and produces a warning… no need for it really…
        ),
    ],
    swiftLanguageVersions: [.v5]
)
