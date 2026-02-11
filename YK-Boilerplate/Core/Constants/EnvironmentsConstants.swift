import Foundation

// MARK: - Environment Configuration
// TODO: Configure your environment URLs and credentials here.

public enum Environments: String {
    case dev = "dev"
    case staging = "staging"
    case prod = "production"
}

public enum ServiceEnvironment: String, CaseIterable {
    case server = "server"
    case mock = "mock"
}

public struct EnvironmentsConstants {
    /// Current API base URL (without https:// prefix)
    /// Reads from Info.plist → BuildConfigurations → baseUrl
    public static var apiBaseUrl: String {
        guard let config = Bundle.main.infoDictionary?["BuildConfigurations"] as? [String: Any],
              let baseUrl = config["baseUrl"] as? String else {
            // TODO: Replace with your default API URL
            return "jsonplaceholder.typicode.com"
        }
        return baseUrl
    }

    /// Current environment determined by build configuration
    public static var currentEnvironment: Environments {
        #if DEBUG
        return .dev
        #else
        return .prod
        #endif
    }

    /// Network mode: server (real API) or mock (local data)
    public static var networkMode: ServiceEnvironment {
        let stored = UserDefaultsManager.shared.getString(for: .serviceEnvironment)
        return ServiceEnvironment(rawValue: stored) ?? .server
    }

    /// VxHub identifier — reads from Info.plist → BuildConfigurations → vxHubId
    public static var vxHubId: String {
        guard let config = Bundle.main.infoDictionary?["BuildConfigurations"] as? [String: Any],
              let hubId = config["vxHubId"] as? String else {
            return "YOUR_VXHUB_ID"
        }
        return hubId
    }
}
