import struct Foundation.Date

/// A type representing type-erased `AnalyticsHandler`s.
protocol AnyAnalyticsEventHandler: AnalyticsHandler {
    /// Type-erased event value type.
    typealias AnyEvent = AnyAnalyticsEvent<EventName>
    /// Action to perform when analytics event and metadata tracking requested.
    var track: (AnyEvent, Date, AnyEvent.Metadata) -> Void { get }
}

extension AnyAnalyticsEventHandler {
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
