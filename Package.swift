// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "AvastShellApp",
    platforms: [
        .macOS(.v15)
    ],
    products: [
        .executable(name: "AvastShellApp", targets: ["AvastShellApp"])
    ],
    targets: [
        .executableTarget(
            name: "AvastShellApp",
            path: "Sources/AvastShellApp"
        ),
        .testTarget(
            name: "AvastShellAppTests",
            dependencies: ["AvastShellApp"],
            path: "Tests/AvastShellAppTests"
        )
    ]
)
