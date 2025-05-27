// swift-tools-version: 6.1
// Was raised from 5.10 to 6.1 to solve GitHub CI build error after depending on swift-collections-benchmark

import PackageDescription

var dependencies: [Package.Dependency] = [
    .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.3.0"),
    .package(url: "https://github.com/tayloraswift/swift-png.git", from: "4.4.4"),
    .package(url: "https://github.com/tayloraswift/jpeg.git", from: "1.1.0"),
    .package(url: "https://github.com/pointfreeco/swift-snapshot-testing.git", from: "1.17.4"),
    .package(url: "https://github.com/apple/swift-algorithms.git", from: "1.2.0"),
    .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.5.0"),
    .package(url: "https://github.com/apple/swift-collections-benchmark", from: "0.0.4"),
    .package(url: "https://github.com/SimplyDanny/SwiftLintPlugins", from: "0.59.1")
]

#if os(macOS)
    // https://forums.swift.org/t/swiftlint-on-linux/64256

    // Build plugins are broken in Xcode 16.3 https://github.com/lukepistrol/SwiftLintPlugin/issues/25
    // So no linting at the moment.

    let plugins: [Target.PluginUsage]? = nil // [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")]
#else
    let plugins: [Target.PluginUsage]? = nil
#endif

let package = Package(

    name: "swift-geometrize",

    platforms: [
        .macOS("15.0") /* raised from 13.3 to 15.0 after depending on swift-collections-benchmark */, .iOS(.v14)
    ],

    products: [
        .library(
            name: "Geometrize",
            targets: ["Geometrize"]
        ),
        .library(
            name: "BitmapImportExport",
            targets: ["BitmapImportExport"]
        ),
        .executable(
            name: "geometrize",
            targets: ["geometrize-cli"]
        ),
        .executable(
            name: "benchmark",
            targets: ["benchmark"]
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
            resources: [.copy("PrivacyInfo.xcprivacy")],
            plugins: plugins
        ),
        .target(
            name: "BitmapImportExport",
            dependencies: [
                "Geometrize",
                .product(name: "PNG", package: "swift-png"),
                .product(name: "JPEG", package: "jpeg", moduleAliases: ["JPEG": "SwiftJPEG"])
            ],
            path: "Sources/bitmapImportExport",
            resources: [.copy("PrivacyInfo.xcprivacy")],
            plugins: plugins
        ),
        .executableTarget(
            name: "geometrize-cli",
            dependencies: [
                "Geometrize",
                "BitmapImportExport",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "PNG", package: "swift-png"),
                .product(name: "JPEG", package: "jpeg", moduleAliases: ["JPEG": "SwiftJPEG"])
                // alias solves build error
                // error: multiple products named 'unit-test' in: 'jpeg' (at '****/jpeg'), 'swift-png' (from 'https://github.com/tayloraswift/swift-png.git')
                // https://github.com/tayloraswift/jpeg/issues/4
                // https://forums.swift.org/t/product-names-from-different-packages-collide-if-packages-are-used-as-dependencies-in-same-package/60178
                // Uses Swift 5.7 feature https://github.com/apple/swift-evolution/blob/main/proposals/0339-module-aliasing-for-disambiguation.md
            ],
            path: "Sources/geometrize-cli",
            resources: [.copy("PrivacyInfo.xcprivacy")],
            plugins: plugins
        ),
        .testTarget(
            name: "geometrizeTests",
            dependencies: [
                "Geometrize",
                "BitmapImportExport",
                .product(name: "PNG", package: "swift-png"),
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing")
            ],
            path: "Tests/geometrizeTests",
            resources: [
                .copy("Resources"),
                .copy("__Snapshots__")
            ],
            plugins: plugins
        ),
        .executableTarget(
            name: "benchmark",
            dependencies: [
                "Geometrize",
                .product(name: "CollectionsBenchmark", package: "swift-collections-benchmark")
            ]
        )
    ]

)
