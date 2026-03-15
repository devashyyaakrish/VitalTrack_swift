import SwiftUI

public struct RegisterView: View {
    @Environment(AppViewModel.self) private var appVM
    @Binding var showRegister: Bool

    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""

    private var passwordStrength: PasswordStrength {
        if password.count == 0 { return .empty }
        if password.count < 6  { return .weak }
        if password.count < 10 { return .medium }
        return .strong
    }

    private var passwordsMatch: Bool { password == confirmPassword && !confirmPassword.isEmpty }

    public init(showRegister: Binding<Bool>) {
        self._showRegister = showRegister
    }

    public var body: some View {
        ZStack {
            Color.backgroundDeep.ignoresSafeArea()

            // Ambient glow
            Circle()
                .fill(Color.secondaryAccent.opacity(0.15))
                .frame(width: 300, height: 300)
                .blur(radius: 80)
                .offset(x: 80, y: -200)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Drag handle
                Capsule()
                    .fill(Color.glassBorder)
                    .frame(width: 36, height: 4)
                    .padding(.top, 12)
                    .padding(.bottom, 20)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Create Account")
                            .heading(font: Typography.displayMedium)
                        Text("Start your health journey today")
                            .textSecondary()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)

                    // Form
                    GlassCard(padding: 24) {
                        VStack(spacing: 16) {

                            GlassTextField(
                                placeholder: "Full Name",
                                text: $name,
                                icon: "person",
                                tint: .primaryButton
                            )
                            .textContentType(.name)

                            GlassTextField(
                                placeholder: "Email Address",
                                text: $email,
                                icon: "envelope",
                                tint: .primaryButton
                            )
                            .keyboardType(.emailAddress)
                            .textContentType(.emailAddress)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)

                            GlassTextField(
                                placeholder: "Password (8+ characters)",
                                text: $password,
                                icon: "lock",
                                isSecure: true,
                                tint: .primaryButton
                            )
                            .textContentType(.newPassword)

                            // Password strength indicator
                            if password.count > 0 {
                                PasswordStrengthBar(strength: passwordStrength)
                                    .transition(.move(edge: .top).combined(with: .opacity))
                            }

                            GlassTextField(
                                placeholder: "Confirm Password",
                                text: $confirmPassword,
                                icon: passwordsMatch ? "checkmark.shield.fill" : "lock.shield",
                                isSecure: true,
                                tint: passwordsMatch ? .successApp : .primaryButton
                            )
                            .textContentType(.newPassword)

                            // Error
                            if let error = appVM.errorMessage {
                                HStack {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.errorApp).font(.system(size: 14))
                                    Text(error)
                                        .font(Typography.labelMedium).foregroundColor(.errorApp)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .transition(.opacity)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)

                    // Action Buttons
                    VStack(spacing: 12) {
                        Button(action: handleRegister) {
                            if appVM.isLoading {
                                AnimatedLoader(color: .white).frame(maxWidth: .infinity, minHeight: 20)
                            } else {
                                Text("Create Account")
                            }
                        }
                        .glassStyle()

                        Button("Already have an account? Sign In") {
                            showRegister = false
                        }
                        .font(Typography.bodyMedium)
                        .foregroundColor(.secondaryAccent)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: appVM.errorMessage)
    }

    private func handleRegister() {
        guard password == confirmPassword else {
            // handled by UI
            return
        }
        Task {
            await appVM.register(name: name, email: email, password: password)
            if appVM.isAuthenticated { showRegister = false }
        }
    }
}

// MARK: - Password Strength Bar

private enum PasswordStrength {
    case empty, weak, medium, strong

    var label: String {
        switch self {
        case .empty:  return ""
        case .weak:   return "Weak"
        case .medium: return "Good"
        case .strong: return "Strong"
        }
    }

    var color: Color {
        switch self {
        case .empty:  return .clear
        case .weak:   return .errorApp
        case .medium: return .warningApp
        case .strong: return .successApp
        }
    }

    var fraction: Double {
        switch self {
        case .empty:  return 0
        case .weak:   return 0.33
        case .medium: return 0.66
        case .strong: return 1.0
        }
    }
}

private struct PasswordStrengthBar: View {
    let strength: PasswordStrength

    var body: some View {
        HStack(spacing: 8) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.glassWhite)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(strength.color)
                        .frame(width: geo.size.width * strength.fraction)
                        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: strength.fraction)
                }
            }
            .frame(height: 4)

            Text(strength.label)
                .font(Typography.labelSmall)
                .foregroundColor(strength.color)
                .frame(width: 44, alignment: .trailing)
        }
    }
}
