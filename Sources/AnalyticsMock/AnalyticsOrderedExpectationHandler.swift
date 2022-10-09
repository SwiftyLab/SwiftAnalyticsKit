import XCTest

@testable import Analytics

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
>: AnalyticsHandler {
    /// All the event expectations registered.
    private var handlers: [EventName: [Expectation]] = [:]
    /// A type representing an expectation with the expectation location
    /// and optional validation callback.
    fileprivate typealias Expectation = (
        (XCTestExpectation, StaticString, StaticString, UInt),
        ((Any, Encodable) throws -> Void)?
    )

    /// Creates a new instance of handler.
    public init() {}

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
        guard !(handlers[event.name]?.isEmpty ?? true) else { return }
        let ((expectation, file, _, line), handler) = handlers[event.name]!
            .removeFirst()
        XCTAssertNoThrow(try handler?(event, data), file: file, line: line)
        expectation.fulfill()
    }

    /// Registers expectation and callback for provided event name.
    ///
    /// - Parameters:
    ///   - event: The event name to register for.
    ///   - expectation: The test expectation to register.
    ///   - evaluate: The callback to invoke when event fires.
    ///   - file: The file where the registration request occurs.
    ///   - function: The function where the registration request occurs.
    ///   - line: The line where the registration request occurs.
    fileprivate func register<Event: AnalyticsEvent>(
        event: Event.Name,
        expectation: XCTestExpectation,
        evaluate: @escaping (Event, Event.Metadata) -> Void,
        file: StaticString,
        function: StaticString,
        line: UInt
    ) where Event.Name == EventName {
        let newHandling: Expectation = (
            (expectation, file, function, line),
            { event, data in
                let event = try XCTUnwrap(
                    event as? Event,
                    "Expected event type \(Event.self) but received \(type(of: event))",
                    file: file, line: line
                )
                let data = try XCTUnwrap(
                    data as? Event.Metadata,
                    file: file, line: line
                )
                evaluate(event, data)
            }
        )
        if handlers[event] != nil {
            handlers[event]!.append(newHandling)
        } else {
            handlers[event] = [newHandling]
        }
    }

    /// Registers expectation for provided event name.
    ///
    /// - Parameters:
    ///   - event: The event name to register for.
    ///   - expectation: The test expectation to register.
    ///   - file: The file where the registration request occurs.
    ///   - function: The function where the registration request occurs.
    ///   - line: The line where the registration request occurs.
    fileprivate func register(
        event: EventName,
        expectation: XCTestExpectation,
        file: StaticString,
        function: StaticString,
        line: UInt
    ) {
        let newHandling: Expectation = (
            (expectation, file, function, line), nil
        )
        if handlers[event] != nil {
            handlers[event]!.append(newHandling)
        } else {
            handlers[event] = [newHandling]
        }
    }
}

public extension XCTestCase {
    /// Creates a new expectation for the provided event name on the provided handler.
    ///
    /// Use this method to create `XCTestExpectation` instances that is fulfilled when event
    /// with provided name is fired on the provided ``AnalyticsOrderedExpectationHandler``
    /// and the provided callback is also invoked with passed parameters.
    ///
    /// - Parameters:
    ///   - event: The name of the event to expect.
    ///   - handler: The handler on which expectation registered.
    ///   - file: The file name to use in the error message if
    ///           this expectation is not waited for. Default is the file
    ///           containing the call to this method. It is rare to provide this
    ///           parameter when calling this method.
    ///   - function: The function name to use in the error message if
    ///               this expectation is not waited for. Default is the file
    ///               containing the call to this method. It is rare to provide this
    ///               parameter when calling this method.
    ///   - line: The line name to use in the error message if
    ///           this expectation is not waited for. Default is the file
    ///           containing the call to this method. It is rare to provide this
    ///           parameter when calling this method.
    ///   - evaluate: The callback invoked when expectation is fulfilled.
    func expect<Event: AnalyticsEvent>(
        event: Event.Name,
        on handler: AnalyticsOrderedExpectationHandler<Event.Name>,
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line,
        evaluate: @escaping (Event, Event.Metadata) -> Void
    ) {
        let expectation = self.expectation(description: "\(event)")
        handler.register(
            event: event,
            expectation: expectation,
            evaluate: evaluate,
            file: file,
            function: function,
            line: line
        )
    }

    /// Creates a new expectation for the provided event name on the provided handler.
    ///
    /// Use this method to create `XCTestExpectation` instances that is fulfilled when event
    /// with provided name is fired on the provided ``AnalyticsOrderedExpectationHandler``
    /// and the provided callback is also invoked with passed parameters.
    ///
    /// - Parameters:
    ///   - event: The name of the event to expect.
    ///   - handler: The handler on which expectation registered.
    ///   - file: The file name to use in the error message if
    ///           this expectation is not waited for. Default is the file
    ///           containing the call to this method. It is rare to provide this
    ///           parameter when calling this method.
    ///   - function: The function name to use in the error message if
    ///               this expectation is not waited for. Default is the file
    ///               containing the call to this method. It is rare to provide this
    ///               parameter when calling this method.
    ///   - line: The line name to use in the error message if
    ///           this expectation is not waited for. Default is the file
    ///           containing the call to this method. It is rare to provide this
    ///           parameter when calling this method.
    func expect<EventName: Hashable>(
        event: EventName,
        on handler: AnalyticsOrderedExpectationHandler<EventName>,
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line
    ) {
        let expectation = self.expectation(description: "\(event)")
        handler.register(
            event: event,
            expectation: expectation,
            file: file,
            function: function,
            line: line
        )
    }
}
