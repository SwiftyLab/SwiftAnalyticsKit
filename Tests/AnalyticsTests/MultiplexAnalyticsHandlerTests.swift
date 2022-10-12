#if swift(>=5.7)
import XCTest

@testable import Analytics
@testable import AnalyticsMock

final class MultiplexAnalyticsHandlerTests: XCTestCase {

    func testMultiplexHandler() throws {
        guard #available(macOS 13, iOS 16, tvOS 16, watchOS 9, *) else {
            throw XCTSkip("Multiplex handler not available on current platform")
        }

        let actionHandler = AnalyticsSingleExpectationHandler<String>()
        let actionHandler2 = AnalyticsOrderedExpectationHandler<String>()
        let stateHandler = AnalyticsSingleExpectationHandler<String>()
        let actionStateHandler = AnalyticsOrderedExpectationHandler<String>()
        let infoHandler = AnalyticsOrderedExpectationHandler<String>()
        let sensitiveHandler = AnalyticsOrderedExpectationHandler<String>()
        let allHandler = AnalyticsOrderedExpectationHandler<String>()

        var mHandler = MultiplexAnalyticsHandler<String>()
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
            (event: LoginFailureReason.Event, data: LoginFailureReason) in
            XCTAssertEqual(event.group, .action)
            XCTAssertEqual(data.reason, "failed")
        }
        expect(event: "loginFailed", on: actionHandler, evaluate: lfa)
        expect(event: "loginFailed", on: actionHandler2, evaluate: lfa)
        expect(event: "loginFailed", on: actionStateHandler, evaluate: lfa)
        expect(event: "loginFailed", on: allHandler, evaluate: lfa)
        LoginFailureReason(reason: "failed").send(to: mHandler)

        let upa = { (event: UserProfileData.Event, data: UserProfileData) in
            XCTAssertEqual(event.group, .info)
            XCTAssertEqual(data.name, "Some User")
            XCTAssertEqual(data.email, "some@email.com")
        }
        expect(event: "", on: infoHandler, evaluate: upa)
        expect(event: "", on: allHandler, evaluate: upa)
        UserProfileData(name: "Some User", email: "some@email.com").send(
            to: mHandler
        )

        let uia = { (event: UserIdData.Event, data: UserIdData) in
            XCTAssertEqual(event.group, .sensitive)
            XCTAssertEqual(data.id, "some_id")
        }
        expect(event: "", on: sensitiveHandler, evaluate: uia)
        expect(event: "", on: allHandler, evaluate: uia)
        UserIdData(id: "some_id").send(to: mHandler)

        waitForExpectations(timeout: 1)
    }
}
#endif
