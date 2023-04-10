// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "Nautilus",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "nautilus-node", targets: ["Nautilus"])
    ],
    targets: [
        .executableTarget(name: "Nautilus", path: "Sources"),
    ]
)
