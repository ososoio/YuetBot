// swift-tools-version:5.3

import PackageDescription

#if os(Linux)
let package = Package(
        name: "YuetBot",
        products: [
                .executable(name: "yuetbot", targets: ["YuetBot"])
        ],
        dependencies: [
                .package(name: "ZEGBot", url: "https://github.com/ShaneQi/ZEGBot.git", from: "4.2.6"),
                .package(name: "swift-log", url: "https://github.com/apple/swift-log.git", from: "1.4.0"),
                .package(name: "SQLite3", url: "https://github.com/ososoio/SQLite3.git", from: "1.0.0")
        ],
        targets: [
                .target(
                        name: "YuetBot",
                        dependencies: [
                                .product(name: "ZEGBot", package: "ZEGBot"),
                                .product(name: "Logging", package: "swift-log"),
                                .product(name: "SQLite3", package: "SQLite3")
                        ]
                ),
                .testTarget(
                        name: "YuetBotTests",
                        dependencies: ["YuetBot"]),
        ]
)
#else
let package = Package(
        name: "YuetBot",
        platforms: [.macOS(.v11)],
        products: [
                .executable(name: "yuetbot", targets: ["YuetBot"])
        ],
        dependencies: [
                .package(name: "ZEGBot", url: "https://github.com/ShaneQi/ZEGBot.git", from: "4.2.6"),
                .package(name: "swift-log", url: "https://github.com/apple/swift-log.git", from: "1.4.0")
        ],
        targets: [
                .target(
                        name: "YuetBot",
                        dependencies: [
                                .product(name: "ZEGBot", package: "ZEGBot"),
                                .product(name: "Logging", package: "swift-log")
                        ]
                ),
                .testTarget(
                        name: "YuetBotTests",
                        dependencies: ["YuetBot"]),
        ]
)
#endif
