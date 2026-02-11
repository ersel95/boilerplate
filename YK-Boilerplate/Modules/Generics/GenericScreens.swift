import SwiftUI

// MARK: - Generic Screens
// Reusable screens that can be used from any module (popup, side menu, etc.)

public enum GenericScreens: CoordinatorEntryPoint, Hashable, Identifiable {
    case popup
    case sideMenu

    public var id: String {
        switch self {
        case .popup:    return "generics-popup"
        case .sideMenu: return "generics-sideMenu"
        }
    }

    public var isNavigationVisible: NavigationVisibility { .none }
    public var isBackButtonHidden: Bool { true }
}

// MARK: - Navigation Handler
extension MainCoordinator {
    func handleGenericsNavigation(_ screen: GenericScreens) -> AnyView {
        switch screen {
        case .popup:
            return AnyView(GenericPopupView())
        case .sideMenu:
            // TODO: Implement your side menu view
            return AnyView(Text("Side Menu").frame(maxWidth: .infinity, maxHeight: .infinity).background(.white))
        }
    }
}
