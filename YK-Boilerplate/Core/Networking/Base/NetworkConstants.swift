import Foundation

// MARK: - Encoding Types
public enum Encoding {
    case urlEncodingQuery
    case urlEncodingHTTPBody
    case jsonEncoding
    case customURLBody
}

// MARK: - Enum Codable Helper
public protocol EnumCodable: RawRepresentable, Codable {
    static var defaultDecoderValue: Self { get }
}

extension EnumCodable where RawValue: Codable {
    public init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer().decode(RawValue.self)
        self = Self(rawValue: value) ?? Self.defaultDecoderValue
    }
}

// MARK: - HTTP Task
public enum HTTPTask {
    case requestPlain
    case requestJSONEncodable(Encodable)
    case requestParameters(parameters: [String: Any], encoding: Encoding)
    case requestParametersWithoutEncoding(parameters: [String: Any])
    case customEncodedURLBody(parameters: [String: Any])
}

// MARK: - HTTP Method
public struct HTTPMethod: RawRepresentable, Equatable, Hashable {
    public static let delete  = HTTPMethod(rawValue: "DELETE")
    public static let get     = HTTPMethod(rawValue: "GET")
    public static let head    = HTTPMethod(rawValue: "HEAD")
    public static let options = HTTPMethod(rawValue: "OPTIONS")
    public static let patch   = HTTPMethod(rawValue: "PATCH")
    public static let post    = HTTPMethod(rawValue: "POST")
    public static let put     = HTTPMethod(rawValue: "PUT")

    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}
