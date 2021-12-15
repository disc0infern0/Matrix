// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MyMatrix",
    products: [
        .library(
            name: "MyMatrix",
            targets: ["Matrix"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Matrix",
            dependencies: []),
    ]
)
