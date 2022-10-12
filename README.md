# SwiftAnalyticsKit

[![API Docs](http://img.shields.io/badge/Read_the-docs-2196f3.svg)](https://swiftylab.github.io/SwiftAnalyticsKit/documentation/analytics/)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/SwiftAnalyticsKit.svg?label=CocoaPods&color=C90005)](https://badge.fury.io/co/SwiftAnalyticsKit)
[![Swift Package Manager Compatible](https://img.shields.io/github/v/tag/SwiftyLab/SwiftAnalyticsKit?label=SPM&color=orange)](https://badge.fury.io/gh/SwiftyLab%2FSwiftAnalyticsKit)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg)](https://github.com/Carthage/Carthage)
[![Swift](https://img.shields.io/badge/Swift-5+-orange)](https://img.shields.io/badge/Swift-5-DE5D43)
[![Platforms](https://img.shields.io/badge/Platforms-all-sucess)](https://img.shields.io/badge/Platforms-all-sucess)
[![CI/CD](https://github.com/SwiftyLab/SwiftAnalyticsKit/actions/workflows/main.yml/badge.svg?event=push)](https://github.com/SwiftyLab/SwiftAnalyticsKit/actions/workflows/main.yml)
[![CodeFactor](https://www.codefactor.io/repository/github/swiftylab/swiftanalyticskit/badge)](https://www.codefactor.io/repository/github/swiftylab/swiftanalyticskit)
[![codecov](https://codecov.io/gh/SwiftyLab/SwiftAnalyticsKit/branch/main/graph/badge.svg?token=YSryFeUvVW)](https://codecov.io/gh/SwiftyLab/SwiftAnalyticsKit)

**SwiftAnalyticsKit** is an API package which tries to establish a common analytics API the ecosystem can use. You can implement ``AnalyticsHandler`` to create compatible analytics backends. You can also create custom encoders with ``AnalyticsEncoder`` to serialize metadata for your backend if default encoders doesn't work for your case.

Implement ``AnalyticsEvent`` to create compatible events or implement ``GlobalAnalyticsMetadata`` to create compatible metadata objects without specific event types:

```swift
enum LoginEvent: String, AnalyticsEvent {
    case loginAttempted
    case loginSucceeded
    case loginFailed

    struct Metadata: AnalyticsMetadata {
        let user: String
    }
}

let handler = MultiplexAnalyticsHandler<String>()
LoginEvents.loginAttempted.fire(on: handler, data: .init(user: "user"))
```

## Requirements

| Platform | Minimum Swift Version | Installation | Status |
| --- | --- | --- | --- |
| iOS 8.0+ / macOS 10.10+ / tvOS 9.0+ / watchOS 2.0+ | 5.1 | [CocoaPods](#cocoapods), [Carthage](#carthage), [Swift Package Manager](#swift-package-manager), [Manual](#manually) | Fully Tested |
| Linux | 5.1 | [Swift Package Manager](#swift-package-manager) | Fully Tested |
| Windows | 5.3 | [Swift Package Manager](#swift-package-manager) | Fully Tested |

## Installation

### CocoaPods

[CocoaPods](https://cocoapods.org) is a dependency manager for Cocoa projects. For usage and installation instructions, visit their website. To integrate `SwiftAnalyticsKit` into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
pod 'SwiftAnalyticsKit'
```

Optionally, you can also use the pre-built XCFramework from the GitHub releases page by replacing `{version}` with the required version you want to use:

```ruby
pod 'SwiftAnalyticsKit', :http => 'https://github.com/SwiftyLab/SwiftAnalyticsKit/releases/download/v{version}/SwiftAnalyticsKit-{version}.xcframework.zip'
```

To use default mocks provided for test cases, add the `Mock` subspec to your test target:

```ruby
pod 'SwiftAnalyticsKit/Mock'
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks. To integrate `SwiftAnalyticsKit` into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "SwiftyLab/SwiftAnalyticsKit"
```

### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler.

Once you have your Swift package set up, adding `SwiftAnalyticsKit` as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift`.

```swift
.package(url: "https://github.com/SwiftyLab/SwiftAnalyticsKit.git", from: "1.0.0"),
```

and add products as dependency to your targets:

```swift
.product(name: "Analytics", package: "SwiftAnalyticsKit")
.product(name: "AnalyticsMock", package: "SwiftAnalyticsKit") // To use mocks, i.e. in test targets
```

Optionally, you can also use the pre-built XCFramework from the GitHub releases page by replacing `{version}` and `{checksum}` with the required version and checksum of artifact you want to use:

```swift
.binaryTarget(name: "Analytics", url: "https://github.com/SwiftyLab/SwiftAnalyticsKit/releases/download/v{version}/SwiftAnalyticsKit-{version}.xcframework.zip", checksum: "{checksum}"),
```

### Manually

If you prefer not to use any of the aforementioned dependency managers, you can integrate `SwiftAnalyticsKit` into your project manually.

#### Git Submodule

- Open up Terminal, `cd` into your top-level project directory, and run the following command "if" your project is not initialized as a git repository:

  ```bash
  $ git init
  ```

- Add `SwiftAnalyticsKit` as a git [submodule](https://git-scm.com/docs/git-submodule) by running the following command:

  ```bash
  $ git submodule add https://github.com/SwiftyLab/SwiftAnalyticsKit.git
  ```

- Open the new `SwiftAnalyticsKit` folder, and drag the `SwiftAnalyticsKit.xcodeproj` into the Project Navigator of your application's Xcode project or existing workspace.

    > It should appear nested underneath your application's blue project icon. Whether it is above or below all the other Xcode groups does not matter.

- Select the `SwiftAnalyticsKit.xcodeproj` in the Project Navigator and verify the deployment target satisfies that of your application target (should be less or equal).
- Next, select your application project in the Project Navigator (blue project icon) to navigate to the target configuration window and select the application target under the `Targets` heading in the sidebar.
- In the tab bar at the top of that window, open the "General" panel.
- Click on the `+` button under the `Frameworks and Libraries` section.
- You will see `SwiftAnalyticsKit.xcodeproj` folder with `Analytics.framework` and `AnalyticsMock.framework` nested inside.
- Select the `Analytics.framework` and that's it!

  > The `Analytics.framework` is automagically added as a target dependency, linked framework and embedded framework in build phase which is all you need to build on the simulator and a device.

- To use default mocks provided for test cases, select the `AnalyticsMock.framework` when adding to your test target.

#### XCFramework

You can also directly download the pre-built artifact from the GitHub releases page:

- Download the artifact from the GitHub releases page of the format `SwiftAnalyticsKit-{version}.xcframework.zip` where `{version}` is the version you want to use.
- Extract the XCFrameworks from the archive, and drag the `Analytics.xcframework` into the Project Navigator of your application's target folder in your Xcode project.
- Select `Copy items if needed` and that's it!

  > The `Analytics.xcframework` is automagically added in the embedded `Frameworks and Libraries` section, an in turn the linked framework in build phase.

- To use default mocks provided for test cases, use `AnalyticsMock.xcframework` from previously extracted XCFrameworks.

## Usage

See the full [documentation](https://swiftylab.github.io/SwiftAnalyticsKit/documentation/analytics/) for API details and articles on sample scenarios.

## Contributing

If you wish to contribute a change, suggest any improvements,
please review our [contribution guide](CONTRIBUTING.md),
check for open [issues](https://github.com/SwiftyLab/SwiftAnalyticsKit/issues), if it is already being worked upon
or open a [pull request](https://github.com/SwiftyLab/SwiftAnalyticsKit/pulls).

## License

`SwiftAnalyticsKit` is released under the MIT license. [See LICENSE](LICENSE) for details.
