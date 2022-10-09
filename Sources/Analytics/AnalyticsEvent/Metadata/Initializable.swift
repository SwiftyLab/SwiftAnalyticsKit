/// A type that can be initialized without any parameters.
public protocol Initializable {
    /// Creates a new instance.
    init()
}

extension Int: Initializable {}
extension Double: Initializable {}
extension Float: Initializable {}
extension Bool: Initializable {}
extension UInt: Initializable {}
extension String: Initializable {}

extension Array: Initializable {}
extension Dictionary: Initializable {}
