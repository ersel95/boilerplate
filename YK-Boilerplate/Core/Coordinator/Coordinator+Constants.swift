import SwiftUI

// MARK: - Navigation Appearance Protocol
public protocol NavigationAppearanceProviding {
    var navigationTitle: String? { get }
    var navigationTitleColor: Color? { get }
    var navigationImage: Image? { get }
    var navigationTintColor: Color? { get }
    var isNavigationVisible: NavigationVisibility { get }
    var isBackButtonHidden: Bool { get }
}

public extension NavigationAppearanceProviding {
    var navigationTitle: String? { nil }
    var navigationTitleColor: Color? { nil }
    var navigationImage: Image? { nil }
    var navigationTintColor: Color? { .accentColor }
    var isNavigationVisible: NavigationVisibility { .always }
    var isBackButtonHidden: Bool { false }
}

// MARK: - Navigation Visibility
public enum NavigationVisibility {
    case none, always
}

// MARK: - Navigation Type
public enum NavigationType: Identifiable, Hashable {
    public var id: String { String(describing: self) }

    case push
    case sheet
    case bottomSheet(detents: [PresentationDetent] = [], isDraggable: Bool = true, scrimColor: Color? = nil)
    case fullScreenCover
    case popup(backgroundColor: DynamicColors? = nil, position: PopupContentPosition, isDismissable: Bool = false)
    case sideMenu

    var isPopup: Bool {
        if case .popup = self { return true }
        return false
    }
}

// MARK: - Dynamic Colors (for popup backgrounds)
public struct DynamicColors: Hashable {
    public let light: Color
    public let dark: Color

    public init(light: Color, dark: Color) {
        self.light = light
        self.dark = dark
    }
}

// MARK: - Popup Content Position
public enum PopupContentPosition: Hashable {
    case top, center, bottom
}

// MARK: - Coordinator Entry Point Protocol
public protocol CoordinatorEntryPoint: NavigationAppearanceProviding {}

public extension CoordinatorEntryPoint {
    var navigationTitle: String? { nil }
    var navigationTitleColor: Color? { nil }
    var navigationTintColor: Color { .accentColor }
    var isNavigationVisible: NavigationVisibility { .always }
    var isBackButtonHidden: Bool { false }
}

// MARK: - Presentation Item
public struct PresentationItem<Screen: CoordinatorEntryPoint & Hashable & Identifiable>: Identifiable, Equatable {
    public let id = UUID()
    public let screen: Screen
    public let type: NavigationType

    public static func == (lhs: PresentationItem<Screen>, rhs: PresentationItem<Screen>) -> Bool {
        lhs.id == rhs.id
    }

    public init(screen: Screen, type: NavigationType) {
        self.screen = screen
        self.type = type
    }
}

// MARK: - Coordinator Navigator Protocol
@MainActor
public protocol CoordinatorNavigator: AnyObject {
    associatedtype Screen: CoordinatorEntryPoint
    func navigate(to screen: Screen, with type: NavigationType)
    func back()
    func popToRoot()
    func switchRoot(to root: AppScreens)
}

// MARK: - Presenting Coordinator Protocol
@MainActor
public protocol PresentingCoordinator: ObservableObject {
    associatedtype Screen: CoordinatorEntryPoint & Hashable & Identifiable

    var presentationStack: [PresentationItem<Screen>] { get set }

    @MainActor func back()
    @MainActor func navigationDestination(for screen: Screen) -> AnyView
}

// MARK: - Bottom Sheet Config
public protocol BottomSheetConfigProviding {
    var bottomSheetDetents: [PresentationDetent] { get }
    var isDraggable: Bool { get }
    var bottomSheetScrimColor: Color? { get }
}

public extension BottomSheetConfigProviding {
    var isDraggable: Bool { true }
    var bottomSheetScrimColor: Color? { nil }
}

// MARK: - Navigate With Type Extension
extension PresentingCoordinator where Self: Coordinator, Self.Screen == Self.Entry {
    @MainActor
    func navigateWithType(with navType: NavigationType, screen: Screen) {
        switch navType {
        case .sheet, .fullScreenCover, .bottomSheet, .sideMenu, .popup:
            presentationStack.append(PresentationItem(screen: screen, type: navType))
        case .push:
            push(screen)
        }
    }
}
