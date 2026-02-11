import SwiftUI

// MARK: - Splash View
// Initial screen shown on app launch.

struct SplashView: View {
    @ObservedObject var viewModel: SplashViewModel

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.accentColor.opacity(0.8), Color.accentColor],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                // App Logo
                Image(systemName: "building.2.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.white)

                Text("YK Boilerplate")
                    .font(.customFont(size: 28, weight: .bold))
                    .foregroundColor(.white)

                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.2)
                        .padding(.top, 20)
                }
            }
        }
    }
}
