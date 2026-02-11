import SwiftUI

// MARK: - Generic Popup Container
// Wraps popup content with background overlay and positioning.

struct GenericPopupContainer<Content: View>: View {
    let dynamicColors: DynamicColors?
    let position: PopupContentPosition
    let isDismissable: Bool
    let dismiss: () -> Void
    @ViewBuilder let content: () -> Content

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            // Background overlay
            backgroundColor
                .ignoresSafeArea()
                .onTapGesture {
                    if isDismissable {
                        dismiss()
                    }
                }

            // Content positioned
            VStack {
                switch position {
                case .top:
                    content()
                    Spacer()
                case .center:
                    Spacer()
                    content()
                    Spacer()
                case .bottom:
                    Spacer()
                    content()
                }
            }
            .padding()
        }
    }

    private var backgroundColor: Color {
        if let dynamicColors {
            return colorScheme == .dark ? dynamicColors.dark : dynamicColors.light
        }
        return Color.black.opacity(0.5)
    }
}
