import Alamofire
import Foundation

// MARK: - Alamofire Event Logger
// Logs all requests and responses in debug builds.

final class AlamofireLogger: EventMonitor {
    let queue = DispatchQueue(label: "com.boilerplate.alamofireLogger")

    func requestDidResume(_ request: Request) {
        #if DEBUG
        guard let urlRequest = request.request else { return }
        let method = urlRequest.httpMethod ?? "UNKNOWN"
        let url = urlRequest.url?.absoluteString ?? "unknown"
        print("🌐 [\(method)] \(url)")

        if let body = urlRequest.httpBody, let bodyString = String(data: body, encoding: .utf8) {
            print("   Body: \(bodyString.prefix(500))")
        }
        #endif
    }

    func request<Value>(_ request: DataRequest, didParseResponse response: DataResponse<Value, AFError>) {
        #if DEBUG
        let statusCode = response.response?.statusCode ?? 0
        let url = request.request?.url?.absoluteString ?? "unknown"
        print("📩 [\(statusCode)] \(url)")
        #endif
    }
}
