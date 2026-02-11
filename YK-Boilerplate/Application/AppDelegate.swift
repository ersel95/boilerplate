import UIKit
import VxHub

// MARK: - App Delegate
// Handles UIKit-level app lifecycle events and VxHub initialization.

class AppDelegate: NSObject, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let config = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        return config
    }

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        VxHubManager.shared.configure(launchOptions: launchOptions, application: application)
        return true
    }

    // MARK: - URL Scheme Handling
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        // TODO: Handle deep link URLs and Google Sign-In callback here
        return false
    }
}
