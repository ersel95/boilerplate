import SwiftUI

/// A view that lazily initializes its content.
/// Useful for NavigationLink destinations to avoid premature view creation.
struct LazyView<Content: View>: View {
    let build: () -> Content

    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }

    var body: Content {
        build()
    }
}
