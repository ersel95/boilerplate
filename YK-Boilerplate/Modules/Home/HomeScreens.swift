import SwiftUI

// MARK: - Home Screen Enum

public enum HomeScreens: CoordinatorEntryPoint, Hashable, Identifiable {
    case main
    case detail

    public var id: String {
        switch self {
        case .main:   return "home-main"
        case .detail: return "home-detail"
        }
    }

    public var navigationTitle: String? {
        switch self {
        case .main:   return "Home"
        case .detail: return "Detail"
        }
    }

    public var isNavigationVisible: NavigationVisibility {
        switch self {
        case .main: return .none
        case .detail: return .always
        }
    }

    public var isBackButtonHidden: Bool {
        switch self {
        case .main: return true
        case .detail: return false
        }
    }
}

// MARK: - Navigation Handler
extension MainCoordinator {
    func handleHomeNavigation(_ screen: HomeScreens) -> AnyView {
        switch screen {
        case .main:
            let viewModel: HomeViewModel = getOrCreateViewModel(for: screen.id) {
                HomeViewModel(navigator: appCoordinator)
            }
            return AnyView(HomeView(viewModel: viewModel))

        case .detail:
            let viewModel: DetailViewModel = getOrCreateViewModel(for: screen.id) {
                DetailViewModel(navigator: appCoordinator)
            }
            return AnyView(DetailView(viewModel: viewModel))
        }
    }
}
