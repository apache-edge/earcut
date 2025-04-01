// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Earcut",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "Earcut",
            targets: ["Earcut"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Earcut",
            dependencies: []),
        .testTarget(
            name: "EarcutTests",
            dependencies: ["Earcut"]),
    ]
)