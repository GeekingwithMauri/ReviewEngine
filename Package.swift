// swift-tools-version:6.0

import PackageDescription

let package = Package(
    name: "ReviewEngine",
    platforms: [
        .iOS(.v18),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "ReviewEngine",
            targets: ["ReviewEngine"]
        ),
    ],
    targets: [
        .target(name: "ReviewEngine"),
        .testTarget(
            name: "ReviewEngineTests",
            dependencies: ["ReviewEngine"]
        ),
    ]
)
