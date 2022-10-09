import XCTest

@testable import Analytics
@testable import AnalyticsMock

final class StandardDictionaryEncoderTests: XCTestCase {

    func testEmptyMetadataEncoding() throws {
        let encoder = StandardDictionaryEncoder()
        let data = try encoder.encodeMetadata(EmptyMetadata())
        XCTAssertTrue(data.isEmpty)
    }

    func testMetadataEncoding() throws {
        let encoder = StandardDictionaryEncoder()
        let data = try encoder.encodeMetadata(LoginFailureReason(reason: "f"))
        XCTAssertEqual(data["reason"] as? String, "f")
    }

    func testTypeErasedEmptyMetadataEncoding() throws {
        let encoder = StandardDictionaryEncoder()
        let data = try encoder.encodeMetadata(
            AnyMetadata(with: EmptyMetadata())
        )
        XCTAssertTrue(data.isEmpty)
    }

    func testTypeErasedMetadataEncoding() throws {
        let encoder = StandardDictionaryEncoder()
        let data = try encoder.encodeMetadata(
            AnyMetadata(with: LoginFailureReason(reason: "f"))
        )
        XCTAssertEqual(data["reason"] as? String, "f")
    }

    #if !os(Linux) && !os(Windows)
    func testInvalidType() throws {
        XCTExpectFailure("Fails due to invalid type provided")
        let encoder = StandardDictionaryEncoder()
        let _ = try encoder.encodeMetadata(["data"])
    }

    func testTypeErasedInvalidType() throws {
        XCTExpectFailure("Fails due to invalid type provided")
        let encoder = StandardDictionaryEncoder()
        let _ = try encoder.encodeMetadata(AnyMetadata(with: ["data"]))
    }
    #endif
}
