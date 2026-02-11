import SwiftUI

// MARK: - Loading Modifier
// Shows a loading overlay when isLoading is true.
// Usage: .loading(isLoading)

public struct LoadingModifier: ViewModifier {
    let isLoading: Bool
    let message: String?

    public func body(content: Content) -> some View {
        ZStack {
            content

            if isLoading {
                LoadingView(message: message)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isLoading)
    }
}

public extension View {
    func loading(_ isLoading: Bool, message: String? = nil) -> some View {
        modifier(LoadingModifier(isLoading: isLoading, message: message))
    }
}
