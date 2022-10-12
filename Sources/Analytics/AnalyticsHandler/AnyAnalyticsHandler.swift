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
public struct AnyAnalyticsHandler<EventName>: AnyAnalyticsEventHandler {
    /// Action to perform when analytics event and metadata tracking requested.
    ///
    /// Sends the event and metadata to ``AnalyticsHandler`` value initialized with
    /// erasing their types.
    internal let track: (AnyEvent, Date, AnyEvent.Metadata) -> Void

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
}
