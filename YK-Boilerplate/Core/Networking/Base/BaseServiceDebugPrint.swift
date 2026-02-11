import Foundation

// MARK: - Debug Print for Network Requests
// Only active in DEBUG builds.

struct BaseServiceDebugPrint {
    static func log<T>(
        target: APITargetType,
        request: URLRequest,
        response: HTTPURLResponse?,
        data: Data?,
        error: Error?,
        responseType: T.Type
    ) {
        #if DEBUG
        let method = target.method.rawValue
        let url = request.url?.absoluteString ?? "unknown"
        let statusCode = response?.statusCode ?? 0
        let statusEmoji = (200..<300).contains(statusCode) ? "✅" : "❌"

        print("\n\(statusEmoji) [\(method)] \(url)")
        print("   Status: \(statusCode)")

        // Request body
        if let body = request.httpBody, let bodyString = String(data: body, encoding: .utf8) {
            if let jsonData = bodyString.data(using: .utf8),
               let json = try? JSONSerialization.jsonObject(with: jsonData),
               let prettyData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
               let prettyString = String(data: prettyData, encoding: .utf8) {
                print("   Request Body:\n\(prettyString)")
            } else {
                print("   Request Body: \(bodyString)")
            }
        }

        // Response body
        if let data = data, let responseString = String(data: data, encoding: .utf8) {
            if let jsonData = responseString.data(using: .utf8),
               let json = try? JSONSerialization.jsonObject(with: jsonData),
               let prettyData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
               let prettyString = String(data: prettyData, encoding: .utf8) {
                let truncated = prettyString.count > 2000 ? String(prettyString.prefix(2000)) + "\n   ... (truncated)" : prettyString
                print("   Response (\(String(describing: T.self))):\n\(truncated)")
            }
        }

        if let error = error {
            print("   Error: \(error.localizedDescription)")
        }
        print("")
        #endif
    }
}
