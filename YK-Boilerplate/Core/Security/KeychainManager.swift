import Foundation
import Security
import UIKit

// MARK: - Keychain Manager
// Provides secure storage for sensitive data using iOS Keychain.

public final class KeychainManager {
    public static let shared = KeychainManager()
    private init() {}

    // MARK: - Stored Properties
    // TODO: Add your keychain-stored properties here.

    /// Unique device identifier, persisted in Keychain
    private(set) lazy var deviceId: String = {
        if let existing = getString(forKey: "device_id") {
            return existing
        }
        let newId = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
        set(newId, forKey: "device_id")
        return newId
    }()

    // MARK: - Generic Keychain Operations

    /// Save a string value to Keychain
    public func set(_ value: String, forKey key: String) {
        guard let data = value.data(using: .utf8) else { return }
        set(data, forKey: key)
    }

    /// Save data to Keychain
    public func set(_ data: Data, forKey key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        // Delete existing item first
        SecItemDelete(query as CFDictionary)
        // Add new item
        SecItemAdd(query as CFDictionary, nil)
    }

    /// Retrieve a string value from Keychain
    public func getString(forKey key: String) -> String? {
        guard let data = getData(forKey: key) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    /// Retrieve data from Keychain
    public func getData(forKey key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess else { return nil }
        return result as? Data
    }

    /// Delete a value from Keychain
    public func delete(forKey key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
    }

    /// Save a Codable object to Keychain
    public func setCodable<T: Codable>(_ value: T, forKey key: String) {
        guard let data = try? JSONEncoder().encode(value) else { return }
        set(data, forKey: key)
    }

    /// Retrieve a Codable object from Keychain
    public func getCodable<T: Codable>(forKey key: String) -> T? {
        guard let data = getData(forKey: key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    /// Clear all keychain items for this app
    public func clearAll() {
        let secClasses = [
            kSecClassGenericPassword,
            kSecClassInternetPassword,
            kSecClassCertificate,
            kSecClassKey,
            kSecClassIdentity
        ]
        for secClass in secClasses {
            let query: [String: Any] = [kSecClass as String: secClass]
            SecItemDelete(query as CFDictionary)
        }
    }

    /// Get device ID (creates one if not exists)
    public func getDeviceId() -> String {
        return deviceId
    }
}
