#if swift(>=5.7)
/// A type representing metadata associated to specific analytics event.
///
/// Use this type if creating a separate type for a specific event doesn't make sense and
/// by using ``SomeAnalyticsEvent`` with this type similar functionality can be achieved.
public protocol GlobalAnalyticsMetadata<Event>: Encodable {
    /// The type of the event for this metadata.
    associatedtype Event: AnalyticsEvent where Event.Metadata == Self
    /// The event associated with this metadata.
    var event: Event { get }
    /// Sends metadata with associated event to provided handler.
    ///
    /// - Parameters:
    ///   - handler: The ``AnalyticsHandler`` to track this metadata.
    func send<Handler: AnalyticsHandler>(
        to handler: Handler
    ) where Handler.EventName == Event.Name
}
#else
/// A type representing metadata associated to specific analytics event.
///
/// Use this type if creating a separate type for a specific event doesn't make sense and
/// by using ``SomeAnalyticsEvent`` with this type similar functionality can be achieved.
public protocol GlobalAnalyticsMetadata: Encodable {
    /// The type of the event for this metadata.
    associatedtype Event: AnalyticsEvent where Event.Metadata == Self
    /// The event associated with this metadata.
    var event: Event { get }
    /// Sends metadata with associated event to provided handler.
    ///
    /// - Parameters:
    ///   - handler: The ``AnalyticsHandler`` to track this metadata.
    func send<Handler: AnalyticsHandler>(
        to handler: Handler
    ) where Handler.EventName == Event.Name
}
#endif

public extension GlobalAnalyticsMetadata {
    /// Sends metadata with associated event to provided handler.
    ///
    /// Invokes the ``AnalyticsEvent/fire(on:)`` method
    /// on the associated event.
    ///
    /// - Parameters:
    ///   - handler: The ``AnalyticsHandler`` to track this metadata.
    @inlinable
    func send<Handler: AnalyticsHandler>(
        to handler: Handler
    ) where Handler.EventName == Event.Name {
        event.fire(on: handler, data: self)
    }
}

public extension GlobalAnalyticsMetadata where Event: Initializable {
    /// The event associated with this metadata
    /// initialized without any parameters.
    var event: Event { .init() }
}
