import struct Foundation.Date

#if swift(>=5.7)
/// An `AnalyticsHandler` is an implementation of an analytics backend.
///
/// Use this type to implement your own analytics backend.
/// Implement ``track(event:at:data:)`` to handle tracking
/// of events and their metadata.
public protocol AnalyticsHandler<EventName> {
    /// The type of event name handled.
    ///
    /// Typically name can be a `String` or an enum with `String`
    /// raw value to avoid event name duplication.
    associatedtype EventName
    /// This method is called when `AnalyticsHandler` needs to track event
    /// and associated metadata fired at the provided time.
    ///
    /// - Parameters:
    ///   - event: The event to track.
    ///   - time: The time at which event fired.
    ///   - data: The associated metadata with event.
    func track<Event: AnalyticsEvent>(
        event: Event,
        at time: Date,
        data: Event.Metadata
    ) where Event.Name == EventName
}
#else
/// An `AnalyticsHandler` is an implementation of an analytics backend.
///
/// Use this type to implement your own analytics backend.
/// Implement ``track(event:at:data:)`` to handle tracking
/// of events and their metadata.
public protocol AnalyticsHandler {
    /// The type of event name handled.
    ///
    /// Typically name can be a `String` or an enum with `String`
    /// raw value to avoid event name duplication.
    associatedtype EventName
    /// This method is called when `AnalyticsHandler` needs to track event
    /// and associated metadata fired at the provided time.
    ///
    /// - Parameters:
    ///   - event: The event to track.
    ///   - time: The time at which event fired.
    ///   - data: The associated metadata with event.
    func track<Event: AnalyticsEvent>(
        event: Event,
        at time: Date,
        data: Event.Metadata
    ) where Event.Name == EventName
}
#endif

public extension AnalyticsHandler {
    /// This method is called when `AnalyticsHandler` needs
    /// to track event and any metadata fired at the provided time.
    ///
    /// - Parameters:
    ///   - event: The event to track.
    ///   - time: The time at which event fired.
    ///   - data: The associated metadata with event.
    @inlinable
    func track(
        event: AnyAnalyticsEvent<EventName>,
        at time: Date = .init(),
        anyData data: Encodable
    ) {
        self.track(
            event: event,
            at: time,
            data: data as? AnyMetadata ?? AnyMetadata(with: data)
        )
    }
}
