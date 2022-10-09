import Foundation
import Analytics

/// An object that encodes instances of a data type as collection (array or dictionary)
/// with `String` dictionary keys.
///
/// The encoding performance isn't optimal and should only be used in case of testing.
///
/// - Warning: This object uses `JSONEncoder` to encode data as JSON object and
///            uses `JSONSerialization` to convert JSON object to equivalent object.
///            Use a decoder that directly decodes to dictionary or collection instead for better
///            performance.
public struct StandardDictionaryEncoder: AnalyticsEncoder {
    /// A dictionary you use to customize the encoding process by providing contextual information.
    public var userInfo: [CodingUserInfoKey: Any]
    /// The strategy that an encoder uses to encode raw data.
    public var dataEncodingStrategy: JSONEncoder.DataEncodingStrategy
    /// The strategy used when encoding dates as part of a JSON object.
    public var dateEncodingStrategy: JSONEncoder.DateEncodingStrategy
    /// A value that determines how to encode a type’s coding keys as JSON keys.
    public var keyEncodingStrategy: JSONEncoder.KeyEncodingStrategy
    /// The strategy used by an encoder when it encounters exceptional floating-point values.
    public var nonConformingFloatEncodingStrategy:
        JSONEncoder.NonConformingFloatEncodingStrategy
    /// A value that determines the readability, size, and element order of the encoded JSON object.
    public var outputFormatting: JSONEncoder.OutputFormatting

    /// Creates a new, reusable `String` keyed collection encoder with the provided formatting settings and encoding strategies.
    ///
    /// - Parameters:
    ///   - userInfo: A dictionary you use to customize the encoding process by providing contextual information.
    ///   - dataEncodingStrategy: The strategy that an encoder uses to encode raw data.
    ///   - dateEncodingStrategy: The strategy used when encoding dates as part of a JSON object.
    ///   - keyEncodingStrategy: A value that determines how to encode a type’s coding keys as JSON keys.
    ///   - nonConformingFloatEncodingStrategy: The strategy used by an encoder when it encounters exceptional floating-point values.
    ///   - outputFormatting: A value that determines the readability, size, and element order of the encoded JSON object.
    public init(
        userInfo: [CodingUserInfoKey: Any] = [:],
        dataEncodingStrategy: JSONEncoder.DataEncodingStrategy = .base64,
        dateEncodingStrategy: JSONEncoder.DateEncodingStrategy =
            .deferredToDate,
        keyEncodingStrategy: JSONEncoder.KeyEncodingStrategy = .useDefaultKeys,
        nonConformingFloatEncodingStrategy: JSONEncoder
            .NonConformingFloatEncodingStrategy = .throw,
        outputFormatting: JSONEncoder.OutputFormatting = .prettyPrinted
    ) {
        self.userInfo = userInfo
        self.dataEncodingStrategy = dataEncodingStrategy
        self.dateEncodingStrategy = dateEncodingStrategy
        self.keyEncodingStrategy = keyEncodingStrategy
        self.nonConformingFloatEncodingStrategy =
            nonConformingFloatEncodingStrategy
        self.outputFormatting = outputFormatting
    }

    /// Returns a `String` keyed collection(dictionary or array)-encoded
    /// representation of the value you supply.
    ///
    /// - Parameter data: The value to encode.
    /// - Returns: The encoded collection object.
    ///
    /// - Throws: The value fails to encode, or contains a nested value that fails
    ///           to encode—this method throws the corresponding error.
    /// - Throws: The value isn’t encodable as a JSON array or JSON object.
    ///           this method throws the `EncodingError.invalidValue` error.
    /// - Throws: The value contains an exceptional floating-point number (such as `infinity` or `nan`)
    ///           and you’re using the default `JSONEncoder.NonConformingFloatEncodingStrategy`,
    ///           this method throws the `EncodingError.invalidValue` error.
    /// - Throws: `JSONSerialization.jsonObject` fails, this method throws `CocoaError`.
    public func encode<T: Encodable>(_ data: T) throws -> Any {
        let encoder = JSONEncoder()
        encoder.userInfo = userInfo
        encoder.dataEncodingStrategy = dataEncodingStrategy
        encoder.dateEncodingStrategy = dateEncodingStrategy
        encoder.keyEncodingStrategy = keyEncodingStrategy
        encoder.nonConformingFloatEncodingStrategy =
            nonConformingFloatEncodingStrategy
        encoder.outputFormatting = outputFormatting
        return try JSONSerialization.jsonObject(with: encoder.encode(data))
    }

    /// Returns a `String` keyed dictionary-encoded representation of the value you supply.
    ///
    /// - Parameter data: The value to encode.
    /// - Returns: The encoded dictionary object.
    ///
    /// - Throws: The value fails to encode, or contains a nested value that fails
    ///           to encode—this method throws the corresponding error.
    /// - Throws: The value isn’t encodable as a JSON array or JSON object,
    ///           this method throws the `EncodingError.invalidValue` error.
    /// - Throws: The value contains an exceptional floating-point number (such as `infinity` or `nan`)
    ///           and you’re using the default `JSONEncoder.NonConformingFloatEncodingStrategy`,
    ///           this method throws the `EncodingError.invalidValue` error.
    /// - Throws: `JSONSerialization.jsonObject` fails, this method throws `CocoaError`.
    /// - Throws: The encoded object isn't a `String` keyed dictionary,
    ///           this method throws the `EncodingError.invalidValue` error.
    public func encodeMetadata<T: Encodable>(
        _ data: T
    ) throws -> [String: Any] {
        let param = try self.encode(data)
        guard let params = param as? [String: Any] else {
            throw EncodingError.invalidValue(
                param,
                .init(
                    codingPath: [],
                    debugDescription:
                        "Expected: \([String: Any].self), received: \(type(of: param))"
                )
            )
        }
        return params
    }
}
