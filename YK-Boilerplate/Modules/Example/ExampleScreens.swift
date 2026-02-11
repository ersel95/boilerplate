import SwiftUI

// MARK: - Example Screen Enum
// Full MVVM-C example with API calls.

public enum ExampleScreens: CoordinatorEntryPoint, Hashable, Identifiable {
    case postList
    case postDetail(id: Int)

    public var id: String {
        switch self {
        case .postList:          return "example-postList"
        case .postDetail(let id): return "example-postDetail-\(id)"
        }
    }

    public var navigationTitle: String? {
        switch self {
        case .postList:   return "Posts"
        case .postDetail: return "Post Detail"
        }
    }

    public var isNavigationVisible: NavigationVisibility { .always }
}

// MARK: - Navigation Handler
extension MainCoordinator {
    func handleExampleNavigation(_ screen: ExampleScreens) -> AnyView {
        switch screen {
        case .postList:
            let viewModel: PostListViewModel = getOrCreateViewModel(for: screen.id) {
                // Inject real or mock service based on environment
                let service: ExampleServiceProtocol
                if EnvironmentsConstants.networkMode == .mock {
                    service = ExampleMockService()
                } else {
                    service = ExampleService()
                }
                return PostListViewModel(service: service, navigator: appCoordinator)
            }
            return AnyView(PostListView(viewModel: viewModel))

        case .postDetail(let id):
            let viewModel: PostDetailViewModel = getOrCreateViewModel(for: screen.id) {
                let service: ExampleServiceProtocol
                if EnvironmentsConstants.networkMode == .mock {
                    service = ExampleMockService()
                } else {
                    service = ExampleService()
                }
                return PostDetailViewModel(postId: id, service: service, navigator: appCoordinator)
            }
            return AnyView(PostDetailView(viewModel: viewModel))
        }
    }
}
