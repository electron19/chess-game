// swift-tools-version: 5.5
import PackageDescription

let package = Package(
    name: "ChessGame",
    platforms: [.macOS(.v12)],
    targets: [
        .target(
            name: "ChessCore",
            path: "Sources/ChessCore"
        ),
        .executableTarget(
            name: "ChessGame",
            dependencies: ["ChessCore"],
            path: "Sources/ChessGame"
        ),
        .testTarget(
            name: "ChessGameTests",
            dependencies: ["ChessCore"],
            path: "Tests/ChessGameTests"
        )
    ]
)
