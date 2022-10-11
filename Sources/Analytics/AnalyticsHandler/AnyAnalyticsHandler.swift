import struct Foundation.Date

/// A type-erased ``AnalyticsHandler`` value.
///
/// The `AnyAnalyticsHandler` type forwards event and metadata tracking
/// to an underlying ``AnalyticsHandler`` value, hiding the type of the wrapped value.
///
/// - Important: All the events and metadata tracked by this handler are type-erased to ``AnyAnalyticsEvent``
///              and ``AnyMetadata`` respectively and then dispatched to wrapped ``AnalyticsHandler``.
///              As a result of this type-change any type based assertions done at the underlying ``AnalyticsHandler``
///              will be impacted.
public struct AnyAnalyticsHandler<EventName>: AnalyticsHandler {
    /// Type-erased event value type.
    private typealias AnyEvent = AnyAnalyticsEvent<EventName>
    /// Action to perform when analytics event and metadata tracking requested.
    ///
    /// Sends the event and metadata to ``AnalyticsHandler`` value initialized with
    /// erasing their types.
    private let track: (AnyEvent, Date, AnyEvent.Metadata) -> Void

    /// Creates a type-erased ``AnalyticsHandler`` value that wraps the given instance.
    ///
    /// - Parameter handler: An ``AnalyticsHandler`` value to wrap.
    public init<Handler: AnalyticsHandler>(
        with handler: Handler
    ) where Handler.EventName == EventName {
        self.track = { event, time, data in
            handler.track(event: event, at: time, data: data)
        }
    }

    /// Propagates event track request to type-erased ``AnalyticsHandler``
    /// wrapped during initialization, after erasing type of provided event and metadata.
    ///
    /// - Parameters:
    ///   - event: The event to track.
    ///   - time: The time at which event fired.
    ///   - data: The associated metadata with event.
    public func track<Event: AnalyticsEvent>(
        event: Event,
        at time: Date,
        data: Event.Metadata
    ) where EventName == Event.Name {
        track(
            event as? AnyEvent ?? AnyEvent(from: event),
            time,
            data as? AnyEvent.Metadata ?? AnyEvent.Metadata(with: data)
        )
    }
}
