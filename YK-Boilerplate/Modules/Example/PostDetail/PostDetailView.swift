import SwiftUI

// MARK: - Post Detail View
// Demonstrates: Detail API call, loading states, bottomSheet for comments.

struct PostDetailView: View {
    @ObservedObject var viewModel: PostDetailViewModel
    @StateObject private var uiState: UIStateManager<PostDTO>

    init(viewModel: PostDetailViewModel) {
        self.viewModel = viewModel
        self._uiState = StateObject(wrappedValue: viewModel.uiState)
    }

    var body: some View {
        Group {
            switch uiState.state {
            case .idle:
                Color.clear.onAppear { viewModel.fetchPost() }

            case .loading:
                VStack {
                    Spacer()
                    ProgressView("Loading post...")
                    Spacer()
                }

            case .data(let post):
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(post.title)
                            .font(.customFont(size: 22, weight: .bold))

                        Text("By User \(post.userId)")
                            .font(.customFont(size: 13, weight: .regular))
                            .foregroundColor(.secondary)

                        Divider()

                        Text(post.body)
                            .font(.customFont(size: 15, weight: .regular))
                            .lineSpacing(4)

                        Divider()

                        // Comments section - opens as bottomSheet
                        AppButtonView(title: "View Comments (BottomSheet)", style: .secondary) {
                            viewModel.showComments()
                        }

                        // Show as popup example
                        AppButtonView(title: "Show Info (Popup)", style: .secondary) {
                            viewModel.showPopup()
                        }

                        // Comments list
                        if !viewModel.comments.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Comments")
                                    .font(.customFont(size: 18, weight: .bold))

                                ForEach(viewModel.comments) { comment in
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(comment.name)
                                            .font(.customFont(size: 14, weight: .medium))
                                        Text(comment.body)
                                            .font(.customFont(size: 13, weight: .regular))
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                        }
                    }
                    .padding(16)
                }

            case .toast(let toast):
                VStack {
                    Text(toast.message).foregroundColor(.red).padding()
                    AppButtonView(title: "Retry") { viewModel.fetchPost() }
                        .padding(.horizontal, 24)
                }

            case .popup:
                EmptyView()
            }
        }
    }
}
