import SwiftUI

// MARK: - Custom Navigation Modifier
// Applies navigation bar appearance based on CoordinatorEntryPoint properties.

public extension View {
    /// Apply custom navigation styling from a CoordinatorEntryPoint screen
    func customNavigation<S: CoordinatorEntryPoint>(_ screen: S) -> some View {
        self
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if let title = screen.navigationTitle {
                    ToolbarItem(placement: .principal) {
                        if let image = screen.navigationImage {
                            HStack(spacing: 8) {
                                image.resizable().scaledToFit().frame(height: 24)
                                Text(title)
                                    .font(.customFont(size: 17, weight: .medium))
                                    .foregroundColor(screen.navigationTitleColor ?? .primary)
                            }
                        } else {
                            Text(title)
                                .font(.customFont(size: 17, weight: .medium))
                                .foregroundColor(screen.navigationTitleColor ?? .primary)
                        }
                    }
                } else if let image = screen.navigationImage {
                    ToolbarItem(placement: .principal) {
                        image.resizable().scaledToFit().frame(height: 28)
                    }
                }
            }
            .navigationBarBackButtonHidden(screen.isBackButtonHidden)
            .toolbarVisibility(screen)
    }

    /// Apply toolbar visibility based on NavigationVisibility
    @ViewBuilder
    func toolbarVisibility<S: CoordinatorEntryPoint>(_ screen: S) -> some View {
        switch screen.isNavigationVisible {
        case .none:
            self.toolbar(.hidden, for: .navigationBar)
        case .always:
            self.toolbar(.visible, for: .navigationBar)
        }
    }
}

// MARK: - Keyboard Dismiss
public extension View {
    /// Dismiss keyboard on tap
    func dismissKeyboardOnTap() -> some View {
        self.onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}

// MARK: - Conditional Modifier
public extension View {
    /// Apply a modifier conditionally
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
