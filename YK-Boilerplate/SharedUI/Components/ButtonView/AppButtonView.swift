import SwiftUI

// MARK: - App Button View
// Reusable button component with consistent styling.

public struct AppButtonView: View {
    let title: String
    let style: AppButtonStyle
    let isLoading: Bool
    let action: () -> Void

    public init(
        title: String,
        style: AppButtonStyle = .primary,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.style = style
        self.isLoading = isLoading
        self.action = action
    }

    public var body: some View {
        Button(action: {
            guard !isLoading && style != .disabled else { return }
            action()
        }) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: style.foregroundColor))
                }
                Text(title)
                    .font(.customFont(size: 16, weight: .medium))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .foregroundColor(style.foregroundColor)
            .background(style.backgroundColor)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(style.borderColor, lineWidth: style == .secondary ? 1.5 : 0)
            )
        }
        .disabled(style == .disabled || isLoading)
    }
}
