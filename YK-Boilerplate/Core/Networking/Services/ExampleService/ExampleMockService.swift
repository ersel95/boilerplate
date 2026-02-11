import Foundation

// MARK: - Example Mock Service
// Returns local mock data without making network requests.
// Use this in previews, tests, and offline development.

public final class ExampleMockService: ExampleServiceProtocol {

    /// Simulated delay in seconds
    private let delay: UInt64

    public init(delay: UInt64 = 1) {
        self.delay = delay
    }

    public func fetchPosts() async -> Result<[PostDTO], Error> {
        try? await Task.sleep(nanoseconds: delay * 1_000_000_000)
        return .success([
            PostDTO(id: 1, userId: 1, title: "Mock Post 1", body: "This is the first mock post body."),
            PostDTO(id: 2, userId: 1, title: "Mock Post 2", body: "This is the second mock post body."),
            PostDTO(id: 3, userId: 2, title: "Mock Post 3", body: "This is the third mock post body."),
            PostDTO(id: 4, userId: 2, title: "Mock Post 4", body: "This is the fourth mock post body."),
            PostDTO(id: 5, userId: 3, title: "Mock Post 5", body: "This is the fifth mock post body."),
        ])
    }

    public func fetchPost(id: Int) async -> Result<PostDTO, Error> {
        try? await Task.sleep(nanoseconds: delay * 1_000_000_000)
        return .success(PostDTO(id: id, userId: 1, title: "Mock Post \(id)", body: "Detailed body for mock post \(id). Lorem ipsum dolor sit amet."))
    }

    public func fetchComments(postId: Int) async -> Result<[CommentDTO], Error> {
        try? await Task.sleep(nanoseconds: delay * 1_000_000_000)
        return .success([
            CommentDTO(id: 1, postId: postId, name: "Mock User", email: "mock@example.com", body: "Great mock post!"),
            CommentDTO(id: 2, postId: postId, name: "Test User", email: "test@example.com", body: "Thanks for the mock data."),
        ])
    }

    public func createPost(request: CreatePostRequestDTO) async -> Result<PostDTO, Error> {
        try? await Task.sleep(nanoseconds: delay * 1_000_000_000)
        return .success(PostDTO(id: 101, userId: request.userId, title: request.title, body: request.body))
    }
}
