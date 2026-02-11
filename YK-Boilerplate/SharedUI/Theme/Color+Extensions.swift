import SwiftUI

// MARK: - Semantic Color Access
// Usage: Color.YKColor.Primary.one, Color.YKColor.Text.primary, etc.
// TODO: Ensure your Colors.xcassets has matching color sets (e.g., "Primary1", "TextPrimary")

public extension Color {
    enum YKColor {
        // MARK: - Primary
        public enum Primary {
            public static let one = Color("Primary1")
            public static let two = Color("Primary2")
            public static let three = Color("Primary3")
            public static let four = Color("Primary4")
            public static let five = Color("Primary5")
            public static let six = Color("Primary6")
            public static let seven = Color("Primary7")
            public static let eight = Color("Primary8")
        }

        // MARK: - Secondary
        public enum Secondary {
            public static let one = Color("Secondary1")
            public static let two = Color("Secondary2")
            public static let three = Color("Secondary3")
        }

        // MARK: - Danger
        public enum Danger {
            public static let one = Color("Danger1")
            public static let two = Color("Danger2")
            public static let three = Color("Danger3")
        }

        // MARK: - Warning
        public enum Warning {
            public static let one = Color("Warning1")
            public static let two = Color("Warning2")
        }

        // MARK: - Success
        public enum Success {
            public static let one = Color("Success1")
            public static let two = Color("Success2")
            public static let three = Color("Success3")
        }

        // MARK: - Gray
        public enum Gray {
            public static let one = Color("Gray1")
            public static let two = Color("Gray2")
            public static let three = Color("Gray3")
            public static let four = Color("Gray4")
            public static let five = Color("Gray5")
            public static let six = Color("Gray6")
            public static let seven = Color("Gray7")
            public static let eight = Color("Gray8")
        }

        // MARK: - Text
        public enum TextLight {
            public static let primary = Color("TextPrimary")
            public static let secondary = Color("TextSecondary")
            public static let placeholder = Color("TextPlaceholder")
            public static let button = Color("TextButton")
        }

        // MARK: - Component
        public enum Component {
            public static let box = Color("ComponentBox")
            public static let header = Color("ComponentHeader")
            public static let bgPrimary = Color("ComponentBgPrimary")
            public static let bgSecondary = Color("ComponentBgSecondary")
            public static let border = Color("ComponentBorder")
            public static let disableButton = Color("ComponentDisableButton")
        }

        // MARK: - Background
        public enum Background {
            public static let white = Color("BackgroundWhite")
            public static let bgOverlay = Color("BackgroundBgOverlay")
        }
    }
}
