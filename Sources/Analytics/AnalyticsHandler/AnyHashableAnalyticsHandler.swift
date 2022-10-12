import struct Foundation.Date

/// A type-erased hashable ``AnalyticsHandler`` value.
///
/// The `AnyAnalyticsHandler` type forwards event and metadata tracking, equality comparisons
/// and hashing operations to an underlying ``AnalyticsHandler`` value, hiding the type of the wrapped value.
///
/// - Important: All the events and metadata tracked by this handler are type-erased to ``AnyAnalyticsEvent``
///              and ``AnyMetadata`` respectively and then dispatched to wrapped ``AnalyticsHandler``.
///              As a result of this type-change any type based assertions done at the underlying ``AnalyticsHandler``
///              will be impacted.
public struct AnyHashableAnalyticsHandler<EventName>: AnyAnalyticsEventHandler,
    Hashable
{
    /// The value wrapped by this instance.
    private let handler: AnyHashable
    /// Action to perform when analytics event and metadata tracking requested.
    ///
    /// Sends the event and metadata to ``AnalyticsHandler`` value initialized with
    /// erasing their types.
    internal let track: (AnyEvent, Date, AnyEvent.Metadata) -> Void

    /// Creates a type-erased ``AnalyticsHandler`` value that wraps the given instance.
    ///
    /// - Parameter handler: An ``AnalyticsHandler`` value to wrap.
    public init<Handler: AnalyticsHandler & Hashable>(
        with handler: Handler
    ) where Handler.EventName == EventName {
        self.handler = handler
        self.track = { event, time, data in
            handler.track(event: event, at: time, data: data)
        }
    }

    /// Returns a Boolean value indicating whether two type-erased
    /// ``AnalyticsHandler`` instances wrap the same value.
    ///
    /// - Parameters:
    ///   - lhs: A type-erased ``AnalyticsHandler`` value.
    ///   - rhs: Another type-erased ``AnalyticsHandler`` value.
    ///
    /// - Returns: Whether both instances wrap the same value.
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.handler == rhs.handler
    }

    /// Hashes the underlying ``AnalyticsHandler`` value
    /// by feeding them into the given hasher.
    ///
    /// - Parameter hasher: The hasher to use when combining
    ///                     the components of this instance.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(handler)
    }
}
