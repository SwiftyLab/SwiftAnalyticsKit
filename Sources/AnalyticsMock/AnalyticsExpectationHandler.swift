import Analytics
import XCTest

public protocol AnalyticsExpectationHandler: AnalyticsHandler, Initializable {
    /// A type representing an expectation with the expectation location
    /// and optional validation callback.
    typealias Expectation = (
        (AnalyticsExpectation, StaticString, StaticString, UInt),
        ((Any, AnalyticsMetadata) throws -> Void)?
    )
    /// Store expectation to be fulfilled later when analytics event
    /// associated with it is fired on this handler.
    ///
    /// - Parameters:
    ///   - expectation: The expectation to store.
    ///   - event: The event name to associate with.
    func add(expectation: Expectation, withEventName event: EventName)
    /// Registers expectation and callback for provided event name.
    ///
    /// - Parameters:
    ///   - event: The event name to register for.
    ///   - expectation: The test expectation to register.
    ///   - evaluate: The callback to invoke when event fires.
    ///   - file: The file where the registration request occurs.
    ///   - function: The function where the registration request occurs.
    ///   - line: The line where the registration request occurs.
    func register<Event: AnalyticsEvent>(
        event: Event.Name,
        expectation: AnalyticsExpectation,
        evaluate: @escaping (Event, Event.Metadata) throws -> Void,
        file: StaticString,
        function: StaticString,
        line: UInt
    ) where Event.Name == EventName
    /// Registers expectation for provided event name.
    ///
    /// - Parameters:
    ///   - event: The event name to register for.
    ///   - expectation: The test expectation to register.
    ///   - file: The file where the registration request occurs.
    ///   - function: The function where the registration request occurs.
    ///   - line: The line where the registration request occurs.
    func register(
        event: EventName,
        expectation: AnalyticsExpectation,
        file: StaticString,
        function: StaticString,
        line: UInt
    )
}

public extension AnalyticsExpectationHandler {
    /// Registers expectation and callback for provided event name.
    ///
    /// Invokes ``add(expectation:withEventName:)``
    /// to store the expectation to be fulfilled later.
    ///
    /// - Parameters:
    ///   - event: The event name to register for.
    ///   - expectation: The test expectation to register.
    ///   - evaluate: The callback to invoke when event fires.
    ///   - file: The file where the registration request occurs.
    ///   - function: The function where the registration request occurs.
    ///   - line: The line where the registration request occurs.
    func register<Event: AnalyticsEvent>(
        event: Event.Name,
        expectation: AnalyticsExpectation,
        evaluate: @escaping (Event, Event.Metadata) throws -> Void,
        file: StaticString,
        function: StaticString,
        line: UInt
    ) where Event.Name == EventName {
        let exp: Expectation = (
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
                try evaluate(event, data)
            }
        )
        add(expectation: exp, withEventName: event)
    }
    /// Registers expectation for provided event name.
    ///
    /// Invokes ``add(expectation:withEventName:)``
    /// to store the expectation to be fulfilled later.
    ///
    /// - Parameters:
    ///   - event: The event name to register for.
    ///   - expectation: The test expectation to register.
    ///   - file: The file where the registration request occurs.
    ///   - function: The function where the registration request occurs.
    ///   - line: The line where the registration request occurs.
    func register(
        event: EventName,
        expectation: AnalyticsExpectation,
        file: StaticString,
        function: StaticString,
        line: UInt
    ) {
        let exp: Expectation = ((expectation, file, function, line), nil)
        add(expectation: exp, withEventName: event)
    }
}

public extension AnalyticsExpectationHandler
where Self: Hashable, Self: AnyObject {
    /// Returns a Boolean value indicating whether
    /// two instances are the same.
    ///
    /// - Parameters:
    ///   - lhs: An `AnalyticsOrderedExpectationHandler` instance.
    ///   - rhs: Another `AnalyticsOrderedExpectationHandler` instance.
    ///
    /// - Returns: Whether two instances are the same.
    static func == (lhs: Self, rhs: Self) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
    /// Hashes the current instance by feeding an unique identifier
    /// associated into the given hasher.
    ///
    /// - Parameter hasher: The hasher to use when combining
    ///                     the components of this instance.
    func hash(into hasher: inout Hasher) {
        ObjectIdentifier(self).hash(into: &hasher)
    }
}

public extension XCTestCase {
    /// Creates a new expectation for the provided event name on the provided handler.
    ///
    /// Use this method to create `XCTestExpectation` instances that is fulfilled when event
    /// with provided name is fired on the provided ``AnalyticsExpectationHandler``
    /// type and the provided callback is also invoked with passed parameters.
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
    ///
    /// - Returns: The created test expectation.
    @discardableResult
    func expect<Event: AnalyticsEvent, Handler: AnalyticsExpectationHandler>(
        event: Event.Name,
        on handler: Handler,
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line,
        evaluate: @escaping (Event, Event.Metadata) throws -> Void
    ) -> AnalyticsExpectation where Handler.EventName == Event.Name {
        let expectation = AnalyticsExpectation(
            from: self.expectation(description: "\(event)")
        )
        expectation.assertForOverFulfill = false
        handler.register(
            event: event,
            expectation: expectation,
            evaluate: evaluate,
            file: file,
            function: function,
            line: line
        )
        return expectation
    }
    /// Creates a new expectation for the provided event name on the provided handler.
    ///
    /// Use this method to create `XCTestExpectation` instances that is fulfilled when event
    /// with provided name is fired on the provided ``AnalyticsExpectationHandler``
    /// type and the provided callback is also invoked with passed parameters.
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
    ///
    /// - Returns: The created test expectation.
    @discardableResult
    func expect<EventName: Hashable, Handler: AnalyticsExpectationHandler>(
        event: EventName,
        on handler: Handler,
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line
    ) -> AnalyticsExpectation where Handler.EventName == EventName {
        let expectation = AnalyticsExpectation(
            from: self.expectation(description: "\(event)")
        )
        expectation.assertForOverFulfill = false
        handler.register(
            event: event,
            expectation: expectation,
            file: file,
            function: function,
            line: line
        )
        return expectation
    }
}
