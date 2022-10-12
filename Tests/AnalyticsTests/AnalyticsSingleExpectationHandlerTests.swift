import XCTest

@testable import Analytics
@testable import AnalyticsMock

final class AnalyticsSingleExpectationHandlerTests: XCTestCase {

    func testExpectationFulfillWithoutCallback() throws {
        let handler = AnalyticsSingleExpectationHandler<String>()
        expect(event: "loginScreenViewed", on: handler)
        LoginEvent.loginScreenViewed.fire(on: handler)
        LoginEvent.loginAttempted.fire(on: handler)
        LoginEvent.loginSucceeded.fire(on: handler)
        waitForExpectations(timeout: 1)
    }

    func testExpectationFulfillWithCallback() throws {
        let handler = AnalyticsSingleExpectationHandler<String>()
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

    func testExpectationMultiFulfillWithoutCallback() throws {
        let handler = AnalyticsSingleExpectationHandler<String>()
        let exp = expect(event: "loginScreenViewed", on: handler)
        exp.expectedFulfillmentCount = 3
        LoginEvent.loginScreenViewed.fire(on: handler)
        LoginEvent.loginScreenViewed.fire(on: handler)
        LoginEvent.loginScreenViewed.fire(on: handler)
        waitForExpectations(timeout: 1)
    }

    func testExpectationMultiFulfillWithCallback() throws {
        let handler = AnalyticsSingleExpectationHandler<String>()
        let exp = expect(event: "loginFailed", on: handler) {
            (event: LoginFailureReason.Event, data: LoginFailureReason) in
            XCTAssertEqual(event.group, .action)
            XCTAssertEqual(data.reason, "failed")
        }

        exp.expectedFulfillmentCount = 3
        LoginFailureReason(reason: "failed").send(to: handler)
        LoginFailureReason(reason: "failed").send(to: handler)
        LoginFailureReason(reason: "failed").send(to: handler)
        waitForExpectations(timeout: 1)
    }

    func testInvertExpectationFulfillWithoutCallback() throws {
        let handler = AnalyticsSingleExpectationHandler<String>()
        let exp = expect(event: "loginAttempted", on: handler)
        exp.isInverted = true
        LoginEvent.loginScreenViewed.fire(on: handler)
        waitForExpectations(timeout: 1)
    }

    func testInvertExpectationFulfillWithCallback() throws {
        let handler = AnalyticsSingleExpectationHandler<String>()
        let exp = expect(event: "messageSelected", on: handler) {
            (event: MessageSelected.Event, data: MessageSelected) in
            XCTAssertEqual(event.group, .action)
            XCTAssertEqual(data.index, 10)
        }

        exp.isInverted = true
        LoginFailureReason(reason: "failed").send(to: handler)
        waitForExpectations(timeout: 1)
    }

    // Assert overfulfill bug-fix: https://github.com/apple/swift-corelibs-xctest/issues/351
    // Swift 5.4 release: https://github.com/apple/swift-corelibs-xctest/commits/swift-5.4-RELEASE
    #if (!os(Linux) && !os(Windows)) || swift(>=5.4)
    func testExpectationOverFulfillWithoutCallback() throws {
        let handler = AnalyticsSingleExpectationHandler<String>()
        let exp = expect(event: "loginScreenViewed", on: handler)
        exp.assertForOverFulfill = false
        LoginEvent.loginScreenViewed.fire(on: handler)
        LoginEvent.loginScreenViewed.fire(on: handler)
        LoginEvent.loginScreenViewed.fire(on: handler)
        waitForExpectations(timeout: 1)
    }

    func testExpectationOverFulfillWithCallback() throws {
        let handler = AnalyticsSingleExpectationHandler<String>()
        let exp = expect(event: "loginFailed", on: handler) {
            (event: LoginFailureReason.Event, data: LoginFailureReason) in
            XCTAssertEqual(event.group, .action)
            XCTAssertEqual(data.reason, "failed")
        }

        exp.assertForOverFulfill = false
        LoginFailureReason(reason: "failed").send(to: handler)
        LoginFailureReason(reason: "failed").send(to: handler)
        LoginFailureReason(reason: "failed").send(to: handler)
        waitForExpectations(timeout: 1)
    }
    #endif

    #if !os(Linux) && !os(Windows)
    func testExpectationFailWithoutCallback() throws {
        XCTExpectFailure("Fails due to expectation unfulfilled")
        let handler = AnalyticsSingleExpectationHandler<String>()
        expect(event: "loginScreenViewed", on: handler)
        waitForExpectations(timeout: 1)
    }

    func testExpectationFailWithCallback() throws {
        XCTExpectFailure("Fails due to expectation unfulfilled")
        let handler = AnalyticsSingleExpectationHandler<String>()
        expect(event: "loginFailed", on: handler) {
            (_: LoginFailureReason.Event, _: LoginFailureReason) in
        }
        waitForExpectations(timeout: 1)
    }

    func testCallbackTypeMismatchFail() throws {
        XCTExpectFailure("Fails due to type mismatch in callback")
        let handler = AnalyticsSingleExpectationHandler<String>()
        expect(event: "messageSelected", on: handler) {
            (_: LoginFailureReason.Event, _: LoginFailureReason) in
        }
        MessageSelected(index: 10).send(to: handler)
        waitForExpectations(timeout: 1)
    }

    func testCallbackAssertionFail() throws {
        XCTExpectFailure("Fails due to assertion failure in callback")
        let handler = AnalyticsSingleExpectationHandler<String>()
        expect(event: "loginFailed", on: handler) {
            (event: LoginFailureReason.Event, data: LoginFailureReason) in
            XCTAssertEqual(event.group, .info)
            XCTAssertEqual(data.reason, "")
        }
        LoginFailureReason(reason: "failed").send(to: handler)
        waitForExpectations(timeout: 1)
    }

    func testCallbackErrorThrownFail() throws {
        XCTExpectFailure("Fails due to error thrown in callback")
        let handler = AnalyticsSingleExpectationHandler<String>()
        expect(event: "loginFailed", on: handler) {
            (event: LoginFailureReason.Event, data: LoginFailureReason) in
            let _ = try XCTUnwrap(Int(data.reason))
        }
        LoginFailureReason(reason: "failed").send(to: handler)
        waitForExpectations(timeout: 1)
    }

    func testExpectationMultiFulfillFailWithoutCallback() throws {
        XCTExpectFailure("Fails due to expectation under fulfilled")
        let handler = AnalyticsSingleExpectationHandler<String>()
        let exp = expect(event: "loginScreenViewed", on: handler)
        exp.expectedFulfillmentCount = 3
        LoginEvent.loginScreenViewed.fire(on: handler)
        waitForExpectations(timeout: 1)
    }

    func testExpectationMultiFulfillFailWithCallback() throws {
        XCTExpectFailure("Fails due to expectation under fulfilled")
        let handler = AnalyticsSingleExpectationHandler<String>()
        let exp = expect(event: "loginFailed", on: handler) {
            (event: LoginFailureReason.Event, data: LoginFailureReason) in
            XCTAssertEqual(event.group, .action)
            XCTAssertEqual(data.reason, "failed")
        }

        exp.expectedFulfillmentCount = 3
        LoginFailureReason(reason: "failed").send(to: handler)
        waitForExpectations(timeout: 1)
    }

    func testExpectationOverFulfillFailWithoutCallback() throws {
        XCTExpectFailure("Fails due to expectation over fulfilled")
        let handler = AnalyticsSingleExpectationHandler<String>()
        let exp = expect(event: "loginScreenViewed", on: handler)
        exp.assertForOverFulfill = true
        LoginEvent.loginScreenViewed.fire(on: handler)
        LoginEvent.loginScreenViewed.fire(on: handler)
        LoginEvent.loginScreenViewed.fire(on: handler)
        waitForExpectations(timeout: 1)
    }

    func testExpectationOverFulfillFailWithCallback() throws {
        XCTExpectFailure("Fails due to expectation over fulfilled")
        let handler = AnalyticsSingleExpectationHandler<String>()
        let exp = expect(event: "loginFailed", on: handler) {
            (event: LoginFailureReason.Event, data: LoginFailureReason) in
            XCTAssertEqual(event.group, .action)
            XCTAssertEqual(data.reason, "failed")
        }

        exp.assertForOverFulfill = true
        LoginFailureReason(reason: "failed").send(to: handler)
        LoginFailureReason(reason: "failed").send(to: handler)
        LoginFailureReason(reason: "failed").send(to: handler)
        waitForExpectations(timeout: 1)
    }

    func testInvertExpectationFulfillFailWithoutCallback() throws {
        XCTExpectFailure("Fails due to inverted expectation fulfilled")
        let handler = AnalyticsSingleExpectationHandler<String>()
        let exp = expect(event: "loginAttempted", on: handler)
        exp.isInverted = true
        LoginEvent.loginAttempted.fire(on: handler)
        waitForExpectations(timeout: 1)
    }

    func testInvertExpectationFulfillFailWithCallback() throws {
        XCTExpectFailure("Fails due to inverted expectation fulfilled")
        let handler = AnalyticsSingleExpectationHandler<String>()
        let exp = expect(event: "messageSelected", on: handler) {
            (event: MessageSelected.Event, data: MessageSelected) in
            XCTAssertEqual(event.group, .action)
            XCTAssertEqual(data.index, 10)
        }

        exp.isInverted = true
        MessageSelected(index: 10).send(to: handler)
        waitForExpectations(timeout: 1)
    }
    #endif
}
