// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "NearPeer",
    platforms: [
        .macOS(.v12),
        .iOS(.v13),
        .tvOS(.v13),
    ],
    products: [
        .library(
            name: "NearPeer",
            targets: ["NearPeer"]
        ),
    ],
    targets: [
        .target(
            name: "NearPeer",
            dependencies: []
        ),
        .testTarget(
            name: "NearPeerTests",
            dependencies: ["NearPeer"]
        ),
    ]
)
