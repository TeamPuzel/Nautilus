// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "Nautilus",
    platforms: [.macOS(.v13)],
    products: [
        // .executable(name: "echo-legacy", targets: ["Legacy"]),
        .executable(name: "echo", targets: ["Echo"]),
        .executable(name: "unique-id", targets: ["UniqueID"]),
        .executable(name: "broadcast", targets: ["Broadcast"])
    ],
    targets: [
        // This was the first attempt used for figuring out
        // the protocol and making sure everything was set up correctly.
        // Left here as a reference.
        .executableTarget(name: "Legacy"),
        
        // This is the implementation of a simple node library
        // used to more easily design nodes for the challenges.
        .target(name: "Nautilus",
            swiftSettings: [
                // Comment out to disable async handling of messages
                .define("ASYNC")
            ]
        ),
        
        // These are the nodes solving each challenge.
        .executableTarget(name: "Echo", dependencies: ["Nautilus"]),
        .executableTarget(name: "UniqueID", dependencies: ["Nautilus"]),
        .executableTarget(name: "Broadcast", dependencies: ["Nautilus"])
    ]
)
