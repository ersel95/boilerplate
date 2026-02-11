import SwiftUI

// MARK: - Home View
// Main dashboard screen. Demonstrates all navigation types.

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "house.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.accentColor)

                    Text("Home")
                        .font(.customFont(size: 24, weight: .bold))

                    Text("Navigation Examples")
                        .font(.customFont(size: 14, weight: .regular))
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)

                Divider().padding(.horizontal)

                // MARK: - Navigation Examples
                VStack(spacing: 12) {
                    sectionHeader("Push Navigation")

                    AppButtonView(title: "Push Detail Screen", style: .primary) {
                        viewModel.navigateToDetail()
                    }

                    AppButtonView(title: "Push Post List (API Example)", style: .primary) {
                        viewModel.navigateToPostList()
                    }
                }
                .padding(.horizontal, 16)

                VStack(spacing: 12) {
                    sectionHeader("Modal Navigation")

                    AppButtonView(title: "Show Sheet", style: .secondary) {
                        viewModel.showSheet()
                    }

                    AppButtonView(title: "Show Bottom Sheet", style: .secondary) {
                        viewModel.showBottomSheet()
                    }

                    AppButtonView(title: "Show Full Screen Cover", style: .secondary) {
                        viewModel.showFullScreenCover()
                    }

                    AppButtonView(title: "Show Popup", style: .secondary) {
                        viewModel.showPopup()
                    }
                }
                .padding(.horizontal, 16)

                VStack(spacing: 12) {
                    sectionHeader("Session")

                    AppButtonView(title: "Logout", style: .danger) {
                        viewModel.logout()
                    }
                }
                .padding(.horizontal, 16)

                Spacer(minLength: 40)
            }
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(.customFont(size: 16, weight: .bold))
                .foregroundColor(.primary)
            Spacer()
        }
        .padding(.top, 8)
    }
}
