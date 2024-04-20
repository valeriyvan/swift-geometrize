// swift-tools-version: 5.7

import PackageDescription

var dependencies: [Package.Dependency] = [
    .package(url: "https://github.com/tayloraswift/swift-png.git", from: "4.4.1"),
    .package(url: "https://github.com/tayloraswift/jpeg.git", from: "1.1.0"),
    .package(url: "https://github.com/pointfreeco/swift-snapshot-testing.git", from: "1.13.0"),
    .package(url: "https://github.com/apple/swift-algorithms.git", from: "1.0.0"),
    .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.1.4"),
]

#if !os(Linux) && !os(Windows)
    dependencies.append(.package(url: "https://github.com/lukepistrol/SwiftLintPlugin.git", from: "0.54.0"))
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
                .product(name: "JPEG", package: "jpeg", moduleAliases: ["JPEG": "SwiftJPEG"])
                // alias solves build error
                // error: multiple products named 'unit-test' in: 'jpeg' (at '****/jpeg'), 'swift-png' (from 'https://github.com/tayloraswift/swift-png.git')
                // https://github.com/tayloraswift/jpeg/issues/4
                // https://forums.swift.org/t/product-names-from-different-packages-collide-if-packages-are-used-as-dependencies-in-same-package/60178
                // Uses Swift 5.7 feature https://github.com/apple/swift-evolution/blob/main/proposals/0339-module-aliasing-for-disambiguation.md
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
