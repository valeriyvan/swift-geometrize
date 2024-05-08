// swift-tools-version: 5.9

import PackageDescription

var dependencies: [Package.Dependency] = [
    .package(url: "https://github.com/tayloraswift/swift-png.git", from: "4.4.1"),
    .package(url: "https://github.com/tayloraswift/jpeg.git", from: "1.1.0"),
    .package(url: "https://github.com/pointfreeco/swift-snapshot-testing.git", from: "1.13.0"),
    .package(url: "https://github.com/apple/swift-algorithms.git", from: "1.0.0"),
    .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.1.4"),
    .package(url: "https://github.com/realm/SwiftLint.git", branch: "main")
]

#if os(macOS)
    // https://forums.swift.org/t/swiftlint-on-linux/64256
    let plugins: [Target.PluginUsage]? = [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLint")]
#else
    let plugins: [Target.PluginUsage]? = nil
#endif

let package = Package(

    name: "swift-geometrize",

    platforms: [
        .macOS(.v12), .iOS(.v14)
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
        )
    ]

)
