import SwiftUI

// MARK: - App Text Field
// Reusable text field with validation support.

public struct AppTextField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    var isSecure: Bool = false
    var errorMessage: String? = nil
    var keyboardType: UIKeyboardType = .default

    public init(
        title: String,
        text: Binding<String>,
        placeholder: String = "",
        isSecure: Bool = false,
        errorMessage: String? = nil,
        keyboardType: UIKeyboardType = .default
    ) {
        self.title = title
        self._text = text
        self.placeholder = placeholder
        self.isSecure = isSecure
        self.errorMessage = errorMessage
        self.keyboardType = keyboardType
    }

    @State private var isShowingPassword = false

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.customFont(size: 13, weight: .medium))
                .foregroundColor(.secondary)

            HStack {
                if isSecure && !isShowingPassword {
                    SecureField(placeholder, text: $text)
                        .keyboardType(keyboardType)
                } else {
                    TextField(placeholder, text: $text)
                        .keyboardType(keyboardType)
                }

                if isSecure {
                    Button(action: { isShowingPassword.toggle() }) {
                        Image(systemName: isShowingPassword ? "eye.slash" : "eye")
                            .foregroundColor(.gray)
                    }
                }
            }
            .font(.customFont(size: 16, weight: .regular))
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(errorMessage != nil ? Color.red : Color.clear, lineWidth: 1)
            )

            if let error = errorMessage {
                Text(error)
                    .font(.customFont(size: 12, weight: .regular))
                    .foregroundColor(.red)
            }
        }
    }
}
