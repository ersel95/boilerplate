import Foundation

// MARK: - API Target Type Protocol
// Each API endpoint enum conforms to this protocol.
// TODO: Customize defaultHeaders for your project needs.

public protocol APITargetType {
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var task: HTTPTask { get }
    var headers: [String: String]? { get }
    var customHeaders: [String: String]? { get }
    var sampleData: Data { get }
    var timeoutInterval: TimeInterval { get }
    var retryCount: Int { get }
    var retryDelay: TimeInterval { get }
    var requiresAuth: Bool { get }
    var shouldCache: Bool { get }
    var cacheTTL: TimeInterval? { get }
    var cacheKey: String { get }
    var consoleLog: Bool { get }
}

// MARK: - Default Implementations
public extension APITargetType {
    var baseURL: String {
        "https://" + EnvironmentsConstants.apiBaseUrl + "/"
    }

    var defaultHeaders: [String: String] {
        [
            "Channel": "MOBILE",
            "Language": "EN",
            "Platform": "IOS",
            "App-Version": AppConstants.version,
            "Device-Id": KeychainManager.shared.getDeviceId(),
            "accept": "*/*",
        ]
    }

    var headers: [String: String]? {
        var headers = defaultHeaders

        if requiresAuth {
            headers["Authorization"] = "Bearer \((UserSession.shared.accessToken).orEmpty)"
        }

        // Apply target-specific custom headers last (override)
        if let extra = customHeaders {
            extra.forEach { key, value in
                headers[key] = value
            }
        }

        return headers
    }

    var timeoutInterval: TimeInterval { 30.0 }
    var retryCount: Int { 0 }
    var retryDelay: TimeInterval { 1.0 }
    var requiresAuth: Bool { false }
    var customHeaders: [String: String]? { nil }
    var shouldCache: Bool { false }
    var cacheTTL: TimeInterval? { nil }
    var consoleLog: Bool { false }

    var cacheKey: String {
        let base = "\(method.rawValue):\(baseURL)\(path)"
        let params: String
        switch task {
        case .requestPlain:
            params = ""
        case .requestJSONEncodable(let encodable):
            let encoder = JSONEncoder()
            encoder.outputFormatting = .sortedKeys
            let jsonData = try? encoder.encode(AnyEncodable(encodable))
            let jsonString = jsonData.flatMap { String(data: $0, encoding: .utf8) } ?? ""
            params = jsonString.sha256()
        case .requestParameters(let parameters, _):
            let paramString = parameters.map { "\($0.key)=\($0.value)" }.sorted().joined(separator: "&")
            params = paramString.sha256()
        case .requestParametersWithoutEncoding(let parameters):
            let paramString = parameters.map { "\($0.key)=\($0.value)" }.sorted().joined(separator: "&")
            params = paramString.sha256()
        case .customEncodedURLBody(let parameters):
            let paramString = parameters.map { "\($0.key)=\($0.value)" }.sorted().joined(separator: "&")
            params = paramString.sha256()
        }
        return base + ":" + params
    }
}
