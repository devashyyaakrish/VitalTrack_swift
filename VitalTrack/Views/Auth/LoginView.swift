import SwiftUI
import LocalAuthentication

public struct LoginView: View {
    @Environment(AppViewModel.self) private var appVM
    @Binding var showRegister: Bool

    @State private var email = ""
    @State private var password = ""
    @State private var shakeOffset: CGFloat = 0
    @State private var logoScale: CGFloat = 0.7
    @State private var logoOpacity: Double = 0
    @State private var formOpacity: Double = 0

    public init(showRegister: Binding<Bool>) {
        self._showRegister = showRegister
    }

    public var body: some View {
        GradientBackground {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    Spacer().frame(height: 32)

                    // MARK: - Animated Logo
                    VStack(spacing: 12) {
                        ZStack {
                            // Outer glow ring
                            Circle()
                                .fill(Color.primaryButton.opacity(0.15))
                                .frame(width: 100, height: 100)
                                .blur(radius: 12)

                            // Logo orb
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: "818CF8"), Color(hex: "4F46E5"), Color(hex: "3730A3")],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 80, height: 80)
                                .overlay(
                                    Image(systemName: "waveform.path.ecg")
                                        .font(.system(size: 34, weight: .bold))
                                        .foregroundColor(.white)
                                        .symbolEffect(.pulse)
                                )
                                .shadow(color: Color.primaryButton.opacity(0.7), radius: 20, x: 0, y: 8)
                        }
                        .scaleEffect(logoScale)
                        .opacity(logoOpacity)

                        VStack(spacing: 4) {
                            Text("VitalTrack")
                                .font(Typography.displayLarge)
                                .foregroundColor(.textPrimary)
                            Text("Your daily health, beautifully tracked.")
                                .textSecondary()
                        }
                        .opacity(logoOpacity)
                    }

                    // MARK: - Login Form Card
                    GlassCard(padding: 24) {
                        VStack(spacing: 18) {
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
                                placeholder: "Password",
                                text: $password,
                                icon: "lock",
                                isSecure: true,
                                tint: .primaryButton
                            )
                            .textContentType(.password)

                            // Error message
                            if let error = appVM.errorMessage {
                                HStack {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.errorApp)
                                        .font(.system(size: 14))
                                    Text(error)
                                        .font(Typography.labelMedium)
                                        .foregroundColor(.errorApp)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .transition(.move(edge: .top).combined(with: .opacity))
                            }

                            HStack {
                                Spacer()
                                Button("Forgot password?") {}
                                    .font(Typography.labelMedium)
                                    .foregroundColor(.secondaryAccent)
                            }

                            // Sign In Button
                            Button(action: handleLogin) {
                                if appVM.isLoading {
                                    AnimatedLoader(color: .white)
                                        .frame(maxWidth: .infinity, minHeight: 20)
                                } else {
                                    Text("Sign In")
                                }
                            }
                            .glassStyle()
                            .padding(.top, 8)
                            .offset(x: shakeOffset)
                        }
                    }
                    .padding(.horizontal, 24)
                    .opacity(formOpacity)

                    // MARK: - Biometrics
                    VStack(spacing: 16) {
                        biometricButton

                        HStack(spacing: 20) {
                            VStack { Divider().background(Color.glassBorder) }
                            Text("or continue with")
                                .font(Typography.labelSmall)
                                .foregroundColor(.textTertiary)
                            VStack { Divider().background(Color.glassBorder) }
                        }
                        .padding(.horizontal, 32)

                        Button {
                            Task { await appVM.loginWithGoogle() }
                        } label: {
                            HStack(spacing: 10) {
                                ZStack {
                                    Circle().fill(Color.white).frame(width: 24, height: 24)
                                    Text("G")
                                        .font(.system(size: 14, weight: .black))
                                        .foregroundColor(Color(hex: "4285F4"))
                                }
                                Text("Continue with Google")
                            }
                        }
                        .glassOutlineStyle()
                        .padding(.horizontal, 24)
                    }
                    .opacity(formOpacity)

                    // MARK: - Sign Up Link
                    HStack {
                        Text("Don't have an account?")
                            .textSecondary(font: Typography.bodyMedium)
                        Button("Sign Up") {
                            showRegister = true
                        }
                        .font(Typography.bodyMedium)
                        .foregroundColor(.primaryButton)
                        .fontWeight(.bold)
                    }
                    .opacity(formOpacity)
                    .padding(.bottom, 40)
                }
            }
        }
        .onAppear { animateIn() }
    }

    // MARK: - Actions

    private func handleLogin() {
        Task {
            await appVM.login(email: email, password: password)
            if appVM.errorMessage != nil { shake() }
        }
    }

    private func shake() {
        withAnimation(.spring(response: 0.1, dampingFraction: 0.3)) { shakeOffset = -10 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.1, dampingFraction: 0.3)) { shakeOffset = 10 }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring(response: 0.1, dampingFraction: 0.3)) { shakeOffset = -6 }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) { shakeOffset = 0 }
        }
    }

    private func animateIn() {
        withAnimation(.spring(response: 0.7, dampingFraction: 0.7)) {
            logoScale = 1.0
            logoOpacity = 1.0
        }
        withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
            formOpacity = 1.0
        }
    }

    // MARK: - Biometric Button

    @ViewBuilder
    private var biometricButton: some View {
        let context = LAContext()
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
            Button {
                authenticateWithBiometrics()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: context.biometryType == .faceID ? "faceid" : "touchid")
                        .font(.system(size: 20))
                    Text(context.biometryType == .faceID ? "Sign in with Face ID" : "Sign in with Touch ID")
                }
            }
            .glassOutlineStyle()
            .padding(.horizontal, 24)
        }
    }

    private func authenticateWithBiometrics() {
        let context = LAContext()
        let reason = "Sign in to VitalTrack"
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, _ in
            if success {
                Task { await appVM.loginWithGoogle() }
            }
        }
    }
}
