import Foundation

// MARK: - Example DTOs
// These models match the JSONPlaceholder API (https://jsonplaceholder.typicode.com)
// TODO: Replace with your own API models.

public struct PostDTO: Codable, Identifiable, Equatable {
    public let id: Int
    public let userId: Int
    public let title: String
    public let body: String
}

public struct CommentDTO: Codable, Identifiable, Equatable {
    public let id: Int
    public let postId: Int
    public let name: String
    public let email: String
    public let body: String
}

public struct CreatePostRequestDTO: Codable {
    public let title: String
    public let body: String
    public let userId: Int
}
