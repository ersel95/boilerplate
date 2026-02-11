import SwiftUI

// MARK: - Coordinator View
// Root SwiftUI view that connects NavigationStack with all presentation types.

struct CoordinatorView<T: Coordinator & PresentingCoordinator>: View where T.Entry == T.Screen {
    @ObservedObject var coordinator: T

    @Environment(\.colorScheme) private var colorScheme

    private var navigationPath: Binding<[T.Entry]> {
        Binding(
            get: { Array(coordinator.stack.dropFirst()) },
            set: { [weak coordinator] newPath in
                guard let coordinator = coordinator else { return }
                if let first = coordinator.stack.first {
                    coordinator.stack = [first] + newPath
                }
            }
        )
    }

    private var isSheetPresented: Binding<Bool> {
        Binding(
            get: { [weak coordinator] in
                guard let coordinator = coordinator else { return false }
                let type = coordinator.presentationStack.first?.type
                let isBottomSheet: Bool = {
                    if let t = type, case .bottomSheet = t { return true }
                    return false
                }()
                if isBottomSheet && (coordinator as? BaseCoordinator<T.Screen>)?.isDismissingBottomSheet == true {
                    return false
                }
                return (type == .sheet) || isBottomSheet
            },
            set: { [weak coordinator] isShowing in
                guard let coordinator = coordinator else { return }
                if !isShowing {
                    let type = coordinator.presentationStack.first?.type
                    let isBottomSheet: Bool = {
                        if let t = type, case .bottomSheet = t { return true }
                        return false
                    }()
                    if type == .sheet || isBottomSheet {
                        coordinator.back()
                    }
                }
            }
        )
    }

    private var isFullScreenCoverPresented: Binding<Bool> {
        Binding(
            get: { [weak coordinator] in coordinator?.presentationStack.first?.type == .fullScreenCover },
            set: { [weak coordinator] isShowing in
                guard let coordinator = coordinator else { return }
                if !isShowing, coordinator.presentationStack.first?.type == .fullScreenCover {
                    coordinator.back()
                }
            }
        )
    }

    private var isPopupPresented: Binding<Bool> {
        Binding(
            get: { [weak coordinator] in
                guard let coordinator = coordinator else { return false }
                let type = coordinator.presentationStack.first?.type
                let isPopup: Bool = {
                    if let t = type, case .popup = t { return true }
                    return false
                }()
                if isPopup && (coordinator as? BaseCoordinator<T.Screen>)?.isDismissingPopup == true {
                    return false
                }
                return isPopup
            },
            set: { [weak coordinator] isShowing in
                guard let coordinator = coordinator else { return }
                if !isShowing, coordinator.presentationStack.first?.type.isPopup == true {
                    coordinator.back()
                }
            }
        )
    }

    private var isSideMenuPresented: Binding<Bool> {
        Binding(
            get: { [weak coordinator] in coordinator?.presentationStack.first?.type == .sideMenu },
            set: { [weak coordinator] isShowing in
                guard let coordinator = coordinator else { return }
                if !isShowing, coordinator.presentationStack.first?.type == .sideMenu {
                    coordinator.back()
                }
            }
        )
    }

    // MARK: - Body

    public var body: some View {
        Group {
            if coordinator.stack.isEmpty {
                EmptyView()
            } else {
                NavigationStack(path: navigationPath) {
                    if let first = coordinator.stack.first {
                        coordinator.navigationDestination(for: first)
                            .customNavigation(first)
                            .navigationDestination(for: T.Entry.self) { entry in
                                coordinator.navigationDestination(for: entry)
                                    .customNavigation(entry)
                            }
                    }
                }
            }
        }
        // Sheet / BottomSheet
        .sheet(isPresented: isSheetPresented) {
            if let firstItem = coordinator.presentationStack.first {
                let firstScreen = firstItem.screen
                let presentationType = firstItem.type
                if case let .bottomSheet(detents, isDraggable, _) = presentationType, !detents.isEmpty {
                    PresentationStackView(coordinator: coordinator, screen: firstScreen)
                        .presentationDetents(Set(detents))
                        .presentationDragIndicator(isDraggable ? .visible : .hidden)
                        .interactiveDismissDisabled(!isDraggable)
                } else {
                    PresentationStackView(coordinator: coordinator, screen: firstScreen)
                        .presentationDetents([.medium])
                        .presentationDragIndicator(.visible)
                }
            }
        }
        // Full Screen Cover
        .fullScreenCover(isPresented: isFullScreenCoverPresented) {
            if let firstScreen = coordinator.presentationStack.first?.screen {
                PresentationStackView(coordinator: coordinator, screen: firstScreen)
            }
        }
        // Side Menu
        .overlay(alignment: .topLeading) {
            if isSideMenuPresented.wrappedValue, let sideMenuItem = coordinator.presentationStack.first {
                PresentationStackView(coordinator: coordinator, screen: sideMenuItem.screen)
                    .transition(.move(edge: .leading).combined(with: .opacity))
                    .zIndex(2)
            }
        }
        // Popup
        .overlay(alignment: .center) {
            if isPopupPresented.wrappedValue,
               let overlayItem = coordinator.presentationStack.first,
               overlayItem.type.isPopup {
                if case let .popup(backgroundColor, position, isDismissable) = overlayItem.type {
                    GenericPopupContainer(dynamicColors: backgroundColor, position: position, isDismissable: isDismissable, dismiss: {
                        Task { @MainActor in coordinator.back() }
                    }) {
                        PresentationStackView(coordinator: coordinator, screen: overlayItem.screen)
                            .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    }
                    .zIndex(3)
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isPopupPresented.wrappedValue)
    }
}
