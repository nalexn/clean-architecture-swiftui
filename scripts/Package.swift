// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "orbit",
    platforms: [
        .macOS(.v11)  // Set this to .v11 or later
    ],
    dependencies: [
        .package(url: "https://github.com/appwrite/sdk-for-swift.git", from: "6.1.0")
    ],
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    targets: [
        .executableTarget(
            name: "deleteAllUnusedAuthUsers",
            dependencies: [
                .product(name: "Appwrite", package: "sdk-for-swift")
            ]
        )
    ]
)
