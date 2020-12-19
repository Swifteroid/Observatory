// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "Observatory",
    platforms: [
        .macOS(.v10_10)
    ],
    products: [
        .library(name: "Observatory", targets: ["Observatory"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Quick/Nimble.git", from: "9.0.0"),
        .package(url: "https://github.com/Quick/Quick.git", from: "3.0.0"),
    ],
    targets: [
        .target(name: "Observatory", path: "source/Observatory", exclude: ["Test", "Testing"]),
        .testTarget(name: "Observatory-Test", dependencies: ["Observatory", "Quick", "Nimble"], path: "source/Observatory", sources: ["Test", "Testing"]),
    ],
    swiftLanguageVersions: [.v5]
)
