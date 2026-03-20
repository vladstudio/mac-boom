// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "Boom",
    platforms: [.macOS(.v15)],
    targets: [
        .executableTarget(
            name: "Boom",
            path: "app/Boom",
            exclude: ["Info.plist"]
        )
    ]
)
