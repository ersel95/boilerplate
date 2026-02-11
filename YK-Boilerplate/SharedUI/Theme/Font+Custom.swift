import SwiftUI

// MARK: - Custom Font Extension
// TODO: 1. Add your font files (.ttf/.otf) to Assets/Fonts/
//       2. Add them to Info.plist under "Fonts provided by application"
//       3. Update the font names below to match your font file names

public extension Font {
    /// Creates a custom font with the specified size and weight.
    /// Falls back to system font if the custom font is not found.
    static func customFont(
        size: CGFloat,
        weight: TypographyStyle.TextStyle.WeightType
    ) -> Font {
        return Font.custom(weight.fontName, size: size)
    }
}

// MARK: - Convenience Text Extensions
public extension View {
    /// Apply heading typography
    func heading(_ level: TypographyStyle.HeadingLevel, weight: TypographyStyle.TextStyle.WeightType = .bold) -> some View {
        self.modifier(BaseTypographyStyle(type: .heading(level: level, style: .init(weight: weight))))
    }

    /// Apply body typography
    func bodyStyle(_ level: TypographyStyle.BodyLevel, weight: TypographyStyle.TextStyle.WeightType = .regular) -> some View {
        self.modifier(BaseTypographyStyle(type: .body(level: level, style: .init(weight: weight))))
    }
}
