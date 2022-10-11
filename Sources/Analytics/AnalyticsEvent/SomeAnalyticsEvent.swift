/// A type-erased ``AnalyticsEvent`` that only keeps the event name and metadata type information.
///
/// This type provides the safety guarantee of associating events with a specific type metadata while also
/// erasing the actual event type. This can be used for metadata of type ``GlobalAnalyticsMetadata``
/// where it does not make sense to create a new event type for the metadata.
public struct SomeAnalyticsEvent<
    Name,
    Metadata: AnalyticsMetadata
>: RawAnalyticsEvent {
    /// The name of the event.
    public let name: Name
    /// The group or set of groups event is part of.
    ///
    /// By default, events are only associated to
    /// ``AnalyticsGroup/action``.
    public let group: AnalyticsGroup
    /// The configuration of event deciding how event is consumed.
    ///
    /// By default ``DefaultConfiguration`` is used which
    /// just propagates event to ``AnalyticsHandler``.
    /// Additional configuration can be provided to allow some processing,
    /// i.e. debounce or throttle event tracking.
    public let configuration: AnalyticsConfiguration

    /// Creates a new analytics event with provided parameters.
    ///
    /// Default group ``AnalyticsGroup/action`` and ``DefaultConfiguration``
    /// are used if group and configuration not specified respectively.
    ///
    /// - Parameters:
    ///   - name: The event name.
    ///   - group: The group or set of groups event associated with.
    ///   - configuration: The configuration of event.
    public init(
        name: Name,
        group: AnalyticsGroup = .action,
        configuration: AnalyticsConfiguration = DefaultConfiguration()
    ) {
        self.name = name
        self.group = group
        self.configuration = configuration
    }
}

extension SomeAnalyticsEvent: ExpressibleByUnicodeScalarLiteral
where Name: ExpressibleByUnicodeScalarLiteral {}

extension SomeAnalyticsEvent: ExpressibleByExtendedGraphemeClusterLiteral
where Name: ExpressibleByExtendedGraphemeClusterLiteral {}

extension SomeAnalyticsEvent: ExpressibleByStringLiteral
where Name: ExpressibleByStringLiteral {}

/// A type-erased ``AnalyticsEvent`` with `String` event name
/// that only keeps metadata type information.
public typealias SomeStringAnalyticsEvent<Metadata: AnalyticsMetadata> =
    SomeAnalyticsEvent<String, Metadata>
