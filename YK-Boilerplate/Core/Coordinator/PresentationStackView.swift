import SwiftUI

// MARK: - Presentation Stack View
// Recursively manages the presentation stack for modals.

struct PresentationStackView<T: Coordinator & PresentingCoordinator>: View where T.Entry == T.Screen {
    @ObservedObject var coordinator: T
    let screen: T.Screen

    private var isSheetPresented: Binding<Bool> {
        Binding(
            get: { [weak coordinator] in
                guard let coordinator = coordinator, coordinator.presentationStack.count > 1 else { return false }
                let type = coordinator.presentationStack.dropFirst().first?.type
                let isSheet = (type == .sheet)
                let isBottomSheet: Bool = {
                    if let t = type, case .bottomSheet = t { return true }
                    return false
                }()
                return isSheet || isBottomSheet
            },
            set: { [weak coordinator] isShowing in
                guard let coordinator = coordinator else { return }
                if !isShowing, coordinator.presentationStack.count > 1 {
                    coordinator.back()
                }
            }
        )
    }

    private var isFullScreenCoverPresented: Binding<Bool> {
        Binding(
            get: { [weak coordinator] in
                guard let coordinator = coordinator, coordinator.presentationStack.count > 1 else { return false }
                return coordinator.presentationStack.dropFirst().first?.type == .fullScreenCover
            },
            set: { [weak coordinator] isShowing in
                guard let coordinator = coordinator else { return }
                if !isShowing, coordinator.presentationStack.count > 1 {
                    coordinator.back()
                }
            }
        )
    }

    @ViewBuilder
    private var destinationView: some View {
        let presentationType = coordinator.presentationStack.first?.type

        let isPopup: Bool = {
            if let type = presentationType, case .popup = type { return true }
            return false
        }()

        let isBottomSheet: Bool = {
            if let type = presentationType, case .bottomSheet = type { return true }
            return false
        }()

        let isSideMenu: Bool = {
            if let type = presentationType, type == .sideMenu { return true }
            return false
        }()

        if isPopup || isBottomSheet || isSideMenu {
            coordinator.navigationDestination(for: screen)
                .customNavigation(screen)
        } else {
            NavigationStack {
                coordinator.navigationDestination(for: screen)
                    .customNavigation(screen)
            }
        }
    }

    var body: some View {
        destinationView
            .sheet(isPresented: isSheetPresented) {
                if let nextItem = coordinator.presentationStack.dropFirst().first {
                    PresentationStackView(coordinator: coordinator, screen: nextItem.screen)
                }
            }
            .fullScreenCover(isPresented: isFullScreenCoverPresented) {
                if let nextItem = coordinator.presentationStack.dropFirst().first {
                    PresentationStackView(coordinator: coordinator, screen: nextItem.screen)
                }
            }
    }
}
