import XCTest

@testable import Analytics

final class SomeAnalyticsEventTests: XCTestCase {

    func testEventCast() throws {
        let lsvEvent = SomeAnalyticsEvent(from: LoginEvent.loginScreenViewed)
        XCTAssertEqual(lsvEvent.name, "loginScreenViewed")
        XCTAssertEqual(lsvEvent.group, .state)
        XCTAssertNotNil(lsvEvent.configuration as? DefaultConfiguration)

        let laEvent = SomeAnalyticsEvent(
            from: LoginEvent.loginAttempted,
            configuration: RandomConfiguration()
        )
        XCTAssertEqual(laEvent.name, "loginAttempted")
        XCTAssertEqual(laEvent.group, .action)
        XCTAssertNotNil(laEvent.configuration as? RandomConfiguration)
    }

    func testEventGroupTransfer() throws {
        let lsvEvent = SomeAnalyticsEvent(
            from: LoginEvent.loginScreenViewed,
            transferredTo: .action
        )
        XCTAssertEqual(lsvEvent.name, "loginScreenViewed")
        XCTAssertEqual(lsvEvent.group, .action)
        XCTAssertNotNil(lsvEvent.configuration as? DefaultConfiguration)

        let laEvent = SomeAnalyticsEvent(
            from: LoginEvent.loginAttempted,
            transferredTo: .action,
            configuration: RandomConfiguration()
        )
        XCTAssertEqual(laEvent.name, "loginAttempted")
        XCTAssertEqual(laEvent.group, .action)
        XCTAssertNotNil(laEvent.configuration as? RandomConfiguration)
    }

    func testEventGroupAppend() throws {
        let lsvEvent = SomeAnalyticsEvent(
            from: LoginEvent.loginScreenViewed,
            appending: .action
        )
        XCTAssertEqual(lsvEvent.name, "loginScreenViewed")
        XCTAssertEqual(lsvEvent.group, [.action, .state])
        XCTAssertNotNil(lsvEvent.configuration as? DefaultConfiguration)

        let laEvent = SomeAnalyticsEvent(
            from: LoginEvent.loginAttempted,
            appending: .action,
            configuration: RandomConfiguration()
        )
        XCTAssertEqual(laEvent.name, "loginAttempted")
        XCTAssertEqual(lsvEvent.group, [.action, .state])
        XCTAssertNotNil(laEvent.configuration as? RandomConfiguration)
    }
}

struct RandomConfiguration: AnalyticsConfiguration {}
