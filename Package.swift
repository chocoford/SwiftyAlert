// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftyAlert",
    platforms: [
        .macOS(.v12),
        .iOS(.v15),
        .macCatalyst(.v15),
        .tvOS(.v15),
        .watchOS(.v8),
        .visionOS(.v1)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SwiftyAlert",
            targets: ["SwiftyAlert"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/elai950/AlertToast.git", branch: "master")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "SwiftyAlert",
            dependencies: ["AlertToast"],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "SwiftyAlertTests",
            dependencies: ["SwiftyAlert"]
        ),
    ]
)
