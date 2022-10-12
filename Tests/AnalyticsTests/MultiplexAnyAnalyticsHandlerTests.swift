import XCTest

@testable import Analytics
@testable import AnalyticsMock

final class MultiplexAnyAnalyticsHandlerTests: XCTestCase {

    func testMultiplexHandler() throws {
        let actionHandler = AnalyticsSingleExpectationHandler<String>()
        let actionHandler2 = AnalyticsOrderedExpectationHandler<String>()
        let stateHandler = AnalyticsSingleExpectationHandler<String>()
        let actionStateHandler = AnalyticsOrderedExpectationHandler<String>()
        let infoHandler = AnalyticsOrderedExpectationHandler<String>()
        let sensitiveHandler = AnalyticsOrderedExpectationHandler<String>()
        let allHandler = AnalyticsOrderedExpectationHandler<String>()

        var mHandler = MultiplexAnyAnalyticsHandler<String>()
        mHandler.register(handler: actionHandler, for: .action)
        mHandler.register(handler: actionHandler2, for: .action)
        mHandler.register(handler: stateHandler, for: .state)
        mHandler.register(handler: actionStateHandler, for: .action)
        mHandler.register(handler: actionStateHandler, for: .state)
        mHandler.register(handler: infoHandler, for: .info)
        mHandler.register(handler: sensitiveHandler, for: .sensitive)
        mHandler.register(handler: allHandler, for: .defaultGroups)

        expect(event: "loginScreenViewed", on: stateHandler)
        expect(event: "loginScreenViewed", on: actionStateHandler)
        expect(event: "loginScreenViewed", on: allHandler)
        LoginEvent.loginScreenViewed.fire(on: mHandler)

        expect(event: "loginAttempted", on: actionHandler)
        expect(event: "loginAttempted", on: actionHandler2)
        expect(event: "loginAttempted", on: actionStateHandler)
        expect(event: "loginAttempted", on: allHandler)
        LoginEvent.loginAttempted.fire(on: mHandler)

        let lfa = {
            (event: AnyStringAnalyticsEvent, data: AnyMetadata) in
            XCTAssertEqual(event.group, .action)
            let data = try XCTUnwrap(data.value as? LoginFailureReason)
            XCTAssertEqual(data.reason, "failed")
        }
        expect(event: "loginFailed", on: actionHandler, evaluate: lfa)
        expect(event: "loginFailed", on: actionHandler2, evaluate: lfa)
        expect(event: "loginFailed", on: actionStateHandler, evaluate: lfa)
        expect(event: "loginFailed", on: allHandler, evaluate: lfa)
        LoginFailureReason(reason: "failed").send(to: mHandler)

        let upa = { (event: AnyStringAnalyticsEvent, data: AnyMetadata) in
            XCTAssertEqual(event.group, .info)
            let data = try XCTUnwrap(data.value as? UserProfileData)
            XCTAssertEqual(data.name, "Some User")
            XCTAssertEqual(data.email, "some@email.com")
        }
        expect(event: "", on: infoHandler, evaluate: upa)
        expect(event: "", on: allHandler, evaluate: upa)
        UserProfileData(name: "Some User", email: "some@email.com").send(
            to: mHandler
        )

        let uia = { (event: AnyStringAnalyticsEvent, data: AnyMetadata) in
            XCTAssertEqual(event.group, .sensitive)
            let data = try XCTUnwrap(data.value as? UserIdData)
            XCTAssertEqual(data.id, "some_id")
        }
        expect(event: "", on: sensitiveHandler, evaluate: uia)
        expect(event: "", on: allHandler, evaluate: uia)
        UserIdData(id: "some_id").send(to: mHandler)

        waitForExpectations(timeout: 1)
    }
}
