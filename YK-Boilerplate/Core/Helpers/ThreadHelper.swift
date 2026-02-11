import Foundation

// MARK: - Main Thread Utilities

/// Executes the given closure on the main thread.
/// If already on main thread, executes synchronously. Otherwise dispatches async.
public func runOnMainThread(_ action: @escaping () -> Void) {
    if Thread.isMainThread {
        action()
    } else {
        DispatchQueue.main.async(execute: action)
    }
}

/// Executes the given closure on the main thread synchronously.
/// - Warning: Be careful with sync dispatch to avoid deadlocks
public func runOnMainThreadSync(_ action: () -> Void) {
    if Thread.isMainThread {
        action()
    } else {
        DispatchQueue.main.sync(execute: action)
    }
}

public extension Thread {
    static var isOnMain: Bool {
        return Thread.isMainThread
    }
}
