import XCTest

@testable import Analytics
@testable import AnalyticsMock

final class AnalyticsOrderedExpectationHandlerTests: XCTestCase {

    func testExpectationFulfillWithoutCallback() throws {
        let handler = AnalyticsOrderedExpectationHandler<String>()
        expect(event: "loginScreenViewed", on: handler)
        LoginEvent.loginScreenViewed.fire(on: handler)
        LoginEvent.loginAttempted.fire(on: handler)
        LoginEvent.loginSucceeded.fire(on: handler)
        waitForExpectations(timeout: 1)
    }

    func testExpectationFulfillWithCallback() throws {
        let handler = AnalyticsOrderedExpectationHandler<String>()
        expect(event: "loginFailed", on: handler) {
            (event: LoginFailureReason.Event, data: LoginFailureReason) in
            XCTAssertEqual(event.group, .action)
            XCTAssertEqual(data.reason, "failed")
        }

        LoginFailureReason(reason: "failed").send(to: handler)
        MessageSelected(index: 10).send(to: handler)
        MessageDeleted(index: 10, read: true).send(to: handler)
        waitForExpectations(timeout: 1)
    }

    func testExpectationFailWithoutCallback() throws {
        XCTExpectFailure("Fails due to expectation unfulfilled")
        let handler = AnalyticsOrderedExpectationHandler<String>()
        expect(event: "loginScreenViewed", on: handler)
        waitForExpectations(timeout: 1)
    }

    func testExpectationFailWithCallback() throws {
        XCTExpectFailure("Fails due to expectation unfulfilled")
        let handler = AnalyticsOrderedExpectationHandler<String>()
        expect(event: "loginFailed", on: handler) {
            (_: LoginFailureReason.Event, _: LoginFailureReason) in
        }
        waitForExpectations(timeout: 1)
    }

    func testCallbackTypeMismatchFail() throws {
        XCTExpectFailure("Fails due to type mismatch in callback")
        let handler = AnalyticsOrderedExpectationHandler<String>()
        expect(event: "messageSelected", on: handler) {
            (_: LoginFailureReason.Event, _: LoginFailureReason) in
        }
        MessageSelected(index: 10).send(to: handler)
        waitForExpectations(timeout: 1)
    }

    func testCallbackAssertionFail() throws {
        XCTExpectFailure("Fails due to assertion failure in callback")
        let handler = AnalyticsOrderedExpectationHandler<String>()
        expect(event: "loginFailed", on: handler) {
            (event: LoginFailureReason.Event, data: LoginFailureReason) in
            XCTAssertEqual(event.group, .info)
            XCTAssertEqual(data.reason, "")
        }
        LoginFailureReason(reason: "failed").send(to: handler)
        waitForExpectations(timeout: 1)
    }

    func testMultiExpectationFulfillWithoutCallback() throws {
        let handler = AnalyticsOrderedExpectationHandler<String>()
        for _ in 0..<3 { expect(event: "loginScreenViewed", on: handler) }
        for _ in 0..<3 { LoginEvent.loginScreenViewed.fire(on: handler) }
        LoginEvent.loginAttempted.fire(on: handler)
        LoginEvent.loginSucceeded.fire(on: handler)
        waitForExpectations(timeout: 1)
    }

    func testMultiExpectationFulfillWithCallback() throws {
        let handler = AnalyticsOrderedExpectationHandler<String>()
        for i in 0..<3 {
            expect(event: "loginFailed", on: handler) {
                (event: LoginFailureReason.Event, data: LoginFailureReason) in
                XCTAssertEqual(event.group, .action)
                XCTAssertEqual(data.reason, "failed \(i)")
            }
        }

        for i in 0..<3 {
            LoginFailureReason(reason: "failed \(i)").send(to: handler)
        }

        MessageSelected(index: 10).send(to: handler)
        MessageDeleted(index: 10, read: true).send(to: handler)
        waitForExpectations(timeout: 1)
    }

    func testMultiExpectationFulfillFailWithoutCallback() throws {
        XCTExpectFailure("Fails due to expectation unfulfilled")
        let handler = AnalyticsOrderedExpectationHandler<String>()
        for _ in 0..<3 { expect(event: "loginScreenViewed", on: handler) }
        for _ in 0..<2 { LoginEvent.loginScreenViewed.fire(on: handler) }
        LoginEvent.loginAttempted.fire(on: handler)
        LoginEvent.loginSucceeded.fire(on: handler)
        waitForExpectations(timeout: 1)
    }

    func testMultiExpectationFulfillFailWithCallback() throws {
        XCTExpectFailure("Fails due to expectation unfulfilled")
        let handler = AnalyticsOrderedExpectationHandler<String>()
        for i in 0..<3 {
            expect(event: "loginFailed", on: handler) {
                (event: LoginFailureReason.Event, data: LoginFailureReason) in
                XCTAssertEqual(event.group, .action)
                XCTAssertEqual(data.reason, "failed \(i)")
            }
        }

        for i in 0..<2 {
            LoginFailureReason(reason: "failed \(i)").send(to: handler)
        }

        MessageSelected(index: 10).send(to: handler)
        MessageDeleted(index: 10, read: true).send(to: handler)
        waitForExpectations(timeout: 1)
    }
}
