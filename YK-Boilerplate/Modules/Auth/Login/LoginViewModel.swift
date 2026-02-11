import Foundation
import Combine

// MARK: - Login ViewModel
// Demonstrates form validation and mock authentication flow.

@MainActor
class LoginViewModel: BaseViewModel {
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var usernameError: String? = nil
    @Published var passwordError: String? = nil

    let uiState = UIStateManager<String>(state: .idle)
    private let validator = FormValidationManager()

    var isFormValid: Bool {
        username.isNotEmpty && password.isNotEmpty
    }

    func login() {
        // Validate
        let usernameResult = validator.validateAll(username, rules: [.required, .minLength(3)])
        let passwordResult = validator.validateAll(password, rules: [.required, .minLength(6)])

        usernameError = usernameResult.errorMessage
        passwordError = passwordResult.errorMessage

        guard usernameResult.isValid && passwordResult.isValid else { return }

        // Perform login
        uiState.setLoading()

        Task {
            // Simulate API call
            // TODO: Replace with actual login service call
            try? await Task.sleep(nanoseconds: 1_500_000_000)

            // Mock success: save token and navigate
            UserSession.shared.saveAccessToken("mock_access_token_\(UUID().uuidString)")
            uiState.setData("Login successful")

            // Navigate to home
            switchRoot(to: .home(.main))
        }
    }
}
