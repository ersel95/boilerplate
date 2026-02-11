import SwiftUI

// MARK: - Button Style Variants

public enum AppButtonStyle {
    case primary
    case secondary
    case danger
    case disabled

    var backgroundColor: Color {
        switch self {
        case .primary:   return .accentColor
        case .secondary: return .clear
        case .danger:    return .red
        case .disabled:  return .gray.opacity(0.3)
        }
    }

    var foregroundColor: Color {
        switch self {
        case .primary:   return .white
        case .secondary: return .accentColor
        case .danger:    return .white
        case .disabled:  return .gray
        }
    }

    var borderColor: Color {
        switch self {
        case .secondary: return .accentColor
        default:         return .clear
        }
    }
}
