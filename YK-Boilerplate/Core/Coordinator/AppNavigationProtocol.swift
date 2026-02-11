import SwiftUI

// MARK: - App Navigation Protocol
// Abstracts navigation functionality to eliminate circular dependencies.
// ViewModels use this protocol instead of directly accessing the coordinator.

@MainActor
public protocol AppNavigationProtocol: AnyObject {
    func navigate(to destination: AppScreens, with type: NavigationType)
    func back()
    func switchRoot(to root: AppScreens, reset: Bool)
    func switchRoot(to root: AppScreens)
    func performGlobalReset()
    func pop(to destination: AppScreens)
    func popToRoot()
    func isRoot(_ screen: AppScreens) -> Bool
}

public extension AppNavigationProtocol {
    func switchRoot(to root: AppScreens) {
        switchRoot(to: root, reset: true)
    }

    func push(_ destination: AppScreens) {
        navigate(to: destination, with: .push)
    }

    func pop() {
        back()
    }
}
