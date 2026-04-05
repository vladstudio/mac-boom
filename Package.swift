// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "Boom",
    platforms: [.macOS(.v14)],
    dependencies: [
        .package(path: "../mac-app-kit"),
    ],
    targets: [
        .executableTarget(
            name: "Boom",
            dependencies: [.product(name: "MacAppKit", package: "mac-app-kit")],
            path: "app/Boom",
            exclude: ["Info.plist"]
        )
    ]
)
