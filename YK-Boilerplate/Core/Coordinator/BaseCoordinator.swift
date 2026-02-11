import SwiftUI
import Foundation

// MARK: - Base Coordinator
// Generic base class for coordinators. Handles stack-based navigation,
// presentation stack, and ViewModel caching.

@MainActor
open class BaseCoordinator<ScreenType: CoordinatorEntryPoint & Hashable & Identifiable>:
    ObservableObject,
    Coordinator,
    PresentingCoordinator,
    CoordinatorNavigator
{
    public typealias Screen = ScreenType
    public typealias Entry = ScreenType
    public typealias ViewType = AnyView

    // MARK: - Properties
    public weak var appCoordinator: AppCoordinator?

    @Published public var stack: [ScreenType] = [] {
        didSet {
            let oldIds = Set(oldValue.map { String(describing: $0.id) })
            let newIds = Set(stack.map { String(describing: $0.id) })
            let removedIds = oldIds.subtracting(newIds)

            if stack.count < oldValue.count {
                SessionManager.shared.handleUserInteraction()
            }

            removedIds.forEach { id in
                allRemovalKeys(for: id).forEach { removeStoredViewModel(for: $0) }
            }
        }
    }

    @Published public var presentationStack: [PresentationItem<ScreenType>] = [] {
        didSet {
            let oldIds = Set(oldValue.map { String(describing: $0.screen.id) })
            let newIds = Set(presentationStack.map { String(describing: $0.screen.id) })
            let removedIds = oldIds.subtracting(newIds)
            removedIds.forEach { id in
                allRemovalKeys(for: id).forEach { removeStoredViewModel(for: $0) }
            }
        }
    }

    @Published public var isDismissingBottomSheet: Bool = false
    @Published public var isDismissingPopup: Bool = false

    // MARK: - TopMost Navigation Info

    public var topMostNavigationType: NavigationType? {
        if let lastPresentationItem = presentationStack.last {
            return lastPresentationItem.type
        }
        if stack.count > 1 { return .push }
        return nil
    }

    public var topMostViewInfo: (screen: ScreenType, navigationType: NavigationType?)? {
        if let lastPresentationItem = presentationStack.last {
            return (lastPresentationItem.screen, lastPresentationItem.type)
        }
        if let lastScreen = stack.last {
            let navType: NavigationType? = stack.count > 1 ? .push : nil
            return (lastScreen, navType)
        }
        return nil
    }

    // MARK: - Initialization

    public init(appCoordinator: AppCoordinator?, initialScreen: ScreenType) {
        self.appCoordinator = appCoordinator
        self.stack = [initialScreen]
    }

    // MARK: - Navigation Destination (Override in subclass)

    @MainActor
    open func navigationDestination(for entry: ScreenType) -> AnyView {
        return AnyView(Text("Error: `navigationDestination` not implemented for \(String(describing: entry))"))
    }

    // MARK: - Navigate

    @MainActor
    public func navigate(to screen: ScreenType, with type: NavigationType) {
        if let currentNavType = topMostNavigationType {
            let isBottomSheet: Bool = { if case .bottomSheet = currentNavType { return true }; return false }()
            let isPopup: Bool = { if case .popup = currentNavType { return true }; return false }()

            if isBottomSheet || isPopup {
                back()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    self?.navigateWithType(with: type, screen: screen)
                }
                return
            }
        }
        self.navigateWithType(with: type, screen: screen)
    }

    @MainActor
    public func switchRoot(to root: AppScreens) {
        appCoordinator?.switchRoot(to: root)
    }

    @MainActor
    public func back() {
        SessionManager.shared.handleUserInteraction()

        if !presentationStack.isEmpty {
            guard let lastItem = presentationStack.last else { return }
            let removedScreenId = String(describing: lastItem.screen.id)
            let isBottomSheet: Bool = { if case .bottomSheet = lastItem.type { return true }; return false }()
            let isPopup: Bool = { if case .popup = lastItem.type { return true }; return false }()

            if isBottomSheet {
                isDismissingBottomSheet = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if !self.presentationStack.isEmpty { self.presentationStack.removeLast() }
                    self.allRemovalKeys(for: removedScreenId).forEach { self.removeStoredViewModel(for: $0) }
                    self.isDismissingBottomSheet = false
                }
            } else if isPopup {
                isDismissingPopup = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    if !self.presentationStack.isEmpty { self.presentationStack.removeLast() }
                    self.allRemovalKeys(for: removedScreenId).forEach { self.removeStoredViewModel(for: $0) }
                    self.isDismissingPopup = false
                }
            } else {
                presentationStack.removeLast()
                allRemovalKeys(for: removedScreenId).forEach { removeStoredViewModel(for: $0) }
            }
        } else if canPop() {
            pop()
        }
    }

    // MARK: - Stack Cleanup

    private func allRemovalKeys(for idString: String) -> [String] {
        var keys: [String] = [idString]
        let parts = idString.split(separator: "-")
        if parts.count >= 3, parts.first == parts.dropFirst().first {
            let stripped = parts.dropFirst().joined(separator: "-")
            keys.append(stripped)
        }
        return keys
    }

    @MainActor
    public func pop() {
        if stack.count > 1 {
            SessionManager.shared.handleUserInteraction()
            let removed = stack.removeLast()
            let removedId = String(describing: removed.id)
            allRemovalKeys(for: removedId).forEach { removeStoredViewModel(for: $0) }
        }
    }

    @MainActor
    public func popToRoot() {
        if let first = stack.first {
            let removedScreens = Array(stack.dropFirst())
            removedScreens.forEach { screen in
                let removedId = String(describing: screen.id)
                allRemovalKeys(for: removedId).forEach { removeStoredViewModel(for: $0) }
            }
            stack = [first]
        }
    }

    // MARK: - Full Cleanup

    @MainActor
    public func performFullCleanup() {
        stack.forEach { screen in
            let key = String(describing: screen.id)
            allRemovalKeys(for: key).forEach { removeStoredViewModel(for: $0) }
        }
        presentationStack.forEach { item in
            let key = String(describing: item.screen.id)
            allRemovalKeys(for: key).forEach { removeStoredViewModel(for: $0) }
        }
        stack.removeAll()
        presentationStack.removeAll()
        isDismissingBottomSheet = false
        isDismissingPopup = false
    }

    @MainActor
    open func handle(data: Any?) {}

    // MARK: - ViewModel Storage

    private let viewModelCache = NSMapTable<NSString, AnyObject>(keyOptions: .strongMemory, valueOptions: .weakMemory)

    @MainActor
    public func storeViewModel<T: AnyObject>(_ viewModel: T, for key: String) {
        viewModelCache.setObject(viewModel, forKey: key as NSString)
    }

    @MainActor
    public func getStoredViewModel<T: AnyObject>(for key: String) -> T? {
        return viewModelCache.object(forKey: key as NSString) as? T
    }

    @MainActor
    public func removeStoredViewModel(for key: String) {
        if let viewModel = viewModelCache.object(forKey: key as NSString) as? BaseViewModeling {
            viewModel.cancelPendingRequests()
        }
        viewModelCache.removeObject(forKey: key as NSString)
    }

    @MainActor
    public func getOrCreateViewModel<T: AnyObject>(for key: String, create: () -> T) -> T {
        if let existing: T = getStoredViewModel(for: key) {
            return existing
        }
        let newViewModel = create()
        storeViewModel(newViewModel, for: key)
        return newViewModel
    }
}
