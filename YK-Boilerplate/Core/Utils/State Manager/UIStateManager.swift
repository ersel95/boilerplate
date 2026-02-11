import Foundation
import SwiftUI
import Combine

// MARK: - UI State Enum
// Represents the current state of a screen or component.

public enum UIState<T> {
    case idle
    case loading
    case data(T)
    case toast(ToastMessage)
    case popup(PopupMessage)

    public var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }

    public var data: T? {
        if case .data(let data) = self { return data }
        return nil
    }

    public var hasToast: Bool {
        if case .toast = self { return true }
        return false
    }

    public var hasPopup: Bool {
        if case .popup = self { return true }
        return false
    }
}

extension UIState: Equatable where T: Equatable {
    public static func == (lhs: UIState<T>, rhs: UIState<T>) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.loading, .loading):
            return true
        case (.data(let lhsData), .data(let rhsData)):
            return lhsData == rhsData
        case (.toast(let lhsToast), .toast(let rhsToast)):
            return lhsToast == rhsToast
        case (.popup(let lhsPopup), .popup(let rhsPopup)):
            return lhsPopup == rhsPopup
        default:
            return false
        }
    }
}

// MARK: - Toast Message
public struct ToastMessage: Equatable {
    public let type: ToastMessageTypes
    public let message: String
    public let autoDismissAfter: TimeInterval?
    public let recoveryAction: (() -> Void)?

    public init(type: ToastMessageTypes, message: String, autoDismissAfter: TimeInterval? = 3.0, recoveryAction: (() -> Void)? = nil) {
        self.type = type
        self.message = message
        self.autoDismissAfter = autoDismissAfter
        self.recoveryAction = recoveryAction
    }

    public static func == (lhs: ToastMessage, rhs: ToastMessage) -> Bool {
        lhs.type == rhs.type && lhs.message == rhs.message && lhs.autoDismissAfter == rhs.autoDismissAfter
    }
}

// MARK: - Toast Message Types
public enum ToastMessageTypes: Equatable {
    public enum ThemeType {
        case light, dark
    }

    case main(ThemeType)
    case success(ThemeType)
    case error(ThemeType)
    case warning(ThemeType)
    case info(ThemeType)
}

// MARK: - Popup Message
public enum PopupType: Equatable, Hashable {
    case noInternet
    case comingSoon
    case custom(title: String, message: String, icon: String)
    case serverError(errorMessage: String)

    public var title: String {
        switch self {
        case .noInternet:     return "No Connection"
        case .comingSoon:     return ErrorMessages.General.comingSoon
        case .custom(let t, _, _): return t
        case .serverError:    return "Error"
        }
    }

    public var message: String {
        switch self {
        case .noInternet:     return ErrorMessages.Network.noInternet
        case .comingSoon:     return ErrorMessages.General.comingSoon
        case .custom(_, let m, _): return m
        case .serverError(let msg): return msg
        }
    }
}

public struct PopupMessage: Equatable {
    public let type: PopupType
    public let buttonTitle: String
    public let onDismiss: (() -> Void)?

    public init(type: PopupType, buttonTitle: String = "OK", onDismiss: (() -> Void)? = nil) {
        self.type = type
        self.buttonTitle = buttonTitle
        self.onDismiss = onDismiss
    }

    public static func == (lhs: PopupMessage, rhs: PopupMessage) -> Bool {
        lhs.type == rhs.type && lhs.buttonTitle == rhs.buttonTitle
    }
}

// MARK: - UI State Manager
public class UIStateManager<T>: ObservableObject {
    @Published public private(set) var state: UIState<T> = .idle
    @Published public private(set) var showError: Bool = false
    @Published public private(set) var isLoading: Bool = false

    public init(state: UIState<T>? = .idle) {
        self.state = state ?? .idle
    }

    public var data: T? { state.data }

    // MARK: - State Methods

    public func setLoading(_ loading: Bool = true) {
        runOnMainThread { [weak self] in
            self?.state = loading ? .loading : .idle
            self?.isLoading = loading
            self?.showError = false
        }
    }

    public func setData(_ data: T) {
        runOnMainThread { [weak self] in
            self?.state = .data(data)
            self?.isLoading = false
            self?.showError = false
        }
    }

    public func setToast(type: ToastMessageTypes, message: String, autoDismissAfter: TimeInterval? = 3.0) {
        runOnMainThread { [weak self] in
            if case .toast = self?.state { self?.state = .idle }
            self?.state = .toast(ToastMessage(type: type, message: message, autoDismissAfter: autoDismissAfter))
            self?.isLoading = false
        }
    }

    public func clearToast() {
        runOnMainThread { [weak self] in
            if case .toast = self?.state { self?.state = .idle }
        }
    }

    public func setPopup(type: PopupType, buttonTitle: String = "OK", onDismiss: (() -> Void)? = nil) {
        runOnMainThread { [weak self] in
            if case .popup = self?.state { self?.state = .idle }
            self?.state = .popup(PopupMessage(type: type, buttonTitle: buttonTitle, onDismiss: onDismiss))
            self?.isLoading = false
        }
    }

    public func clearPopup() {
        runOnMainThread { [weak self] in
            if case .popup = self?.state { self?.state = .idle }
        }
    }

    public func reset() {
        runOnMainThread { [weak self] in
            self?.state = .idle
            self?.isLoading = false
            self?.showError = false
        }
    }

    public func clearError() {
        runOnMainThread { [weak self] in
            self?.showError = false
            self?.state = .idle
            self?.isLoading = false
        }
    }
}
