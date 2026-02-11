import SwiftUI

// MARK: - Generic Popup View
// A reusable popup view for displaying messages.

struct GenericPopupView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "info.circle.fill")
                .font(.system(size: 48))
                .foregroundColor(.blue)

            Text("Popup Title")
                .font(.customFont(size: 20, weight: .bold))

            Text("This is an example popup message. You can customize this view for different popup types.")
                .font(.customFont(size: 14, weight: .regular))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            AppButtonView(title: "OK", style: .primary) {
                AppCoordinator.current?.back()
            }
        }
        .padding(24)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
        .padding(.horizontal, 32)
    }
}
