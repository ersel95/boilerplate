import Foundation

// MARK: - Type-Erased Encodable
// Wraps any Encodable value for use in generic contexts.

public struct AnyEncodable: Encodable {
    private let _encode: (Encoder) throws -> Void

    public init(_ wrapped: Encodable) {
        _encode = wrapped.encode
    }

    public func encode(to encoder: Encoder) throws {
        try _encode(encoder)
    }
}
