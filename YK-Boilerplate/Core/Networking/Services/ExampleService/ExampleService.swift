import Foundation

// MARK: - Example Service (Real API)
// Makes actual HTTP requests to JSONPlaceholder API.

final class ExampleService: BaseService<ExampleAPI>, ExampleServiceProtocol {

    func fetchPosts() async -> Result<[PostDTO], Error> {
        let result: Result<[PostDTO], Error> = await requestWithoutBaseResponse(target: ExampleAPI.getPosts)
        return result
    }

    func fetchPost(id: Int) async -> Result<PostDTO, Error> {
        let result: Result<PostDTO, Error> = await requestWithoutBaseResponse(target: ExampleAPI.getPost(id: id))
        return result
    }

    func fetchComments(postId: Int) async -> Result<[CommentDTO], Error> {
        let result: Result<[CommentDTO], Error> = await requestWithoutBaseResponse(target: ExampleAPI.getComments(postId: postId))
        return result
    }

    func createPost(request: CreatePostRequestDTO) async -> Result<PostDTO, Error> {
        let result: Result<PostDTO, Error> = await requestWithoutBaseResponse(target: ExampleAPI.createPost(request: request))
        return result
    }
}
