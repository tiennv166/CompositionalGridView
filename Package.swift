// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "CompositionalGridView",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(name: "CompositionalGridView", targets: ["CompositionalGridView"])
    ],
    dependencies: [
        .package(url: "https://github.com/Quick/Quick.git", .upToNextMajor(from: "6.0.0")),
        .package(url: "https://github.com/Quick/Nimble.git", .upToNextMajor(from: "12.0.0"))
    ],
    targets: [
        .target(
            name: "CompositionalGridView",
            path: "CompositionalGridView/Classes"
        ),
        .testTarget(
            name: "CompositionalGridViewTests",
            dependencies: [
                "CompositionalGridView",
                .product(name: "Quick", package: "Quick"),
                .product(name: "Nimble", package: "Nimble")
            ],
            path: "Tests"
        )
    ],
    swiftLanguageVersions: [.v5]
)
