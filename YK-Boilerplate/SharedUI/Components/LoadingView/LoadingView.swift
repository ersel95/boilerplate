import SwiftUI

// MARK: - Loading View
// Full-screen loading overlay.

public struct LoadingView: View {
    var message: String?

    public init(message: String? = nil) {
        self.message = message
    }

    public var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)

                if let message = message {
                    Text(message)
                        .font(.customFont(size: 14, weight: .medium))
                        .foregroundColor(.white)
                }
            }
            .padding(32)
            .background(Color(.systemGray5).opacity(0.95))
            .cornerRadius(16)
        }
    }
}
