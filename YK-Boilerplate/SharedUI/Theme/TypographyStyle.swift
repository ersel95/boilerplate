import SwiftUI

// MARK: - Typography Style System
// Provides consistent typography across the app.
// Usage: Text("Hello").modifier(BaseTypographyStyle(type: .heading(level: .H5, style: .init(weight: .bold))))

public struct BaseTypographyStyle: ViewModifier {
    let type: TypographyStyle

    public func body(content: Content) -> some View {
        content
            .font(.customFont(size: type.size, weight: type.textStyle.weight))
    }
}

public enum TypographyStyle {
    case heading(level: HeadingLevel, style: TextStyle)
    case body(level: BodyLevel, style: TextStyle)

    public var size: CGFloat {
        switch self {
        case let .heading(level, _):
            return level.size
        case let .body(level, _):
            return level.size
        }
    }

    public var textStyle: TextStyle {
        switch self {
        case let .heading(_, style):
            return style
        case let .body(_, style):
            return style
        }
    }
}

// MARK: - Text Style
extension TypographyStyle {
    public struct TextStyle {
        let weight: WeightType

        public init(weight: WeightType) {
            self.weight = weight
        }

        public enum WeightType {
            case light
            case regular
            case medium
            case bold

            // TODO: Replace with your custom font names
            var fontName: String {
                switch self {
                case .light:   return "Ubuntu-Light"
                case .regular: return "Ubuntu-Regular"
                case .medium:  return "Ubuntu-Medium"
                case .bold:    return "Ubuntu-Bold"
                }
            }
        }
    }
}

// MARK: - Heading Levels
extension TypographyStyle {
    public enum HeadingLevel {
        case H0, H1, H2, H3, H4, H5, H6, H7, H8

        var size: CGFloat {
            switch self {
            case .H0: return 48
            case .H1: return 40
            case .H2: return 36
            case .H3: return 32
            case .H4: return 28
            case .H5: return 24
            case .H6: return 20
            case .H7: return 18
            case .H8: return 16
            }
        }
    }
}

// MARK: - Body Levels
extension TypographyStyle {
    public enum BodyLevel {
        case P1, P2, P3, P4, P5, P6, P7

        var size: CGFloat {
            switch self {
            case .P1: return 16
            case .P2: return 15
            case .P3: return 14
            case .P4: return 13
            case .P5: return 12
            case .P6: return 10
            case .P7: return 8
            }
        }
    }
}
