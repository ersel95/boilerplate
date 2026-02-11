import Foundation

// MARK: - Example API Target
// Defines endpoints for JSONPlaceholder API.
// TODO: Replace with your own API endpoints.

enum ExampleAPI {
    case getPosts
    case getPost(id: Int)
    case getComments(postId: Int)
    case createPost(request: CreatePostRequestDTO)
}

extension ExampleAPI: APITargetType {
    var baseURL: String {
        "https://jsonplaceholder.typicode.com/"
    }

    var path: String {
        switch self {
        case .getPosts:
            return "posts"
        case .getPost(let id):
            return "posts/\(id)"
        case .getComments(let postId):
            return "posts/\(postId)/comments"
        case .createPost:
            return "posts"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .getPosts, .getPost, .getComments:
            return .get
        case .createPost:
            return .post
        }
    }

    var task: HTTPTask {
        switch self {
        case .getPosts, .getPost, .getComments:
            return .requestPlain
        case .createPost(let request):
            return .requestJSONEncodable(request)
        }
    }

    var requiresAuth: Bool { false }

    var consoleLog: Bool { true }

    var sampleData: Data {
        switch self {
        case .getPosts:
            return """
            [
                {"userId": 1, "id": 1, "title": "Sample Post Title", "body": "This is a sample post body."},
                {"userId": 1, "id": 2, "title": "Another Post", "body": "Another post body content."},
                {"userId": 2, "id": 3, "title": "Third Post", "body": "Third post body."}
            ]
            """.data(using: .utf8) ?? Data()

        case .getPost:
            return """
            {"userId": 1, "id": 1, "title": "Sample Post Title", "body": "This is a sample post body for detail view."}
            """.data(using: .utf8) ?? Data()

        case .getComments:
            return """
            [
                {"postId": 1, "id": 1, "name": "John", "email": "john@example.com", "body": "Great post!"},
                {"postId": 1, "id": 2, "name": "Jane", "email": "jane@example.com", "body": "Thanks for sharing."}
            ]
            """.data(using: .utf8) ?? Data()

        case .createPost:
            return """
            {"userId": 1, "id": 101, "title": "New Post", "body": "New post body."}
            """.data(using: .utf8) ?? Data()
        }
    }
}
