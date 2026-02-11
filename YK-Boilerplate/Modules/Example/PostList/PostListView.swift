import SwiftUI

// MARK: - Post List View
// Demonstrates: API call, UIStateManager, list rendering, pull-to-refresh, push navigation.

struct PostListView: View {
    @ObservedObject var viewModel: PostListViewModel
    @StateObject private var uiState: UIStateManager<[PostDTO]>

    init(viewModel: PostListViewModel) {
        self.viewModel = viewModel
        self._uiState = StateObject(wrappedValue: viewModel.uiState)
    }

    var body: some View {
        Group {
            switch uiState.state {
            case .idle:
                Color.clear.onAppear { viewModel.fetchPosts() }

            case .loading:
                VStack {
                    Spacer()
                    ProgressView("Loading posts...")
                        .font(.customFont(size: 14, weight: .regular))
                    Spacer()
                }

            case .data(let posts):
                List(posts) { post in
                    PostRowView(post: post)
                        .onTapGesture {
                            viewModel.navigateToDetail(postId: post.id)
                        }
                        .listRowSeparator(.hidden)
                }
                .listStyle(.plain)
                .refreshable {
                    await viewModel.refreshPosts()
                }

            case .toast(let toast):
                VStack {
                    Text(toast.message)
                        .foregroundColor(.red)
                        .padding()
                    AppButtonView(title: "Retry", style: .primary) {
                        viewModel.fetchPosts()
                    }
                    .padding(.horizontal, 24)
                }

            case .popup:
                EmptyView()
            }
        }
    }
}

// MARK: - Post Row
struct PostRowView: View {
    let post: PostDTO

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(post.title)
                .font(.customFont(size: 16, weight: .medium))
                .lineLimit(2)

            Text(post.body)
                .font(.customFont(size: 13, weight: .regular))
                .foregroundColor(.secondary)
                .lineLimit(3)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
    }
}
