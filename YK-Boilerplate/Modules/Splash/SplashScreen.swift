import SwiftUI

// MARK: - Splash Screen Enum

public enum SplashScreen: CoordinatorEntryPoint, Hashable, Identifiable {
    case splash

    public var id: String { "splash" }
    public var isNavigationVisible: NavigationVisibility { .none }
    public var isBackButtonHidden: Bool { true }
}

// MARK: - Navigation Handler
extension MainCoordinator {
    func handleSplashNavigation(_ screen: SplashScreen) -> AnyView {
        switch screen {
        case .splash:
            let viewModel: SplashViewModel = getOrCreateViewModel(for: screen.id) {
                SplashViewModel(navigator: appCoordinator)
            }
            return AnyView(SplashView(viewModel: viewModel))
        }
    }
}
