import Foundation

// MARK: - Network Error
public enum NetworkError: Error {
    case serverError(errorData: BaseErrorResponse)
    case internalError(message: String)
    case authenticationError

    // MARK: - Backend Error Code
    // TODO: Add your project-specific backend error codes here.
    public enum BackendErrorCode: String {
        case invalidToken = "INVALID_TOKEN"
        case sessionExpired = "SESSION_EXPIRED"
        case invalidCredentials = "INVALID_CREDENTIALS"
        case accessDenied = "ACCESS_DENIED"
        case unknown

        public init(from rawValue: String?) {
            guard let raw = rawValue?.uppercased() else {
                self = .unknown
                return
            }
            self = BackendErrorCode(rawValue: raw) ?? .unknown
        }

        public var userFriendlyMessage: String {
            switch self {
            case .invalidToken, .sessionExpired:
                return ErrorMessages.Auth.sessionExpired
            case .invalidCredentials:
                return ErrorMessages.Auth.invalidCredentials
            case .accessDenied:
                return ErrorMessages.Auth.accessDenied
            case .unknown:
                return ErrorMessages.Network.unknown
            }
        }
    }

    // MARK: - Computed Properties
    public var backendCode: BackendErrorCode {
        switch self {
        case .serverError(let errorData):
            return BackendErrorCode(from: errorData.errorCode)
        default:
            return .unknown
        }
    }

    public var errorMessage: String {
        switch self {
        case .serverError(let errorData):
            let backendCode = BackendErrorCode(from: errorData.errorCode)
            if let message = errorData.errorMessage, !message.isEmpty {
                return message
            }
            return backendCode.userFriendlyMessage

        case .internalError(let message):
            return message

        case .authenticationError:
            return ErrorMessages.Auth.sessionExpired
        }
    }

    public var errorCode: String {
        switch self {
        case .serverError(let errorData):
            return (errorData.errorCode).orEmpty
        case .internalError(let message):
            return message
        case .authenticationError:
            return "AUTH_ERROR"
        }
    }

    public var headers: [String: String]? {
        switch self {
        case .serverError(let errorData):
            return errorData.headers
        default:
            return nil
        }
    }
}

// MARK: - Internal Network Error
public enum InternalNetworkError: Swift.Error {
    case requestMapping(String)
    case encodableMapping(Swift.Error)
    case parameterEncoding(Swift.Error)
    case objectMapping(Swift.Error)
    case customError(String)
    case serverError(message: String, code: Int)
}
