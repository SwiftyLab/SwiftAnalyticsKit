import XCTest

@testable import Analytics
@testable import AnalyticsMock

final class AnyAnalyticsEventTests: XCTestCase {

    func testEventCast() throws {
        let lsvEvent = AnyAnalyticsEvent(from: LoginEvent.loginScreenViewed)
        XCTAssertEqual(lsvEvent.name, "loginScreenViewed")
        XCTAssertEqual(lsvEvent.group, .state)
        XCTAssertNotNil(lsvEvent.configuration as? DefaultConfiguration)

        let laEvent = AnyAnalyticsEvent(
            from: LoginEvent.loginAttempted,
            configuration: RandomConfiguration()
        )
        XCTAssertEqual(laEvent.name, "loginAttempted")
        XCTAssertEqual(laEvent.group, .action)
        XCTAssertNotNil(laEvent.configuration as? RandomConfiguration)
    }

    func testEventGroupTransfer() throws {
        let lsvEvent = AnyAnalyticsEvent(
            from: LoginEvent.loginScreenViewed,
            transferredTo: .action
        )
        XCTAssertEqual(lsvEvent.name, "loginScreenViewed")
        XCTAssertEqual(lsvEvent.group, .action)
        XCTAssertNotNil(lsvEvent.configuration as? DefaultConfiguration)

        let laEvent = AnyAnalyticsEvent(
            from: LoginEvent.loginAttempted,
            transferredTo: .action,
            configuration: RandomConfiguration()
        )
        XCTAssertEqual(laEvent.name, "loginAttempted")
        XCTAssertEqual(laEvent.group, .action)
        XCTAssertNotNil(laEvent.configuration as? RandomConfiguration)
    }

    func testEventGroupAppend() throws {
        let lsvEvent = AnyAnalyticsEvent(
            from: LoginEvent.loginScreenViewed,
            appending: .action
        )
        XCTAssertEqual(lsvEvent.name, "loginScreenViewed")
        XCTAssertEqual(lsvEvent.group, [.action, .state])
        XCTAssertNotNil(lsvEvent.configuration as? DefaultConfiguration)

        let laEvent = AnyAnalyticsEvent(
            from: LoginEvent.loginAttempted,
            appending: .action,
            configuration: RandomConfiguration()
        )
        XCTAssertEqual(laEvent.name, "loginAttempted")
        XCTAssertEqual(lsvEvent.group, [.action, .state])
        XCTAssertNotNil(laEvent.configuration as? RandomConfiguration)
    }

    func testTrackingAnyMetadata() throws {
        let data = LoginFailureReason(reason: "failed")
        let event = AnyAnalyticsEvent(from: data.event)
        print(event.name)
        let handler = AnalyticsExpectationHandler<String>()
        expect(event: "loginFailed", on: handler) {
            (event: AnyAnalyticsEvent<String>, data: AnyMetadata) in
            let data = try XCTUnwrap(data.value as? LoginFailureReason)
            XCTAssertEqual(event.group, .action)
            XCTAssertEqual(data.reason, "failed")
        }
        handler.track(event: event, at: .init(), anyData: data)
        waitForExpectations(timeout: 1)
    }
}
