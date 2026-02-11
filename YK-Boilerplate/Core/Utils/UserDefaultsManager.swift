import Foundation

// MARK: - UserDefaults Manager
// Provides type-safe access to UserDefaults with predefined keys.
// TODO: Add your project-specific keys to UserDefaultsKey enum.

public protocol UserDefaultsManagerProtocol {
    func getValue<T>(for key: UserDefaultsKey) -> T?
    func setValue<T>(_ value: T, for key: UserDefaultsKey)
    func getBool(for key: UserDefaultsKey) -> Bool
    func getString(for key: UserDefaultsKey) -> String
    func getInt(for key: UserDefaultsKey) -> Int
    func resetToDefaults()
    func clearAll()
}

// MARK: - Keys
public enum UserDefaultsKey: String, CaseIterable {
    case selectedLanguage = "selected_language"
    case serviceEnvironment = "service_environment"
    case isBiometricEnabled = "is_biometric_enabled"
    case isFirstLaunch = "is_first_launch"
    case localizationCache = "localization_cache"

    // Default values
    var defaultValue: Any? {
        switch self {
        case .selectedLanguage: return "en"
        case .serviceEnvironment: return "server"
        case .isBiometricEnabled: return false
        case .isFirstLaunch: return true
        case .localizationCache: return nil
        }
    }
}

// MARK: - Implementation
public final class UserDefaultsManager: UserDefaultsManagerProtocol {
    public static let shared = UserDefaultsManager()
    private let defaults = UserDefaults.standard

    private init() {}

    public func getValue<T>(for key: UserDefaultsKey) -> T? {
        return defaults.object(forKey: key.rawValue) as? T
    }

    public func setValue<T>(_ value: T, for key: UserDefaultsKey) {
        defaults.set(value, forKey: key.rawValue)
    }

    public func getBool(for key: UserDefaultsKey) -> Bool {
        return defaults.bool(forKey: key.rawValue)
    }

    public func getString(for key: UserDefaultsKey) -> String {
        return defaults.string(forKey: key.rawValue) ?? (key.defaultValue as? String ?? "")
    }

    public func getInt(for key: UserDefaultsKey) -> Int {
        return defaults.integer(forKey: key.rawValue)
    }

    public func resetToDefaults() {
        UserDefaultsKey.allCases.forEach { key in
            if let defaultValue = key.defaultValue {
                defaults.set(defaultValue, forKey: key.rawValue)
            } else {
                defaults.removeObject(forKey: key.rawValue)
            }
        }
    }

    public func clearAll() {
        UserDefaultsKey.allCases.forEach { key in
            defaults.removeObject(forKey: key.rawValue)
        }
    }
}
