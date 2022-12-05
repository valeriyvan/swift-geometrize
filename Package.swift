// swift-tools-version: 5.7

import PackageDescription

var dependencies: [Package.Dependency] = [
    .package(url: "git@github.com:kelvin13/swift-png.git", from: "4.0.2"),
    .package(url: "git@github.com:valeriyvan/jpeg.git", branch: "allFixesMerged"),
    .package(url: "git@github.com:pointfreeco/swift-snapshot-testing.git", from: "1.9.0"),
    .package(url: "git@github.com:apple/swift-algorithms.git", from: "1.0.0"),
    .package(url: "git@github.com:apple/swift-argument-parser.git", from: "1.1.4"),
]

#if !os(Windows)
    dependencies.append(.package(url: "git@github.com:lukepistrol/SwiftLintPlugin.git", from: "0.0.4"))
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
                .copy("Resources/grapefruit.png"),
                .copy("Resources/hot_air_balloon.png"),
                .copy("Resources/jammy_biscuit.png"),
                .copy("Resources/monarch_butterfly.png"),
                .copy("Resources/pomegranate_splitting.png"),
                .copy("Resources/sliced_fruit.png"),
                .copy("Resources/sundaes.png"),
                .copy("Resources/sunrise_at_sea.png"),
                .copy("Resources/differenceFull bitmap first.txt"),
                .copy("Resources/differenceFull bitmap second.txt"),
                .copy("Resources/differencePartial bitmap target.txt"),
                .copy("Resources/differencePartial bitmap before.txt"),
                .copy("Resources/differencePartial bitmap after.txt"),
                .copy("Resources/differencePartial scanlines.txt"),
                .copy("Resources/defaultEnergyFunction target bitmap.txt"),
                .copy("Resources/defaultEnergyFunction current bitmap.txt"),
                .copy("Resources/defaultEnergyFunction buffer bitmap.txt"),
                .copy("Resources/defaultEnergyFunction buffer bitmap on exit.txt"),
                .copy("Resources/defaultEnergyFunction scanlines.txt"),
                .copy("Resources/hillClimb target bitmap.txt"),
                .copy("Resources/hillClimb current bitmap.txt"),
                .copy("Resources/hillClimb buffer bitmap.txt"),
                .copy("Resources/hillClimb buffer bitmap on exit.txt"),
                .copy("Resources/hillClimb randomRange.txt")
            ],
            plugins: plugins
        )
    ]
    
)
