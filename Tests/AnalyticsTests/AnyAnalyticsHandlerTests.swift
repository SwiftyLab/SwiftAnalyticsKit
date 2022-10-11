import XCTest

@testable import Analytics
@testable import AnalyticsMock

final class AnyAnalyticsHandlerTests: XCTestCase {

    func testEventPropagationWithoutMetadata() throws {
        let handler = AnalyticsExpectationHandler<String>()
        expect(event: "loginScreenViewed", on: handler) {
            (event: AnyAnalyticsEvent, data: AnyMetadata) in
            XCTAssertEqual(event.group, .state)
        }
        expect(event: "loginAttempted", on: handler) {
            (event: AnyAnalyticsEvent, data: AnyMetadata) in
            XCTAssertEqual(event.group, .action)
        }
        expect(event: "loginSucceeded", on: handler) {
            (event: AnyAnalyticsEvent, data: AnyMetadata) in
            XCTAssertEqual(event.group, .action)
        }

        let erasedHandler = AnyAnalyticsHandler(with: handler)
        LoginEvent.loginScreenViewed.fire(on: erasedHandler)
        LoginEvent.loginAttempted.fire(on: erasedHandler)
        LoginEvent.loginSucceeded.fire(on: erasedHandler)
        waitForExpectations(timeout: 1)
    }

    func testEventPropagationWithMetadata() throws {
        let handler = AnalyticsExpectationHandler<String>()
        expect(event: "loginFailed", on: handler) {
            (event: AnyAnalyticsEvent, data: AnyMetadata) in
            XCTAssertEqual(event.group, .action)
            let data = try XCTUnwrap(data.value as? LoginFailureReason)
            XCTAssertEqual(data.reason, "failed")
        }
        expect(event: "messageSelected", on: handler) {
            (event: AnyAnalyticsEvent, data: AnyMetadata) in
            XCTAssertEqual(event.group, .action)
            let data = try XCTUnwrap(data.value as? MessageSelected)
            XCTAssertEqual(data.index, 10)
        }
        expect(event: "messageDeleted", on: handler) {
            (event: AnyAnalyticsEvent, data: AnyMetadata) in
            XCTAssertEqual(event.group, .action)
            let data = try XCTUnwrap(data.value as? MessageDeleted)
            XCTAssertEqual(data.index, 10)
            XCTAssertTrue(data.read)
        }

        let erasedHandler = AnyAnalyticsHandler(with: handler)
        LoginFailureReason(reason: "failed").send(to: erasedHandler)
        MessageSelected(index: 10).send(to: erasedHandler)
        MessageDeleted(index: 10, read: true).send(to: erasedHandler)
        waitForExpectations(timeout: 1)
    }
}
