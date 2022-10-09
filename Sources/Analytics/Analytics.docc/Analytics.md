# ``Analytics``

A Composable Analytics API for Swift.

## Overview

**SwiftAnalyticsKit** is an API package which tries to establish a common analytics API the ecosystem can use. You can implement ``AnalyticsHandler`` to create compatible analytics backends. You can also create custom encoders with ``AnalyticsEncoder`` to serialize metadata for your backend if default encoders doesn't work for your case.


Implement ``AnalyticsEvent`` to create compatible events or implement ``GlobalAnalyticsMetadata`` to create compatible metadata objects without specific event types:

```swift
enum LoginEvent: String, AnalyticsEvent {
    case loginAttempted
    case loginSucceeded
    case loginFailed

    struct Metadata: Encodable {
        let user: String
    }
}

let handler = MultiplexAnalyticsHandler<String>()
LoginEvents.loginAttempted.fire(on: handler, data: .init(user: "user"))
```

## Topics

### Event

- ``AnalyticsEvent``
- ``RawAnalyticsEvent``
- ``SomeAnalyticsEvent``
- ``AnyAnalyticsEvent``
- ``EmptyAnalyticsEvent``
- ``SomeStringAnalyticsEvent``
- ``AnyStringAnalyticsEvent``
- ``RawRepresentableAnalyticsEvent``
- ``EmptyRawRepresentableAnalyticsEvent``

### Event Properties

- ``AnalyticsGroup``
- ``AnalyticsConfiguration``
- ``DefaultConfiguration``

### Metadata

- ``GlobalAnalyticsMetadata``
- ``EmptyMetadata``
- ``AnyMetadata``

### Serialization

- ``AnalyticsEncoder``
- ``EncodingFailureAction``

### Handler

- ``AnalyticsHandler``
- ``MultiplexAnalyticsHandler``
