// swift-tools-version: 5.6

import PackageDescription

let darwin: [Platform] = [.macOS, .iOS, .tvOS, .watchOS, .macCatalyst]
let xctest: LinkerSetting = .linkedFramework("XCTest", .when(platforms: darwin))

let package = Package(
    name: "SwiftAnalyticsKit",
    platforms: [
        .iOS(.v8),
        .macOS(.v10_10),
        .tvOS(.v9),
        .watchOS(.v2),
        .macCatalyst(.v13)
    ],
    products: [
        .library(name: "Analytics", targets: ["Analytics"]),
        .library(name: "AnalyticsMock", targets: ["AnalyticsMock"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-format", from: "0.50700.0"),
    ],
    targets: [
        .target(name: "Analytics"),
        .target(name: "AnalyticsMock", dependencies: ["Analytics"], linkerSettings: [xctest]),
        .testTarget(name: "AnalyticsTests", dependencies: ["Analytics", "AnalyticsMock"]),
    ],
    swiftLanguageVersions: [.v5]
)
