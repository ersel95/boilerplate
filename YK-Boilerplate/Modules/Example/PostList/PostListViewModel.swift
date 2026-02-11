import Foundation

// MARK: - Post List ViewModel
// Full MVVM-C example: protocol-injected service, UIStateManager, navigation.

@MainActor
class PostListViewModel: BaseViewModel {
    let uiState = UIStateManager<[PostDTO]>(state: .idle)
    private let service: ExampleServiceProtocol

    init(service: ExampleServiceProtocol, navigator: AppNavigationProtocol? = nil) {
        self.service = service
        super.init(navigator: navigator)
    }

    // MARK: - Data Fetching

    func fetchPosts() {
        uiState.setLoading()

        Task {
            let result = await service.fetchPosts()

            switch result {
            case .success(let posts):
                uiState.setData(posts)
            case .failure(let error):
                uiState.setToast(type: .error(.light), message: error.localizedDescription)
            }
        }
    }

    func refreshPosts() async {
        let result = await service.fetchPosts()

        switch result {
        case .success(let posts):
            uiState.setData(posts)
        case .failure(let error):
            uiState.setToast(type: .error(.light), message: error.localizedDescription)
        }
    }

    // MARK: - Navigation

    func navigateToDetail(postId: Int) {
        navigate(to: .example(.postDetail(id: postId)), with: .push)
    }
}
