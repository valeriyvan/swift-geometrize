// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    
    name: "geometrize",
    
    platforms: [
        .macOS(.v10_15), .iOS(.v15)
    ],
    
    products: [
        .library(
            name: "geometrize",
            targets: ["geometrize"]
        ),
        .executable(
            name: "geometrize-cli",
            targets: ["geometrize-cli"]
        )
    ],
    
    dependencies: [
        .package(name: "PNG", url: "git@github.com:kelvin13/swift-png.git", from: "4.0.1"),
        .package(name: "SnapshotTesting", url: "git@github.com:pointfreeco/swift-snapshot-testing.git", from: "1.9.0")
    ],
    
    targets: [
        .target(
            name: "geometrize",
            dependencies: [],
            path: "Sources/geometrize"
        ),
        .executableTarget(
            name: "geometrize-cli",
            dependencies: ["geometrize"]
        ),
        .testTarget(
            name: "geometrizeTests",
            dependencies: ["geometrize", "PNG", "SnapshotTesting"],
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
                .copy("Resources/defaultEnergyFunction scanlines.txt")
            ]
        )
    ]
    
)
