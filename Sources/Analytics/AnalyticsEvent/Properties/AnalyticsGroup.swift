/// The group for analytics event.
///
/// ``AnalyticsEvent``s can be associated with either one or multiple groups
/// to specify their handling by the analytics backend (``AnalyticsHandler``).
public struct AnalyticsGroup: OptionSet, Hashable {
    /// Appropriate for events that contain information normally of use only when
    /// tracing the execution of a program.
    public static let trace: Self = .init(rawValue: 1 << 0)
    /// Appropriate for events that contain information normally of use only when
    /// debugging a program.
    public static let debug: Self = .init(rawValue: 1 << 1)
    /// Appropriate for events that provide some global or user specific informations.
    public static let info: Self = .init(rawValue: 1 << 2)
    /// Appropriate for events that contain information about action performed
    /// during the execution of a program.
    public static let action: Self = .init(rawValue: 1 << 3)
    /// Appropriate for events that contain information about the current state
    /// during the execution of a program.
    public static let state: Self = .init(rawValue: 1 << 4)
    /// Appropriate for events that are not errors, but that may require
    /// special handling.
    public static let notice: Self = .init(rawValue: 1 << 5)
    /// Appropriate for events that are not errors, but more severe than
    /// ``notice``.
    public static let warning: Self = .init(rawValue: 1 << 6)
    /// Appropriate for error events.
    public static let error: Self = .init(rawValue: 1 << 7)
    /// Appropriate for critical errors that usually require immediate attention.
    ///
    /// When a `critical` event is tracked, the analytics
    /// backend (``AnalyticsHandler``) is free to perform more heavy-weight
    /// operations to capture system state (such as capturing stack traces) to facilitate
    /// debugging.
    public static let critical: Self = .init(rawValue: 1 << 8)
    /// Appropriate for events that contain private or sensitive information,
    /// that might require different handling.
    public static let sensitive: Self = .init(rawValue: 1 << 9)

    /// Default groups provided as part of this package.
    static var defaultGroups: Self = [
        .trace, .debug,
        .info, .action, .state, .sensitive,
        .notice, .warning, .error, .critical,
    ]

    /// The corresponding value of the group.
    ///
    /// A new instance initialized with `rawValue`
    /// will be equivalent to this instance. For example:
    /// ```swift
    /// print(AnalyticsGroup(rawValue: 1 << 0) == AnalyticsGroup.trace)
    /// // Prints "true"
    /// ```
    public let rawValue: UInt
    /// Creates a new group from the given raw value.
    ///
    /// Use this initializer to create new groups if provided default groups
    /// are not enough.
    ///
    /// - Parameter rawValue: The raw value of the group to create.
    /// - Returns: The newly created analytics group.
    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }
}
