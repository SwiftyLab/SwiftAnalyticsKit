#if swift(>=5.7)
/// A type representing an analytics event.
///
/// Use this type to implement an analytics event that can be handled by
/// any analytics backend implementing ``AnalyticsHandler``
/// with the same event name type.
public protocol AnalyticsEvent<Name,Metadata> {
    /// The type of the event name.
    ///
    /// Typically the type is `String`, or can be made
    /// enum with `String` raw value.
    ///
    /// ``AnalyticsHandler`` with the
    /// same name type can handle the event.
    associatedtype Name
    /// The metadata type associated with the event.
    ///
    /// Use this type to add compile time validation on
    /// analytics event metadata. In case, event must not
    /// have associated metadata ``EmptyMetadata``
    /// can be used.
    ///
    /// It is the responsibility of ``AnalyticsHandler``
    /// to serialize metadata to the actual type that will be stored.
    associatedtype Metadata: AnalyticsMetadata
    /// The name of the event.
    var name: Name { get }
    /// The group or set of groups event is part of.
    ///
    /// By default, events are only associated to
    /// ``AnalyticsGroup/action``.
    var group: AnalyticsGroup { get }
    /// The configuration of event deciding how event is consumed.
    ///
    /// By default ``DefaultConfiguration`` is used which
    /// just propagates event to ``AnalyticsHandler``.
    /// Additional configuration can be provided to allow some processing,
    /// i.e. debounce or throttle event tracking.
    var configuration: AnalyticsConfiguration { get }
    /// Fires event with associated metadata to the provided handler for tracking.
    ///
    /// By default, event with associated data and provided handler is passed
    /// to ``configuration-98oi3`` to apply some post processing.
    ///
    /// - Parameters:
    ///   - handler: The handler that will track this event.
    ///   - data: The associated metadata to track.
    func fire<Handler: AnalyticsHandler>(
        on handler: Handler,
        data: Metadata
    ) where Handler.EventName == Name
}
#else
/// A type representing an analytics event.
///
/// Use this type to implement an analytics event that can be handled by
/// any analytics backend implementing ``AnalyticsHandler``
/// with the same event name type.
public protocol AnalyticsEvent {
    /// The type of the event name.
    ///
    /// Typically the type is `String`, or can be made
    /// enum with `String` raw value.
    ///
    /// ``AnalyticsHandler`` with the
    /// same name type can handle the event.
    associatedtype Name
    /// The metadata type associated with the event.
    ///
    /// Use this type to add compile time validation on
    /// analytics event metadata. In case, event mustn't
    /// have associated metadata ``EmptyMetadata``
    /// can be used.
    ///
    /// It is the responsibility of ``AnalyticsHandler``
    /// to serialize metadata to the actual type that will be stored.
    associatedtype Metadata: AnalyticsMetadata
    /// The name of the event.
    var name: Name { get }
    /// The group or set of groups event is part of.
    ///
    /// By default, events are only associated to
    /// ``AnalyticsGroup/action``.
    var group: AnalyticsGroup { get }
    /// The configuration of event deciding how event is consumed.
    ///
    /// By default ``DefaultConfiguration`` is used which
    /// just propagates event to ``AnalyticsHandler``.
    /// Additional configuration can be provided to allow some processing,
    /// i.e. debounce or throttle event tracking.
    var configuration: AnalyticsConfiguration { get }
    /// Fires event with associated metadata to the provided handler for tracking.
    ///
    /// By default, event with associated data and provided handler is passed
    /// to ``configuration-98oi3`` to apply some post processing.
    ///
    /// - Parameters:
    ///   - handler: The handler that will track this event.
    ///   - data: The associated metadata to track.
    func fire<Handler: AnalyticsHandler>(
        on handler: Handler,
        data: Metadata
    ) where Handler.EventName == Name
}
#endif

public extension AnalyticsEvent {
    /// Fires event with associated metadata and the provided handler
    /// for tracking to ``configuration-98oi3`` to apply some post processing.
    ///
    /// - Parameters:
    ///   - handler: The handler that will track this event.
    ///   - data: The associated metadata to track.
    @inlinable
    func fire<Handler: AnalyticsHandler>(
        on handler: Handler,
        data: Metadata
    ) where Handler.EventName == Name {
        configuration.process(event: self, data: data, for: handler)
    }

    /// Fires event with the provided handler for tracking and initialized
    /// metadata to ``configuration-98oi3`` to apply some post processing.
    ///
    /// - Parameter handler: The handler that will track this event.
    @inlinable
    func fire<Handler: AnalyticsHandler>(
        on handler: Handler
    ) where Handler.EventName == Name, Metadata: Initializable {
        configuration.process(event: self, data: .init(), for: handler)
    }

    /// Associates event to ``AnalyticsGroup/action``
    /// by default.
    @inlinable
    var group: AnalyticsGroup { .action }

    /// Applies ``DefaultConfiguration`` to the event by default.
    @inlinable
    var configuration: AnalyticsConfiguration { DefaultConfiguration() }
}

public extension AnalyticsEvent where Self: RawRepresentable, Name == RawValue {
    /// A type that can be converted to and from an associated raw value.
    @inlinable
    var name: Name { rawValue }
}

#if swift(>=5.7)
/// A type of ``AnalyticsEvent`` that has no associated metadata.
public protocol EmptyAnalyticsEvent<Name>: AnalyticsEvent
where Metadata == EmptyMetadata {}

/// A type of ``AnalyticsEvent`` that has associated raw value as event name.
public protocol RawRepresentableAnalyticsEvent<RawValue,Metadata>:
    AnalyticsEvent, RawRepresentable
where RawValue == Name {}
/// A type of ``AnalyticsEvent`` that has associated raw value as event name
/// and no associated metadata.
public protocol EmptyRawRepresentableAnalyticsEvent<RawValue>:
    RawRepresentableAnalyticsEvent
where Metadata == EmptyMetadata {}
#else
/// A type of ``AnalyticsEvent`` that has no associated metadata.
public protocol EmptyAnalyticsEvent: AnalyticsEvent
where Metadata == EmptyMetadata {}

/// A type of ``AnalyticsEvent`` that has associated raw value as event name.
public protocol RawRepresentableAnalyticsEvent:
    AnalyticsEvent, RawRepresentable
where RawValue == Name {}
/// A type of ``AnalyticsEvent`` that has associated raw value as event name
/// and no associated metadata.
public protocol EmptyRawRepresentableAnalyticsEvent:
    RawRepresentableAnalyticsEvent
where Metadata == EmptyMetadata {}
#endif
