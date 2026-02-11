import SwiftUI

// MARK: - App Entry Point

@main
struct BoilerplateApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var appCoordinator = AppCoordinator()
    @Environment(\.scenePhase) private var scenePhase

    init() {
        NetworkReachability.shared.startMonitoring()
    }

    var body: some Scene {
        WindowGroup {
            RootCoordinatorView()
                .environmentObject(appCoordinator)
                .onAppear {
                    AppCoordinator.current = appCoordinator
                }
                .onChange(of: scenePhase) { _, newPhase in
                    switch newPhase {
                    case .active:
                        SessionManager.shared.handleUserInteraction()
                        VxHubManager.shared.start()
                    case .inactive:
                        break
                    case .background:
                        break
                    @unknown default:
                        break
                    }
                }
        }
    }
}

// MARK: - Root Coordinator View
// Displays the current root screen based on AppCoordinator's root state.

struct RootCoordinatorView: View {
    @EnvironmentObject var appCoordinator: AppCoordinator

    var body: some View {
        let coordinator = appCoordinator.getCoordinator(for: appCoordinator.root)

        if let mainCoordinator = coordinator as? MainCoordinator {
            CoordinatorView(coordinator: mainCoordinator)
                .transition(.opacity)
        }
    }
}
