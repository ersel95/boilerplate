import SwiftUI

// MARK: - Coordinator Protocol
@MainActor
public protocol Coordinator: AnyObject {
    associatedtype Entry: CoordinatorEntryPoint
    associatedtype ViewType: View

    var stack: [Entry] { get set }

    func push(_ entry: Entry)
    func pop()
    func popToRoot()
    func canPop() -> Bool
    func stackCount() -> Int
    func handle(data: Any?)
}

public extension Coordinator {
    func push(_ entry: Entry) {
        stack.append(entry)
    }

    func pop() {
        if stack.count > 1 {
            stack.removeLast()
        }
    }

    func popToRoot() {
        if let first = stack.first {
            stack = [first]
        }
    }

    func canPop() -> Bool {
        return stack.count > 1
    }

    func stackCount() -> Int {
        return stack.count
    }
}

public extension Coordinator where Entry: Equatable {
    func pop(to destination: Entry? = nil) {
        if let destination, let targetIndex = stack.lastIndex(of: destination) {
            stack = Array(stack.prefix(targetIndex + 1))
            return
        }
        pop()
    }
}

// MARK: - App Coordinator
// Central navigation manager. NOT a singleton - injected via environment.

@MainActor
public final class AppCoordinator: ObservableObject {

    /// Thread-safe accessor for the current app coordinator (set from BoilerplateApp)
    @MainActor public static var current: AppCoordinator?

    @Published public var root: AppScreens = .splash(.splash)

    private var _mainCoordinator: MainCoordinator?

    public init() {}

    // MARK: - Coordinator Access

    public func getCoordinator(for root: AppScreens) -> AnyObject {
        if _mainCoordinator == nil {
            _mainCoordinator = MainCoordinator(appCoordinator: self, entry: root)
        }
        return _mainCoordinator!
    }

    private func resetCoordinator(for root: AppScreens) {
        _mainCoordinator = nil
    }

    // MARK: - Root Switch

    public func switchRoot(to root: AppScreens, reset: Bool = true) {
        if reset {
            dismissAllModals()
            _mainCoordinator?.performFullCleanup()
            resetCoordinator(for: self.root)
            resetCoordinator(for: root)
        }
        withAnimation(.easeInOut(duration: 0.3)) {
            self.root = root
        }
    }

    // MARK: - Global Reset

    public func performGlobalReset() {
        dismissAllModals()
        resetCoordinator(for: root)
        DispatchQueue.main.async { [weak self] in
            self?.switchRoot(to: .splash(.splash), reset: true)
        }
    }

    private func dismissAllModals() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }

        var rootController = window.rootViewController
        while let presentedController = rootController?.presentedViewController {
            presentedController.dismiss(animated: false, completion: nil)
            rootController = presentedController
        }
    }
}

// MARK: - AppNavigationProtocol Conformance
extension AppCoordinator: AppNavigationProtocol {
    public func pop(to destination: AppScreens) {
        _mainCoordinator?.pop(to: destination)
    }

    public func navigate(to destination: AppScreens, with type: NavigationType) {
        _mainCoordinator?.navigate(to: destination, with: type)
    }

    public func back() {
        _mainCoordinator?.back()
    }

    public func popToRoot() {
        _mainCoordinator?.popToRoot()
    }

    public func isRoot(_ screen: AppScreens) -> Bool {
        return root == screen
    }
}
