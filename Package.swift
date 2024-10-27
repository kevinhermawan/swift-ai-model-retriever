// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AIModelRetriever",
    platforms: [.iOS(.v15), .macOS(.v12)],
    products: [
        .library(
            name: "AIModelRetriever",
            targets: ["AIModelRetriever"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-docc-plugin.git", .upToNextMajor(from: "1.4.3"))
    ],
    targets: [
        .target(
            name: "AIModelRetriever"),
        .testTarget(
            name: "AIModelRetrieverTests",
            dependencies: ["AIModelRetriever"]
        )
    ]
)
