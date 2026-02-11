import SwiftUI

// MARK: - Toast View
// Shows a temporary message at the top of the screen.

public struct ToastView: View {
    let message: ToastMessage
    let onDismiss: () -> Void

    public var body: some View {
        HStack(spacing: 12) {
            Image(systemName: iconName)
                .foregroundColor(.white)
                .font(.system(size: 18, weight: .semibold))

            Text(message.message)
                .font(.customFont(size: 14, weight: .medium))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)

            Spacer()

            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .foregroundColor(.white.opacity(0.8))
                    .font(.system(size: 12, weight: .bold))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(backgroundColor)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
        .padding(.horizontal, 16)
    }

    private var iconName: String {
        switch message.type {
        case .success: return "checkmark.circle.fill"
        case .error:   return "xmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .info:    return "info.circle.fill"
        case .main:    return "bell.fill"
        }
    }

    private var backgroundColor: Color {
        switch message.type {
        case .success: return .green
        case .error:   return .red
        case .warning: return .orange
        case .info:    return .blue
        case .main:    return .gray
        }
    }
}

// MARK: - Toast Host
// Container that shows toast messages with auto-dismiss.

public struct ToastHost<Content: View>: View {
    @Binding var toast: ToastMessage?
    let content: () -> Content

    public init(toast: Binding<ToastMessage?>, @ViewBuilder content: @escaping () -> Content) {
        self._toast = toast
        self.content = content
    }

    public var body: some View {
        ZStack(alignment: .top) {
            content()

            if let toastMessage = toast {
                ToastView(message: toastMessage) {
                    withAnimation { toast = nil }
                }
                .transition(.move(edge: .top).combined(with: .opacity))
                .onAppear {
                    if let duration = toastMessage.autoDismissAfter {
                        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                            withAnimation { toast = nil }
                        }
                    }
                }
                .zIndex(100)
            }
        }
        .animation(.spring(response: 0.3), value: toast != nil)
    }
}
