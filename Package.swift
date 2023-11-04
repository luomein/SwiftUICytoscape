// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftUICytoscape",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
        .macCatalyst(.v13),
        .tvOS(.v13),
        .watchOS(.v6),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SwiftUICytoscape",
            targets: ["SwiftUICytoscape"]),
    ],
    //dependencies: [.package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "0.59.0"),
    dependencies: [.package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.2.0"),
],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "SwiftUICytoscape",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),],
            resources: [.process("Resources")
            ]
        ),
        .testTarget(
            name: "SwiftUICytoscapeTests",
            dependencies: ["SwiftUICytoscape"]),
    ]
)
