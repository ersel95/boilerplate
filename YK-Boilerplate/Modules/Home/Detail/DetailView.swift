import SwiftUI

// MARK: - Detail View
// Example detail screen opened via push, sheet, bottomSheet, or fullScreenCover.

struct DetailView: View {
    @ObservedObject var viewModel: DetailViewModel

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "doc.text.fill")
                .font(.system(size: 50))
                .foregroundColor(.accentColor)

            Text("Detail Screen")
                .font(.customFont(size: 22, weight: .bold))

            Text("This screen can be opened via push, sheet, bottomSheet, or fullScreenCover. The navigation type is determined by the coordinator.")
                .font(.customFont(size: 14, weight: .regular))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            AppButtonView(title: "Go Back", style: .secondary) {
                viewModel.back()
            }
            .padding(.horizontal, 24)

            Spacer()
        }
        .padding(.top, 40)
    }
}
