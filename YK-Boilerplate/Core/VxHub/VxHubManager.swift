import UIKit
import Combine
import VxHub

// MARK: - VxHub Init State
enum VxHubInitState {
    case loading
    case ready
    case forceUpdate
    case banned
    case failed(String?)
}

// MARK: - VxHub Manager
// Bridges VxHub SDK with the app layer.
// Init is triggered from AppDelegate, state is observed by SplashViewModel.

final class VxHubManager: NSObject, ObservableObject, VxHubDelegate {
    static let shared = VxHubManager()

    @Published var initState: VxHubInitState = .loading
    @Published var isNetworkConnected: Bool = true

    private override init() {
        super.init()
    }

    func configure(launchOptions: [UIApplication.LaunchOptionsKey: Any]?, application: UIApplication) {
        let environment: VxHubEnvironment = EnvironmentsConstants.currentEnvironment == .prod ? .prod : .stage
        let logLevel: LogLevel = EnvironmentsConstants.currentEnvironment == .prod ? .warning : .verbose

        let config = VxHubConfig(
            hubId: EnvironmentsConstants.vxHubId,
            environment: environment,
            appLifecycle: .sceneDelegate,
            requestAtt: false,
            logLevel: logLevel
        )

        VxHub.shared.initialize(
            config: config,
            delegate: self,
            launchOptions: launchOptions,
            application: application
        )
    }

    func start() {
        VxHub.shared.start()
    }

    // MARK: - VxHubDelegate

    func vxHubDidInitialize() {
        DispatchQueue.main.async { [weak self] in
            self?.initState = .ready
        }
    }

    func vxHubDidStart() { }

    func vxHubDidFailWithError(error: String?) {
        DispatchQueue.main.async { [weak self] in
            self?.initState = .failed(error)
        }
    }

    func vxHubDidReceiveForceUpdate() {
        DispatchQueue.main.async { [weak self] in
            self?.initState = .forceUpdate
        }
    }

    func vxHubDidReceiveBanned() {
        DispatchQueue.main.async { [weak self] in
            self?.initState = .banned
        }
    }

    func vxHubDidChangeNetworkStatus(isConnected: Bool, connectionType: String) {
        DispatchQueue.main.async { [weak self] in
            self?.isNetworkConnected = isConnected
        }
    }
}
