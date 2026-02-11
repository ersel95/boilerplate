import SwiftUI

// MARK: - Login View
// Example login screen with form validation.

struct LoginView: View {
    @ObservedObject var viewModel: LoginViewModel
    @StateObject private var uiState: UIStateManager<String>

    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
        self._uiState = StateObject(wrappedValue: viewModel.uiState)
    }

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Logo
                    VStack(spacing: 12) {
                        Image(systemName: "building.2.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.accentColor)

                        Text("Welcome")
                            .font(.customFont(size: 28, weight: .bold))

                        Text("Sign in to continue")
                            .font(.customFont(size: 14, weight: .regular))
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 60)
                    .padding(.bottom, 20)

                    // Form Fields
                    VStack(spacing: 16) {
                        AppTextField(
                            title: "Username",
                            text: $viewModel.username,
                            placeholder: "Enter your username",
                            errorMessage: viewModel.usernameError
                        )

                        AppTextField(
                            title: "Password",
                            text: $viewModel.password,
                            placeholder: "Enter your password",
                            isSecure: true,
                            errorMessage: viewModel.passwordError
                        )
                    }

                    // Login Button
                    AppButtonView(
                        title: "Sign In",
                        style: viewModel.isFormValid ? .primary : .disabled,
                        isLoading: uiState.isLoading
                    ) {
                        viewModel.login()
                    }

                    Spacer()
                }
                .padding(.horizontal, 24)
            }
            .dismissKeyboardOnTap()
        }
        .loading(uiState.isLoading)
    }
}
