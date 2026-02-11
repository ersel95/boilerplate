import Foundation

// MARK: - Post Detail ViewModel
// Demonstrates: Detail API call, comments loading, modal navigation.

@MainActor
class PostDetailViewModel: BaseViewModel {
    let uiState = UIStateManager<PostDTO>(state: .idle)
    @Published var comments: [CommentDTO] = []

    private let postId: Int
    private let service: ExampleServiceProtocol

    init(postId: Int, service: ExampleServiceProtocol, navigator: AppNavigationProtocol? = nil) {
        self.postId = postId
        self.service = service
        super.init(navigator: navigator)
    }

    // MARK: - Data Fetching

    func fetchPost() {
        uiState.setLoading()

        Task {
            let result = await service.fetchPost(id: postId)

            switch result {
            case .success(let post):
                uiState.setData(post)
                await fetchComments()
            case .failure(let error):
                uiState.setToast(type: .error(.light), message: error.localizedDescription)
            }
        }
    }

    private func fetchComments() async {
        let result = await service.fetchComments(postId: postId)
        if case .success(let fetchedComments) = result {
            comments = fetchedComments
        }
    }

    // MARK: - Navigation Examples

    func showComments() {
        // Show detail screen itself as bottomSheet (demonstrates the pattern)
        navigate(to: .generics(.popup), with: .bottomSheet(detents: [.medium], isDraggable: true))
    }

    func showPopup() {
        navigate(to: .generics(.popup), with: .popup(position: .center, isDismissable: true))
    }
}
