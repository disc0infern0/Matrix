// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Matrix",
    products: [
        .library(
            name: "Matrix",
            targets: ["Matrix"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Matrix",
            dependencies: []),
    ]
)
