import Foundation
import Combine

// MARK: - Session Manager
// Manages session timeout and idle detection.

public enum SessionState {
    case active
    case idle
    case warning
    case expired
}

public final class SessionManager: ObservableObject {
    public static let shared = SessionManager()

    @Published public var sessionState: SessionState = .active
    @Published public var showSessionWarning: Bool = false

    private var idleTimer: Timer?
    private var warningTimer: Timer?
    private let lock = NSLock()
    private var isSessionActive = false

    private init() {}

    // MARK: - Session Lifecycle

    /// Start a new session with idle timeout tracking
    public func startSession() {
        lock.lock()
        defer { lock.unlock() }

        isSessionActive = true
        sessionState = .active
        resetTimers()
    }

    /// End the current session
    public func endSession() {
        lock.lock()
        defer { lock.unlock() }

        isSessionActive = false
        invalidateTimers()

        runOnMainThread {
            self.sessionState = .expired
            self.showSessionWarning = false
        }

        // TODO: Navigate to login screen
        // AppCoordinator.shared?.switchRoot(to: .auth(.login))
    }

    /// Called on every user interaction to reset idle timer
    public func handleUserInteraction() {
        guard isSessionActive else { return }
        resetTimers()

        if sessionState == .warning {
            runOnMainThread {
                self.sessionState = .active
                self.showSessionWarning = false
            }
        }
    }

    // MARK: - Timer Management

    private func resetTimers() {
        invalidateTimers()

        let warningTimeout = AppConstants.sessionWarningTimeout
        let idleTimeout = AppConstants.sessionIdleTimeout

        DispatchQueue.main.async { [weak self] in
            self?.warningTimer = Timer.scheduledTimer(withTimeInterval: warningTimeout, repeats: false) { [weak self] _ in
                self?.handleWarningTimeout()
            }

            self?.idleTimer = Timer.scheduledTimer(withTimeInterval: idleTimeout, repeats: false) { [weak self] _ in
                self?.handleIdleTimeout()
            }
        }
    }

    private func invalidateTimers() {
        DispatchQueue.main.async { [weak self] in
            self?.idleTimer?.invalidate()
            self?.idleTimer = nil
            self?.warningTimer?.invalidate()
            self?.warningTimer = nil
        }
    }

    private func handleWarningTimeout() {
        runOnMainThread {
            self.sessionState = .warning
            self.showSessionWarning = true
        }
    }

    private func handleIdleTimeout() {
        endSession()
    }
}
