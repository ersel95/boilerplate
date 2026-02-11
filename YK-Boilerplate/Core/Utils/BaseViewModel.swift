import Foundation
import SwiftUI
import Combine

// MARK: - Base View Modeling Protocol
protocol BaseViewModeling: AnyObject {
    func cancelPendingRequests()
}

extension BaseViewModeling {
    func cancelPendingRequests() {}
}

// MARK: - Base ViewModel
// All ViewModels should inherit from this class.
// Provides navigation and cancellable management.
//
// Navigation is done via protocol injection instead of singleton access.
// The navigator is set automatically when a ViewModel is created by the coordinator.

@MainActor
open class BaseViewModel: ObservableObject, BaseViewModeling {

    public var cancellables = Set<AnyCancellable>()

    /// Weak reference to the navigation protocol
    private weak var navigator: AppNavigationProtocol?

    public init(navigator: AppNavigationProtocol? = nil) {
        self.navigator = navigator ?? AppCoordinator.current
    }

    // MARK: - Navigation Methods

    public func navigate(to destination: AppScreens, with type: NavigationType) {
        navigator?.navigate(to: destination, with: type)
    }

    public func back() {
        navigator?.back()
    }

    public func popToRoot() {
        navigator?.popToRoot()
    }

    public func switchRoot(to root: AppScreens, reset: Bool = true) {
        navigator?.switchRoot(to: root, reset: reset)
    }

    public func pop(to destination: AppScreens) {
        navigator?.pop(to: destination)
    }

    // MARK: - Cleanup

    open func cancelPendingRequests() {
        cancellables.removeAll()
    }
}
