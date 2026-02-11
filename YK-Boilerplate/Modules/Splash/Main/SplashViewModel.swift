import Foundation
import Combine

// MARK: - Splash ViewModel
// Observes VxHub initialization state and navigates when ready.

@MainActor
class SplashViewModel: BaseViewModel {
    @Published var isLoading = true

    private let vxHubManager: VxHubManager

    init(navigator: AppNavigationProtocol? = nil, vxHubManager: VxHubManager = .shared) {
        self.vxHubManager = vxHubManager
        super.init(navigator: navigator)
        observeVxHubState()
    }

    private func observeVxHubState() {
        vxHubManager.$initState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.handleVxHubState(state)
            }
            .store(in: &cancellables)
    }

    private func handleVxHubState(_ state: VxHubInitState) {
        switch state {
        case .loading:
            break
        case .ready:
            completeInitialization()
        case .forceUpdate:
            // TODO: Show force update alert/screen
            break
        case .banned:
            // TODO: Show banned screen
            break
        case .failed:
            // TODO: Show error with retry option
            break
        }
    }

    private func completeInitialization() {
        if UserSession.shared.isLoggedIn {
            switchRoot(to: .home(.main))
        } else {
            switchRoot(to: .auth(.login))
        }
        isLoading = false
    }
}
