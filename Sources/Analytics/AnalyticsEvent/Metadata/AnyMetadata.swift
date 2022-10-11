/// A type-erased metadata that can hold and
/// encode any type of metadata.
///
/// This type is used with ``AnyAnalyticsEvent``
/// to allow sending any type of metadata with an event.
public struct AnyMetadata: AnalyticsMetadata {
    /// The actual value that is encoded.
    internal let value: AnalyticsMetadata

    /// Creates a new metadata with the provided value.
    ///
    /// - Parameter value: The actual value
    ///                    that will be encoded.
    public init(with value: AnalyticsMetadata) {
        self.value = value
    }

    /// Encodes data provided during initialization
    /// into the given encoder.
    ///
    /// - Parameter encoder: The encoder to write data to.
    public func encode(to encoder: Encoder) throws {
        try value.encode(to: encoder)
    }
}
