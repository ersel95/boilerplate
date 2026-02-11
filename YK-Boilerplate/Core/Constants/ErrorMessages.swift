import Foundation

// MARK: - Centralized Error Messages
// TODO: Replace these with your localization system when ready.
// All user-facing error strings should be defined here for easy maintenance.

public struct ErrorMessages {

    // MARK: - Network Errors
    public struct Network {
        public static let timeout = "Request timed out. Please try again."
        public static let noInternet = "No internet connection. Please check your connection."
        public static let unknown = "An unexpected error occurred."
        public static let requestInProgress = "A request is already in progress. Please wait."
        public static let serverError = "Server error occurred. Please try again later."
        public static let decodingError = "Failed to process server response."
    }

    // MARK: - Authentication Errors
    public struct Auth {
        public static let invalidCredentials = "Invalid credentials. Please try again."
        public static let sessionExpired = "Your session has expired. Please log in again."
        public static let accessDenied = "Access denied."
        public static let accountBlocked = "Your account has been blocked."
        public static let maxLoginAttempts = "Maximum login attempts exceeded."
    }

    // MARK: - Validation Errors
    public struct Validation {
        public static let requiredField = "This field is required."
        public static let invalidEmail = "Please enter a valid email address."
        public static let invalidPhone = "Please enter a valid phone number."
        public static let minLength = "Minimum %d characters required."
        public static let maxLength = "Maximum %d characters allowed."
    }

    // MARK: - General
    public struct General {
        public static let somethingWentWrong = "Something went wrong. Please try again."
        public static let noData = "No data available."
        public static let comingSoon = "This feature is coming soon."
    }
}
