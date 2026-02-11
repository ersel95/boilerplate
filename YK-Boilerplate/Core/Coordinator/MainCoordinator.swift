import SwiftUI

// MARK: - App Screens
// Central screen enum for the entire app. Each module defines its own sub-enum.
// TODO: Add new module screen enums here as you create them.

public indirect enum AppScreens: CoordinatorEntryPoint, Hashable, Identifiable {
    case splash(SplashScreen)
    case auth(AuthScreens)
    case home(HomeScreens)
    case example(ExampleScreens)
    case generics(GenericScreens)

    // MARK: - Identifiable
    public var id: String {
        switch self {
        case .splash(let screen):   return "splash-\(screen.id)"
        case .auth(let screen):     return "auth-\(screen.id)"
        case .home(let screen):     return "home-\(screen.id)"
        case .example(let screen):  return "example-\(screen.id)"
        case .generics(let screen): return "generics-\(screen.id)"
        }
    }

    // MARK: - Navigation Appearance Delegation
    public var navigationTitle: String? {
        switch self {
        case .splash(let s):   return s.navigationTitle
        case .auth(let s):     return s.navigationTitle
        case .home(let s):     return s.navigationTitle
        case .example(let s):  return s.navigationTitle
        case .generics(let s): return s.navigationTitle
        }
    }

    public var navigationTitleColor: Color? {
        switch self {
        case .splash(let s):   return s.navigationTitleColor
        case .auth(let s):     return s.navigationTitleColor
        case .home(let s):     return s.navigationTitleColor
        case .example(let s):  return s.navigationTitleColor
        case .generics(let s): return s.navigationTitleColor
        }
    }

    public var navigationTintColor: Color? {
        switch self {
        case .splash(let s):   return s.navigationTintColor
        case .auth(let s):     return s.navigationTintColor
        case .home(let s):     return s.navigationTintColor
        case .example(let s):  return s.navigationTintColor
        case .generics(let s): return s.navigationTintColor
        }
    }

    public var navigationImage: Image? {
        switch self {
        case .splash(let s):   return s.navigationImage
        case .auth(let s):     return s.navigationImage
        case .home(let s):     return s.navigationImage
        case .example(let s):  return s.navigationImage
        case .generics(let s): return s.navigationImage
        }
    }

    public var isNavigationVisible: NavigationVisibility {
        switch self {
        case .splash(let s):   return s.isNavigationVisible
        case .auth(let s):     return s.isNavigationVisible
        case .home(let s):     return s.isNavigationVisible
        case .example(let s):  return s.isNavigationVisible
        case .generics(let s): return s.isNavigationVisible
        }
    }

    public var isBackButtonHidden: Bool {
        switch self {
        case .splash(let s):   return s.isBackButtonHidden
        case .auth(let s):     return s.isBackButtonHidden
        case .home(let s):     return s.isBackButtonHidden
        case .example(let s):  return s.isBackButtonHidden
        case .generics(let s): return s.isBackButtonHidden
        }
    }

    // MARK: - Hashable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: AppScreens, rhs: AppScreens) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Main Coordinator
// Routes AppScreens to their corresponding Views.

class MainCoordinator: BaseCoordinator<AppScreens> {
    public var stateProvider = FlowStateProvider()

    init(appCoordinator: AppCoordinator?, entry: AppScreens = .splash(.splash)) {
        super.init(appCoordinator: appCoordinator, initialScreen: entry)
    }

    public override func navigationDestination(for entry: AppScreens) -> AnyView {
        switch entry {
        case .splash(let screen):
            return handleSplashNavigation(screen)
        case .auth(let screen):
            return handleAuthNavigation(screen)
        case .home(let screen):
            return handleHomeNavigation(screen)
        case .example(let screen):
            return handleExampleNavigation(screen)
        case .generics(let screen):
            return handleGenericsNavigation(screen)
        }
    }
}
