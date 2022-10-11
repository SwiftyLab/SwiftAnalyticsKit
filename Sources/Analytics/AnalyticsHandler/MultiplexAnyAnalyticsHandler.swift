import struct Foundation.Date

/// A pseudo-``AnalyticsHandler`` that can be used to
/// send event track requests to multiple other ``AnalyticsHandler``s.
///
/// Use ``register(handler:for:)`` method to handle events for a specific set of group.
/// If an event specifies any of the group that ``AnalyticsHandler``s were registered with,
/// then that event can be tracked with the registered handlers.
///
/// ```swift
/// let handler = MultiplexAnyAnalyticsHandler<String>()
/// // Tracks events associated with action group.
/// handler.register(handler: actionH, for: .action)
/// // Tracks events associated with either action or state group.
/// handler.register(handler: actionStateH, for: [.action, .state])
/// ```
///
/// - Important: This type behaves similar to ``MultiplexAnalyticsHandler`` key difference being
///              all the events and metadata tracked by this handler are type-erased to ``AnyAnalyticsEvent``
///              and ``AnyMetadata`` respectively and then dispatched to registered ``AnalyticsHandler``s.
///              As a result of this type-change any type based assertions done at the individual ``AnalyticsHandler``
///              level will be impacted, while this opens up usage in wider Swift and platform versions.
public struct MultiplexAnyAnalyticsHandler<EventName>: AnalyticsHandler,
    Initializable, Hashable
{
    /// The type erased handler type stored.
    private typealias AnyHandler = AnyHashableAnalyticsHandler<EventName>
    /// All the registered handlers.
    private var handlers: [AnyHandler: AnalyticsGroup]

    /// Create a new `MultiplexAnyAnalyticsHandler`
    /// with no registered ``AnalyticsHandler``s.
    ///
    /// After initialization, use the ``register(handler:for:)``
    /// method to register ``AnalyticsHandler``s to track analytics
    /// events and metadata across multiple ``AnalyticsGroup``s.
    public init() {
        self.handlers = [:]
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
        for (handler, group) in handlers
        where !group.isDisjoint(with: event.group) {
            handler.track(event: event, at: time, data: data)
        }
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
    public mutating func register<Handler: AnalyticsHandler & Hashable>(
        handler: Handler,
        for group: AnalyticsGroup
    ) where Handler.EventName == EventName {
        let handler = AnyHandler(with: handler)
        if handlers[handler] == nil {
            handlers[handler] = group
        } else {
            handlers[handler]!.insert(group)
        }
    }
}
