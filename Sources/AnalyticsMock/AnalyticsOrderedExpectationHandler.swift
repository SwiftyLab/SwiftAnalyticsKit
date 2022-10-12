import Analytics
import XCTest

/// An `AnalyticsHandler` that tracks expected events by their name and order.
///
/// Use this type to check if analytics events with specified name have been fired with the order
/// in which they are added as part of the test. Use the `XCTestCase` extension methods
/// to register expectation of an analytics event with optional callback for validation.
///
/// Each expectation is fulfilled and callback is invoked when the associated event is fired.
/// Multiple expectations can be registered for a single event name which are then fulfilled
/// by the order they are added.
///
/// If the registered event names aren't tracked by this handler, then test is failed with unfulfilled expectations.
/// If the expected event and metadata type don't match or any assertions failed in provided callback,
/// then also test is failed.
public final class AnalyticsOrderedExpectationHandler<
    EventName: Hashable
>: AnalyticsExpectationHandler, Hashable {
    /// All the event expectations registered.
    private var handlers: [EventName: [Expectation]] = [:]

    /// Creates a new instance of handler.
    public init() {}

    /// Store expectation to be fulfilled later when analytics event
    /// associated with it is fired on this handler.
    ///
    /// Expectations are fulfilled in the order of their registration.
    ///
    /// - Parameters:
    ///   - expectation: The expectation to store.
    ///   - event: The event name to associate with.
    public func add(expectation: Expectation, withEventName event: EventName) {
        if handlers[event] != nil {
            handlers[event]!.append(expectation)
        } else {
            handlers[event] = [expectation]
        }
    }

    /// Fulfills the registered event's oldest expectation and invokes callback.
    ///
    /// If event's event name is registered, then the first associated expectation is fulfilled
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
        guard
            let (
                (expectation, file, _, line), handler
            ) = handlers[event.name]?.first
        else { return }
        XCTAssertNoThrow(try handler?(event, data), file: file, line: line)
        expectation.fulfill()
        switch expectation.state {
        case .fulfilled where !expectation.assertForOverFulfill: break
        case .overfulfilled: break
        default: return
        }
        handlers[event.name]!.removeFirst()
    }
}
