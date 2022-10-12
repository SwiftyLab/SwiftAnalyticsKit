import XCTest

/// An expectation type that keeps the count of
/// ``fulfill()`` method invocation.
///
/// Instead of using this type directly use following
/// `XCTestCase` convenience methods:
///
/// - `expect(event:on:file:function:line:evaluate:)`
/// - `expect(event:on:file:function:line:)`
///
/// - Important: Do not invoke `fulfill()` method
///              directly on the expectation value wrapped.
public class AnalyticsExpectation {
    /// Represents current fulfillment state of
    /// ``AnalyticsExpectation``.
    ///
    /// - If expectation is met, state is represented
    ///   by ``fulfilled``.
    /// - If expectation isn't met, state is represented
    ///   by ``unfulfilled``.
    /// - If ``AnalyticsExpectation/fulfill()``
    ///   invocation exceeds ``AnalyticsExpectation/expectedFulfillmentCount``,
    ///   state is represented by ``overfulfilled``.
    public enum FulfillmentState {
        /// Expectation hasn't been met.
        case unfulfilled
        /// Expectation hast been met.
        case fulfilled
        /// Expectation has been met but
        /// the ``AnalyticsExpectation/fulfill()``
        /// invocation exceeds ``AnalyticsExpectation/expectedFulfillmentCount``.
        case overfulfilled
    }

    /// The `XCTestExpectation` value
    /// wrapped by this instance.
    private let base: XCTestExpectation

    /// The number of times ``fulfill()`` must be called
    /// before the expectation is completely fulfilled.
    ///
    /// The value of `expectedFulfillmentCount`
    /// must be greater than `0`. By default, expectations
    /// have an `expectedFulfillmentCount` of `1`.
    ///
    /// - Note: The value of `expectedFulfillmentCount`
    ///         is ignored when ``isInverted`` is `true`.
    public var expectedFulfillmentCount: Int {
        get { base.expectedFulfillmentCount }
        set { base.expectedFulfillmentCount = newValue }
    }

    /// Indicates that an assertion should be triggered
    /// during testing if the expectation is over-fulfilled.
    ///
    /// When `true`, a call to ``fulfill()`` made
    /// after the expectation has already been fulfilled
    /// (exceeding ``expectedFulfillmentCount``)
    /// will trigger an assertion.
    ///
    /// When `false`, a call to ``fulfill()``
    /// after the expectation has already been fulfilled
    /// will have no effect.
    public var assertForOverFulfill: Bool {
        get { base.assertForOverFulfill }
        set { base.assertForOverFulfill = newValue }
    }

    /// Indicates that the expectation is not intended to happen.
    ///
    /// To check that a situation *does not occur* during testing,
    /// create an expectation that is fulfilled when the unexpected
    /// situation occurs, and set its `isInverted` property to true.
    /// Your test will fail immediately if the inverted expectation is fulfilled.
    public var isInverted: Bool {
        get { base.isInverted }
        set { base.isInverted = newValue }
    }

    /// Indicates the number of times ``fulfill()`` has been called.
    ///
    /// By default, this is set to `0` and increased each time ``fulfill()``
    /// invoked. Expectation is completely fulfilled if `currentFulfillmentCount`
    /// meets or exceeds ``expectedFulfillmentCount``.
    public private(set) var currentFulfillmentCount: Int = 0

    /// Represents current fulfillment state of expectation.
    ///
    /// Compares ``currentFulfillmentCount``
    /// with ``expectedFulfillmentCount`` and
    /// calculates ``FulfillmentState``.
    public var state: FulfillmentState {
        switch currentFulfillmentCount - expectedFulfillmentCount {
        case 0: return .fulfilled
        case ..<0: return .unfulfilled
        default: return .overfulfilled
        }
    }

    /// Creates an analytics expectation that wraps the given instance.
    ///
    /// Wraps the provided expectation while exposing methods to
    /// customize its properties and a fulfillment count.
    ///
    /// - Parameter base: An expectation value to wrap.
    /// - Returns: Newly created analytics expectation.
    ///
    /// - Important: Do not invoke `fulfill()` method
    ///              directly on the expectation provided.
    public init(from base: XCTestExpectation) {
        self.base = base
    }

    /// Marks the expectation as having been met.
    ///
    /// It is an error to call this method on an expectation
    /// that has already been fulfilled, or when the test case
    /// that vended the expectation has already completed.
    public func fulfill() {
        currentFulfillmentCount += 1
        base.fulfill()
    }
}
