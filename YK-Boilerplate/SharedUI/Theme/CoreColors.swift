import Foundation

// MARK: - Core Color Definitions
// TODO: Define your color names here. They must match the names in Colors.xcassets.

public enum CoreColors: String {
    case Primary
    case Secondary
    case Danger
    case Warning
    case Success
    case Gray
    case Text
    case Component
    case Background

    public enum SubColors: String {
        // Numbered variants (Primary, Secondary, Success, Warning, Gray)
        case one = "1"
        case two = "2"
        case three = "3"
        case four = "4"
        case five = "5"
        case six = "6"
        case seven = "7"
        case eight = "8"

        // Semantic variants (Text)
        case primary = "Primary"
        case secondary = "Secondary"
        case placeholder = "Placeholder"
        case button = "Button"

        // Component variants
        case box = "Box"
        case header = "Header"
        case bgPrimary = "BgPrimary"
        case bgSecondary = "BgSecondary"
        case border = "Border"
        case disableButton = "DisableButton"

        // Background variants
        case white = "White"
        case bgOverlay = "BgOverlay"
    }
}
