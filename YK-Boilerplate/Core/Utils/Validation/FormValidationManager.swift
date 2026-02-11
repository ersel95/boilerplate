import Foundation

// MARK: - Form Validation
// Provides validation rules and manager for form fields.

public enum RegexType {
    case required
    case minLength(Int)
    case maxLength(Int)
    case exactLength(Int)
    case email
    case phone
    case numeric
    case alphanumeric
    case custom(pattern: String, message: String)

    public var pattern: String? {
        switch self {
        case .required: return nil
        case .minLength: return nil
        case .maxLength: return nil
        case .exactLength: return nil
        case .email: return "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        case .phone: return "^[+]?[0-9]{10,15}$"
        case .numeric: return "^[0-9]+$"
        case .alphanumeric: return "^[a-zA-Z0-9]+$"
        case .custom(let pattern, _): return pattern
        }
    }

    public var errorMessage: String {
        switch self {
        case .required: return ErrorMessages.Validation.requiredField
        case .minLength(let min): return String(format: ErrorMessages.Validation.minLength, min)
        case .maxLength(let max): return String(format: ErrorMessages.Validation.maxLength, max)
        case .exactLength(let len): return "Must be exactly \(len) characters."
        case .email: return ErrorMessages.Validation.invalidEmail
        case .phone: return ErrorMessages.Validation.invalidPhone
        case .numeric: return "Only numbers allowed."
        case .alphanumeric: return "Only letters and numbers allowed."
        case .custom(_, let message): return message
        }
    }
}

// MARK: - Validation Result
public struct ValidationResult {
    public let isValid: Bool
    public let errorMessage: String?

    public static let valid = ValidationResult(isValid: true, errorMessage: nil)

    public static func invalid(_ message: String) -> ValidationResult {
        ValidationResult(isValid: false, errorMessage: message)
    }
}

// MARK: - Validation Manager
public class FormValidationManager {

    public init() {}

    /// Validate a single text against a rule
    public func validate(_ text: String, with rule: RegexType) -> ValidationResult {
        switch rule {
        case .required:
            return text.trimmed.isEmpty
                ? .invalid(rule.errorMessage)
                : .valid

        case .minLength(let min):
            return text.count < min
                ? .invalid(rule.errorMessage)
                : .valid

        case .maxLength(let max):
            return text.count > max
                ? .invalid(rule.errorMessage)
                : .valid

        case .exactLength(let len):
            return text.count != len
                ? .invalid(rule.errorMessage)
                : .valid

        default:
            guard let pattern = rule.pattern else { return .valid }
            let predicate = NSPredicate(format: "SELF MATCHES %@", pattern)
            return predicate.evaluate(with: text)
                ? .valid
                : .invalid(rule.errorMessage)
        }
    }

    /// Validate text against multiple rules, returns first failure
    public func validateAll(_ text: String, rules: [RegexType]) -> ValidationResult {
        for rule in rules {
            let result = validate(text, with: rule)
            if !result.isValid {
                return result
            }
        }
        return .valid
    }
}
