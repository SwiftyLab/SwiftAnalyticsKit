import Analytics
import XCTest

/// An `AnalyticsHandler` that tracks expected events by their name.
///
/// Use this type to check if analytics events with specified name have been fired as part of the test.
/// Use the `XCTestCase` extension methods to register expectation of an analytics event
/// with optional callback for validation. The expectation is fulfilled multiple times and callback
/// is invoked multiple times depending on whether associated event is fired multiple times.
///
/// If the registered event names aren't tracked by this handler, then test is failed with unfulfilled expectations.
/// If the expected event and metadata type don't match or any assertions failed in provided callback,
/// then also test is failed.
///
/// - Important: Only one expectation can be registered per event name.
public final class AnalyticsSingleExpectationHandler<
    EventName: Hashable
>: AnalyticsExpectationHandler, Hashable {
    /// All the event expectations registered.
    private var handlers: [EventName: Expectation] = [:]

    /// Creates a new instance of handler.
    public init() {}

    /// Store expectation to be fulfilled later when analytics event
    /// associated with it is fired on this handler.
    ///
    /// - Parameters:
    ///   - expectation: The expectation to store.
    ///   - event: The event name to associate with.
    ///
    /// - Important: Only one expectation can be stored per event name.
    public func add(expectation: Expectation, withEventName event: EventName) {
        handlers[event] = expectation
    }

    /// Fulfills the registered event's expectation and invokes callback.
    ///
    /// If event's event name is registered, then the associated expectation is fulfilled
    /// and the associated callback is invoked with provided parameters,
    /// otherwise the event is ignored.
    ///
    /// - Parameters:
    ///   - event: The event to track.
    ///   - time: The time at which event fired.
    ///   - data: The associated metadata with event.
    public func track<Event: AnalyticsEvent>(
        event: Event,
        at time: Date,
        data: Event.Metadata
    ) where Event.Name == EventName {
        guard let ((expectation, file, _, line), handler) = handlers[event.name]
        else { return }
        expectation.fulfill()
        XCTAssertNoThrow(try handler?(event, data), file: file, line: line)
    }
}
