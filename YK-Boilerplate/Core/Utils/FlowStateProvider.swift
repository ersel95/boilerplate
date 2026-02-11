import Foundation
import SwiftUI

// MARK: - Flow State Provider
// Lazy-loading state management provider.
// Ensures each state object is created once and reused.
// Used by coordinators to manage ViewModel lifecycles.

@MainActor
final class FlowStateProvider {
    private var storage: [String: Any] = [:]

    /// Retrieves existing instance or creates new one via factory closure.
    func resolve<T: ObservableObject>(_ type: T.Type, factory: @autoclosure () -> T) -> T {
        let key = String(describing: type)

        if let existingInstance = storage[key] as? T {
            return existingInstance
        }

        let newInstance = factory()
        storage[key] = newInstance
        return newInstance
    }
}
