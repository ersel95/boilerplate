import Foundation
import CryptoKit

// MARK: - String Convenience Extensions

public extension String {
    /// Returns true if the string is not empty
    var isNotEmpty: Bool {
        return !isEmpty
    }

    /// SHA256 hash of the string
    func sha256() -> String {
        let inputData = Data(self.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.compactMap { String(format: "%02x", $0) }.joined()
    }

    /// RFC3986 percent encoding for URL parameters
    var addingRFC3986PercentEncoding: String {
        let allowed = CharacterSet.urlQueryAllowed.subtracting(CharacterSet(charactersIn: ":#[]@!$&'()*+,;="))
        return addingPercentEncoding(withAllowedCharacters: allowed) ?? self
    }

    /// Trims whitespace and newlines
    var trimmed: String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Returns nil if the string is empty
    var nilIfEmpty: String? {
        return isEmpty ? nil : self
    }
}
