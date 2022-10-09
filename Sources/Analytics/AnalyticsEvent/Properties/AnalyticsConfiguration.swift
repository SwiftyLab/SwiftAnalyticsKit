import struct Foundation.Date

/// The configuration of analytics event.
///
/// Use this type to create new configurations to apply additional processing
/// to ``AnalyticsEvent``s before sending them for tracking to analytics
/// backend (``AnalyticsHandler``).
public protocol AnalyticsConfiguration {
    /// Processes event fired at specified time with associated metadata
    /// and the provided handler for tracking.
    ///
    /// Additional processing can be done to allow specific event tracking requirement,
    /// i.e. debounce or throttle event tracking.
    ///
    /// - Parameters:
    ///   - event: The event to process.
    ///   - time: The time at which event fired.
    ///   - data: The metadata associated with the event.
    ///   - handler: The handler that will track the event after processing.
    func process<Event: AnalyticsEvent, Handler: AnalyticsHandler>(
        event: Event,
        at time: Date,
        data: Event.Metadata,
        for handler: Handler
    ) where Event.Name == Handler.EventName
}

public extension AnalyticsConfiguration {
    /// Passes event fired at specified time with associated metadata
    /// to the provided handler for tracking as is without any processing.
    ///
    /// If time isn't specified, time at which this method invoked
    /// is taken into consideration.
    ///
    /// - Parameters:
    ///   - event: The event to process.
    ///   - time: The time at which event fired.
    ///   - data: The metadata associated with the event.
    ///   - handler: The handler that will track the event after processing.
    @inlinable
    func process<Event: AnalyticsEvent, Handler: AnalyticsHandler>(
        event: Event,
        at time: Date = .init(),
        data: Event.Metadata,
        for handler: Handler
    ) where Event.Name == Handler.EventName {
        handler.track(event: event, at: time, data: data)
    }
}

/// The default configuration for analytics events that sends them to analytics
/// backend (``AnalyticsHandler``) as is without any processing.
public struct DefaultConfiguration: AnalyticsConfiguration, Initializable {
    public init() {}
}
