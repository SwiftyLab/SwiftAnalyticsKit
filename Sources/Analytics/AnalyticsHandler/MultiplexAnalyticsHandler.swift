#if swift(>=5.7)
import struct Foundation.Date

/// A pseudo-``AnalyticsHandler`` that can be used to
/// send event track requests to multiple other ``AnalyticsHandler``s.
///
/// Use ``register(handler:for:)`` method to handle events for a specific set of group.
/// If an event specifies any of the group that ``AnalyticsHandler``s were registered with,
/// then that event can be tracked with the registered handlers.
///
/// ```swift
/// let handler = MultiplexAnalyticsHandler<String>()
/// // Tracks events associated with action group.
/// handler.register(handler: actionH, for: .action)
/// // Tracks events associated with either action or state group.
/// handler.register(handler: actionStateH, for: [.action, .state])
/// ```
@available(macOS 13, iOS 16, tvOS 16, watchOS 9, *)
public struct MultiplexAnalyticsHandler<EventName>: AnalyticsHandler {
    /// All the registered handlers.
    private var handlers: [AnalyticsGroup: [any AnalyticsHandler<EventName>]]

    /// Create a `MultiplexAnalyticsHandler`.
    ///
    /// - Parameter handlers: An array of ``AnalyticsHandler``s associated with ``AnalyticsGroup``,
    ///                       each of which will receive the event track request sent to this handler depending on
    ///                       whether event is associated with any of the group.
    public init(
        handlers: [AnalyticsGroup: [any AnalyticsHandler<EventName>]] = [:]
    ) {
        self.handlers = handlers
    }

    /// Propagates event track request to registered handlers depending on
    /// whether event is associated with any of the registered groups.
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
        handlers.lazy
            .flatMap { $0.key.isDisjoint(with: event.group) ? [] : $0.value }
            .forEach { $0.track(event: event, at: time, data: data) }
    }

    /// Registers an ``AnalyticsHandler`` that tracks events
    /// associated to any of the groups provided.
    ///
    /// If events passed with ``track(event:at:data:)`` associated to
    /// any group that handlers were registered with then handlers can track these events.
    ///
    /// - Parameters:
    ///   - handler: The ``AnalyticsHandler`` to add.
    ///   - group: The group that handler tracks.
    public mutating func register<Handler: AnalyticsHandler>(
        handler: Handler,
        for group: AnalyticsGroup
    ) where Handler.EventName == EventName {
        if handlers[group] == nil {
            handlers[group] = [handler]
        } else {
            handlers[group]!.append(handler)
        }
    }
}
#endif
