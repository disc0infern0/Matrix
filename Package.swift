// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Matrix",
    platforms: [ .macOS(.v10_15), .iOS(.v13) ],
    products: [
        .library(
            name: "Matrix",
            targets: ["Matrix"]),
    ],
    targets: [
        .target(
            name: "Matrix",
            path: "Sources"),
    ]
)
