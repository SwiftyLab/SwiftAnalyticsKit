/// A metadata type without any data.
///
/// Use this type for events where metadata is not tracked.
public struct EmptyMetadata: Initializable, AnalyticsMetadata {
    /// A dummy empty dictionary that is encoded.
    private let data: [String: Bool] = [:]
    /// Creates a new instance.
    public init() {}

    /// Encodes empty dictionary data into the given encoder.
    ///
    /// - Parameter encoder: The encoder to write data to.
    public func encode(to encoder: Encoder) throws {
        try data.encode(to: encoder)
    }
}
