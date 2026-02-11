import Foundation

// MARK: - Example Service Protocol
// Protocol-based service design for testability.
// Inject this protocol instead of the concrete service class.

public protocol ExampleServiceProtocol {
    func fetchPosts() async -> Result<[PostDTO], Error>
    func fetchPost(id: Int) async -> Result<PostDTO, Error>
    func fetchComments(postId: Int) async -> Result<[CommentDTO], Error>
    func createPost(request: CreatePostRequestDTO) async -> Result<PostDTO, Error>
}
