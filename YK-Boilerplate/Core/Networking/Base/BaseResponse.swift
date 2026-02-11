import Foundation

// MARK: - API Result Type Alias
public typealias APIResult<T: Codable> = Result<BaseResponse<T>, NetworkError>

// MARK: - Base Error Response
public struct BaseErrorResponse: Decodable, Error {
    var errorMessage: String?
    var errorCode: String?
    var headers: [String: String]?

    enum CodingKeys: String, CodingKey {
        case errorMessage
        case errorCode
    }

    public init(errorMessage: String? = nil, errorCode: String? = nil, headers: [String: String]? = nil) {
        self.errorMessage = errorMessage
        self.errorCode = errorCode
        self.headers = headers
    }
}

// MARK: - Server Response Wrapper
/// Matches API response format: { "data": ..., "message": ..., "code": ... }
public struct BaseResponse<T: Codable>: Codable {
    public let postAction: PostActionTypes?
    public let message: String?
    public let code: ServerStatusCode?
    public let data: T?

    /// HTTP response headers (set manually after decoding)
    public var headers: [String: String]?

    public enum CodingKeys: String, CodingKey {
        case postAction
        case message
        case code
        case data
    }

    public init(data: T?, message: String? = nil, code: ServerStatusCode? = nil, postAction: PostActionTypes? = nil, headers: [String: String]? = nil) {
        self.data = data
        self.message = message
        self.code = code
        self.postAction = postAction
        self.headers = headers
    }
}

extension BaseResponse {
    public var isSuccess: Bool {
        !(code?.shouldHandle).orTrue
    }
}

// MARK: - Post Action Types
public enum PostActionTypes: String, EnumCodable {
    case none = "NONE"
    case logout = "LOGOUT"
    case showPopup = "SHOW_POPUP"
    case redirect = "REDIRECT"

    public static var defaultDecoderValue: PostActionTypes { .none }
}

// MARK: - Server Status Code
public enum ServerStatusCode: Int, Codable {
    case success = 0
    case success200 = 200
    case failure = 1

    // TODO: Add your project-specific server status codes here.

    /// Whether this code indicates an error that should be handled
    public var shouldHandle: Bool {
        switch self {
        case .success, .success200:
            return false
        default:
            return true
        }
    }
}

// MARK: - Empty Response DTO
/// Use when the API returns no body data
public struct EmptyResponseDTO: Codable {
    public init() {}
}

// MARK: - HTTPURLResponse Extension
extension HTTPURLResponse {
    var asDictionary: [String: String] {
        var headers: [String: String] = [:]
        allHeaderFields.forEach { key, value in
            headers[String(describing: key)] = String(describing: value)
        }
        return headers
    }
}
