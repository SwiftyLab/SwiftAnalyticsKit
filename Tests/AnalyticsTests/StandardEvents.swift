import Analytics

enum LoginEvent: String, EmptyRawRepresentableAnalyticsEvent {
    case loginScreenViewed
    case loginAttempted
    case loginSucceeded

    var group: AnalyticsGroup {
        switch self {
        case .loginScreenViewed:
            return .state
        default:
            return .action
        }
    }
}

struct LoginFailureReason: GlobalAnalyticsMetadata {
    let reason: String

    var event: SomeStringAnalyticsEvent<Self> { "loginFailed" }
}

struct MessageSelected: GlobalAnalyticsMetadata {
    let index: Int

    var event: SomeStringAnalyticsEvent<Self> { "messageSelected" }
}

struct MessageDeleted: GlobalAnalyticsMetadata {
    let index: Int
    let read: Bool

    var event: SomeStringAnalyticsEvent<Self> { "messageDeleted" }
}

struct UserProfileData: GlobalAnalyticsMetadata {
    let name: String
    let email: String

    var event: SomeStringAnalyticsEvent<Self> { .some(group: .info) }
}

struct UserIdData: GlobalAnalyticsMetadata {
    let id: String

    var event: SomeStringAnalyticsEvent<Self> { .some(group: .sensitive) }
}
