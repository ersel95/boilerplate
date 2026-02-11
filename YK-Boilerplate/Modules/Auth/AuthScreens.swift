import SwiftUI

// MARK: - Auth Screen Enum

public enum AuthScreens: CoordinatorEntryPoint, Hashable, Identifiable {
    case login

    public var id: String {
        switch self {
        case .login: return "auth-login"
        }
    }

    public var isNavigationVisible: NavigationVisibility { .none }
    public var isBackButtonHidden: Bool { true }
}

// MARK: - Navigation Handler
extension MainCoordinator {
    func handleAuthNavigation(_ screen: AuthScreens) -> AnyView {
        switch screen {
        case .login:
            let viewModel: LoginViewModel = getOrCreateViewModel(for: screen.id) {
                LoginViewModel(navigator: appCoordinator)
            }
            return AnyView(LoginView(viewModel: viewModel))
        }
    }
}
