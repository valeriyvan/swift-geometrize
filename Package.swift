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
        .package(name: "PNG", url: "https://github.com/kelvin13/swift-png", from: "4.0.1")
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
            dependencies: ["geometrize", "PNG"],
            path: "Tests/geometrizeTests",
            resources: [
                .copy("Resources/grapefruit.png")
            ]
        )
    ]
    
)
