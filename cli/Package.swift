// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "smith",
    platforms: [.macOS(.v15)],
    products: [
        .executable(
            name: "smith",
            targets: ["SmithCLI"]
        ),
    ],
    dependencies: [
        .package(path: "../../smith-diagnostics"),
        .package(path: "../../smith-foundation"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0")
    ],
    targets: [
        .executableTarget(
            name: "SmithCLI",
            dependencies: [
                .product(name: "SBDiagnostics", package: "smith-diagnostics"),
                .product(name: "SmithProgress", package: "smith-foundation"),
                .product(name: "SmithErrorHandling", package: "smith-foundation"),
                .product(name: "SmithOutputFormatter", package: "smith-foundation"),
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "SmithCLITests",
            dependencies: ["SmithCLI"]
        ),
    ]
)