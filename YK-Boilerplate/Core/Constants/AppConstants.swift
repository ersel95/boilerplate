import Foundation

// MARK: - App Constants
// TODO: Update these values for your project.

public struct AppConstants {
    /// App version from bundle
    public static var version: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }

    /// App build number from bundle
    public static var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }

    /// Bundle identifier
    public static var bundleId: String {
        Bundle.main.bundleIdentifier ?? "com.yourcompany.app"
    }

    /// App display name
    public static var appName: String {
        Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "YK-Boilerplate"
    }

    // MARK: - Session
    /// Session idle timeout in seconds (5 minutes)
    public static let sessionIdleTimeout: TimeInterval = 5 * 60
    /// Session warning timeout in seconds (4 minutes)
    public static let sessionWarningTimeout: TimeInterval = 4 * 60
}
