import SwiftUI

// MARK: - Component Image Definitions
// TODO: Add your icon/image names here. They must match names in Icons.xcassets / Images.xcassets.

public enum ComponentImage: String {
    // MARK: - Navigation
    case arrowBack = "arrow_back"
    case arrowForward = "arrow_forward"
    case close = "close"
    case menuHamburger = "menu_hamburger"

    // MARK: - Actions
    case search = "search"
    case settings = "settings"
    case notification = "notification"

    // MARK: - Status
    case checkCircle = "check_circle"
    case warningCircle = "warning_circle"
    case dangerCircleFill = "danger_circle_fill"
    case infoCircle = "info_circle"

    // MARK: - App
    case logo = "app_logo"

    /// Returns SwiftUI Image from asset name
    public var assetImage: Image {
        Image(self.rawValue)
    }

    /// Returns system image as fallback
    public var systemImage: Image {
        switch self {
        case .arrowBack: return Image(systemName: "chevron.left")
        case .arrowForward: return Image(systemName: "chevron.right")
        case .close: return Image(systemName: "xmark")
        case .menuHamburger: return Image(systemName: "line.3.horizontal")
        case .search: return Image(systemName: "magnifyingglass")
        case .settings: return Image(systemName: "gearshape")
        case .notification: return Image(systemName: "bell")
        case .checkCircle: return Image(systemName: "checkmark.circle.fill")
        case .warningCircle: return Image(systemName: "exclamationmark.triangle.fill")
        case .dangerCircleFill: return Image(systemName: "xmark.circle.fill")
        case .infoCircle: return Image(systemName: "info.circle.fill")
        case .logo: return Image(systemName: "building.2")
        }
    }
}
