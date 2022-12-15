#if swift(>=5.7)
import Foundation

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
public struct MultiplexAnalyticsHandler<EventName>: AnalyticsHandler,
    Initializable, Hashable
{
    /// A type-erased hashable ``AnalyticsHandler`` value.
    ///
    /// The `AnyHandler` type forwards event and metadata tracking,
    /// equality comparisons and hashing operations to an underlying
    /// ``AnalyticsHandler`` value, hiding the type of the wrapped value.
    struct AnyHandler: AnalyticsHandler, Hashable {
        /// The value wrapped by this instance.
        let value: any AnalyticsHandler<EventName>

        /// Creates a type-erased ``AnalyticsHandler`` value that wraps the given instance.
        ///
        /// - Parameter handler: An ``AnalyticsHandler`` value to wrap.
        init<Handler: AnalyticsHandler<EventName> & Hashable>(
            with value: Handler
        ) {
            self.value = value
        }

        /// Propagates event track request to type-erased ``AnalyticsHandler``
        /// wrapped during initialization, after erasing type of provided event and metadata.
        ///
        /// - Parameters:
        ///   - event: The event to track.
        ///   - time: The time at which event fired.
        ///   - data: The associated metadata with event.
        func track<Event: AnalyticsEvent>(
            event: Event,
            at time: Date,
            data: Event.Metadata
        ) where EventName == Event.Name {
            value.track(event: event, at: time, data: data)
        }

        /// Returns a Boolean value indicating whether two type-erased
        /// ``AnalyticsHandler`` instances wrap the same value.
        ///
        /// - Parameters:
        ///   - lhs: A type-erased ``AnalyticsHandler`` value.
        ///   - rhs: Another type-erased ``AnalyticsHandler`` value.
        ///
        /// - Returns: Whether both instances wrap the same value.
        static func == (lhs: Self, rhs: Self) -> Bool {
            func valueAs<T, U>(value: T, _ type: U.Type) -> U? { value as? U }
            func isEql(lhs: some Hashable, rhs: some Hashable) -> Bool {
                guard let rhs = valueAs(value: rhs, type(of: lhs))
                else { return false }
                return rhs == lhs
            }

            let lhsValue = lhs.value as! any Hashable
            let rhsValue = rhs.value as! any Hashable
            return isEql(lhs: lhsValue, rhs: rhsValue)
        }

        /// Hashes the underlying ``AnalyticsHandler`` value
        /// by feeding them into the given hasher.
        ///
        /// - Parameter hasher: The hasher to use when combining
        ///                     the components of this instance.
        func hash(into hasher: inout Hasher) {
            (value as! any Hashable).hash(into: &hasher)
        }
    }

    /// All the registered handlers.
    private var handlers: [AnyHandler: AnalyticsGroup]

    /// Create a new `MultiplexAnalyticsHandler`
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
#endif
