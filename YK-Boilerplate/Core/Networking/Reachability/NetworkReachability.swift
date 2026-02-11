import Foundation
import Combine
import Network

// MARK: - Network Reachability
// Monitors network connectivity using NWPathMonitor.

public final class NetworkReachability: ObservableObject {
    public static let shared = NetworkReachability()

    @Published public var isReachable: Bool = true
    public let shouldShowNetworkError = PassthroughSubject<Bool, Never>()

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.boilerplate.networkReachability")

    private init() {}

    /// Start monitoring network connectivity
    public func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            let reachable = path.status == .satisfied
            DispatchQueue.main.async {
                self?.isReachable = reachable
                if !reachable {
                    self?.shouldShowNetworkError.send(true)
                }
            }
        }
        monitor.start(queue: queue)
    }

    /// Stop monitoring
    public func stopMonitoring() {
        monitor.cancel()
    }
}
