import Foundation
import Alamofire

// MARK: - Request Builder
protocol RequestBuilderProtocol {
    func buildRequest(from target: APITargetType) throws -> URLRequest
}

final class RequestBuilder: RequestBuilderProtocol {
    func buildRequest(from target: APITargetType) throws -> URLRequest {
        guard let requestURLComponents = URLComponents(string: target.baseURL + target.path) else {
            throw InternalNetworkError.requestMapping("Error occurred building URL")
        }

        guard let url = requestURLComponents.url else {
            throw InternalNetworkError.requestMapping("Error occurred building URL")
        }

        var request = URLRequest(
            url: url,
            cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
            timeoutInterval: target.timeoutInterval
        )

        request.httpMethod = target.method.rawValue
        target.headers?.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }

        // TODO: Add any custom token headers here if needed
        // request.setValue(tokenManager.token, forHTTPHeaderField: "X-Custom-Token")

        do {
            switch target.task {
            case .requestPlain:
                break
            case .requestJSONEncodable(let bodyObject):
                try request.encoded(encodable: bodyObject)
            case .requestParameters(parameters: let parameters, encoding: let encoding):
                request = try request.encoded(parameters: parameters, parameterEncoding: encoding.parameterEncodingValue)
            case .requestParametersWithoutEncoding(let parameters):
                request.httpBody = parameters.map { "\($0.key)=\($0.value)" }
                    .joined(separator: "&").data(using: .utf8)
            case .customEncodedURLBody(parameters: let parameters):
                request = request.encodeURLBodyWithRFC3986PercentEncoding(parameters: parameters)
            }
            return request
        } catch {
            throw error
        }
    }
}

// MARK: - URLRequest Encoding Extensions
internal extension URLRequest {
    mutating func encoded(encodable: Encodable, encoder: JSONEncoder = JSONEncoder()) throws {
        do {
            let encodable = AnyEncodable(encodable)
            encoder.outputFormatting = [.withoutEscapingSlashes]
            httpBody = try encoder.encode(encodable)

            let contentTypeHeaderName = "Content-Type"
            if value(forHTTPHeaderField: contentTypeHeaderName) == nil {
                setValue("application/json", forHTTPHeaderField: contentTypeHeaderName)
            }
        } catch {
            throw InternalNetworkError.encodableMapping(error)
        }
    }

    func encoded(parameters: [String: Any], parameterEncoding: ParameterEncoding) throws -> URLRequest {
        do {
            return try parameterEncoding.encode(self, with: parameters)
        } catch {
            throw InternalNetworkError.parameterEncoding(error)
        }
    }

    func encodeURLBodyWithRFC3986PercentEncoding(parameters: [String: Any]) -> URLRequest {
        var request = self
        let pairs = parameters.keys.sorted().compactMap { key -> String? in
            guard let value = parameters[key] as? String else { return nil }
            let encodedKey = key.addingRFC3986PercentEncoding
            let encodedValue = value.addingRFC3986PercentEncoding.replacingOccurrences(of: "%20", with: "+")
            return "\(encodedKey)=\(encodedValue)"
        }
        request.httpBody = pairs.joined(separator: "&").data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        return request
    }
}

// MARK: - Encoding → ParameterEncoding
extension Encoding {
    var parameterEncodingValue: ParameterEncoding {
        switch self {
        case .urlEncodingQuery:  return URLEncoding.queryString
        case .urlEncodingHTTPBody: return URLEncoding.httpBody
        case .jsonEncoding: return JSONEncoding(options: [.withoutEscapingSlashes])
        case .customURLBody: return URLEncoding.httpBody
        }
    }
}
