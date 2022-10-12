import XCTest

@testable import Analytics
@testable import AnalyticsMock

final class AnalyticsEventTests: XCTestCase {

    func testEventFire() throws {
        let handler = AnalyticsSingleExpectationHandler<String>()
        expect(event: "loginScreenViewed", on: handler) {
            (event: LoginEvent, data: LoginEvent.Metadata) in
            XCTAssertEqual(event.group, .state)
        }
        expect(event: "loginAttempted", on: handler) {
            (event: LoginEvent, data: LoginEvent.Metadata) in
            XCTAssertEqual(event.group, .action)
        }
        expect(event: "loginSucceeded", on: handler) {
            (event: LoginEvent, data: LoginEvent.Metadata) in
            XCTAssertEqual(event.group, .action)
        }
        LoginEvent.loginScreenViewed.fire(on: handler)
        LoginEvent.loginAttempted.fire(on: handler)
        LoginEvent.loginSucceeded.fire(on: handler)
        waitForExpectations(timeout: 1)
    }

    func testEventFireWithMetadata() throws {
        let handler = AnalyticsSingleExpectationHandler<String>()
        expect(event: "loginFailed", on: handler) {
            (event: LoginFailureReason.Event, data: LoginFailureReason) in
            XCTAssertEqual(event.group, .action)
            XCTAssertEqual(data.reason, "failed")
        }
        expect(event: "messageSelected", on: handler) {
            (event: MessageSelected.Event, data: MessageSelected) in
            XCTAssertEqual(event.group, .action)
            XCTAssertEqual(data.index, 10)
        }
        expect(event: "messageDeleted", on: handler) {
            (event: MessageDeleted.Event, data: MessageDeleted) in
            XCTAssertEqual(event.group, .action)
            XCTAssertEqual(data.index, 10)
            XCTAssertTrue(data.read)
        }

        LoginFailureReason(reason: "failed").send(to: handler)
        MessageSelected(index: 10).send(to: handler)
        MessageDeleted(index: 10, read: true).send(to: handler)
        waitForExpectations(timeout: 1)
    }

    func testUserSpecificEvents() {
        let handler = AnalyticsOrderedExpectationHandler<String>()
        expect(event: "", on: handler) {
            (event: UserProfileData.Event, data: UserProfileData) in
            XCTAssertEqual(event.group, .info)
            XCTAssertEqual(data.name, "Some User")
            XCTAssertEqual(data.email, "some@email.com")
        }
        expect(event: "", on: handler) {
            (event: UserIdData.Event, data: UserIdData) in
            XCTAssertEqual(event.group, .sensitive)
            XCTAssertEqual(data.id, "some_id")
        }
        UserProfileData(
            name: "Some User",
            email: "some@email.com"
        ).send(to: handler)
        UserIdData(id: "some_id").send(to: handler)
        waitForExpectations(timeout: 1)
    }
}
