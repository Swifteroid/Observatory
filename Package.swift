// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Observatory",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .library(name: "Observatory", targets: ["Observatory"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Quick/Nimble.git", from: "13.0.0"),
        .package(url: "https://github.com/Quick/Quick.git", from: "7.0.0"),
    ],
    targets: [
        .target(
            name: "Observatory",
            path: "source/Observatory",
            exclude: ["Test", "Testing"],
        ),
        .testTarget(
            name: "Observatory-Test",
            dependencies: ["Observatory", "Quick", "Nimble"],
            path: "source/Observatory",
            exclude: ["Keyboard", "Observer", "Shortcut"],
        ),
    ],
    swiftLanguageVersions: [.v5]
)
