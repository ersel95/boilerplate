import Foundation

// MARK: - Home ViewModel
// Demonstrates different navigation types.

@MainActor
class HomeViewModel: BaseViewModel {

    // MARK: - Push Navigation
    func navigateToDetail() {
        navigate(to: .home(.detail), with: .push)
    }

    func navigateToPostList() {
        navigate(to: .example(.postList), with: .push)
    }

    // MARK: - Modal Navigation
    func showSheet() {
        navigate(to: .home(.detail), with: .sheet)
    }

    func showBottomSheet() {
        navigate(to: .home(.detail), with: .bottomSheet(detents: [.medium, .large], isDraggable: true))
    }

    func showFullScreenCover() {
        navigate(to: .home(.detail), with: .fullScreenCover)
    }

    func showPopup() {
        navigate(to: .generics(.popup), with: .popup(position: .center, isDismissable: true))
    }

    // MARK: - Session
    func logout() {
        UserSession.shared.logout()
        switchRoot(to: .auth(.login))
    }
}
