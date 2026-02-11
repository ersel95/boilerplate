import Foundation

// MARK: - User Session
// Manages the current user's session state and tokens.
// TODO: Customize token storage and session data for your project.

public final class UserSession: ObservableObject {
    public static let shared = UserSession()

    @Published public var isLoggedIn: Bool = false
    @Published public var accessToken: String?

    private init() {
        // Restore token from Keychain on init
        accessToken = KeychainManager.shared.getString(forKey: "access_token")
        isLoggedIn = accessToken != nil
    }

    // MARK: - Token Management

    /// Save access token
    public func saveAccessToken(_ token: String) {
        accessToken = token
        isLoggedIn = true
        KeychainManager.shared.set(token, forKey: "access_token")
    }

    /// Retrieve stored access token
    public func retrieveAccessToken() -> String? {
        return accessToken ?? KeychainManager.shared.getString(forKey: "access_token")
    }

    // MARK: - Session Lifecycle

    /// Logout and clear all session data
    public func logout() {
        accessToken = nil
        isLoggedIn = false
        KeychainManager.shared.delete(forKey: "access_token")
        // TODO: Clear additional session data here
    }

    /// Clear all local data (for full reset)
    public func clearAllLocalData() {
        logout()
        UserDefaultsManager.shared.clearAll()
        KeychainManager.shared.clearAll()
        NetworkCache.shared.clear()
    }
}
