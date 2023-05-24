// swift-tools-version: 5.7

import PackageDescription

var dependencies: [Package.Dependency] = [
    .package(url: "https://github.com/kelvin13/swift-png.git", from: "4.0.2"),
    .package(url: "https://github.com/valeriyvan/jpeg.git", from: "1.0.2"),
    .package(url: "https://github.com/pointfreeco/swift-snapshot-testing.git", from: "1.9.0"),
    .package(url: "https://github.com/apple/swift-algorithms.git", from: "1.0.0"),
    .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.1.4"),
]

#if !os(Windows)
    dependencies.append(.package(url: "https://github.com/lukepistrol/SwiftLintPlugin.git", from: "0.0.4"))
    let plugins: [Target.PluginUsage]? = [.plugin(name: "SwiftLint", package: "SwiftLintPlugin")]
#else
    let plugins: [Target.PluginUsage]? = nil
#endif

let package = Package(
    
    name: "swift-geometrize",
    
    platforms: [
        .macOS(.v10_15), .iOS(.v14)
    ],
    
    products: [
        .library(
            name: "Geometrize",
            targets: ["Geometrize"]
        ),
        .executable(
            name: "geometrize-cli",
            targets: ["geometrize-cli"]
        )
    ],
    
    dependencies: dependencies,
    
    targets: [
        .target(
            name: "Geometrize",
            dependencies: [
                .product(name: "Algorithms", package: "swift-algorithms")
            ],
            path: "Sources/geometrize",
            plugins: plugins
        ),
        .executableTarget(
            name: "geometrize-cli",
            dependencies: [
                "Geometrize",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "PNG", package: "swift-png"),
                .product(name: "JPEG", package: "jpeg")
            ],
            plugins: plugins
        ),
        .testTarget(
            name: "geometrizeTests",
            dependencies: [
                "Geometrize",
                .product(name: "PNG", package: "swift-png"),
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing")
            ],
            path: "Tests/geometrizeTests",
            resources: [
                .copy("Resources"),
                .copy("__Snapshots__")
            ],
            plugins: plugins
        )
    ]
    
)
