#if swift(>=5.7)
/// A type that encodes analytics metadata to an output type.
@rethrows
public protocol AnalyticsEncoder<Output> {
    /// The type of the encoded representation.
    associatedtype Output
    /// Returns an encoded representation of the value supplied.
    ///
    /// - Parameters:
    ///   - data: The value to encode.
    ///
    /// - Returns: The encoded output.
    /// - Throws: If encoding to the output type fails.
    func encodeMetadata<T: Encodable>(_ data: T) throws -> Output
}
#else
/// A type that encodes analytics metadata to an output type.
@rethrows
public protocol AnalyticsEncoder {
    /// The type of the encoded representation.
    associatedtype Output
    /// Returns an encoded representation of the value supplied.
    ///
    /// - Parameters:
    ///   - data: The value to encode.
    ///
    /// - Returns: The encoded output.
    /// - Throws: If encoding to the output type fails.
    func encodeMetadata<T: Encodable>(_ data: T) throws -> Output
}
#endif

/// The action to perform if encoding analytics metadata fails.
@frozen
public enum EncodingFailureAction {
    /// Ignore associated event if encoding metadata fails.
    case ignore
    /// Rethrow or pass error if encoding metadata fails.
    case error
}
