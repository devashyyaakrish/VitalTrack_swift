import SwiftUI
import Observation

// MARK: - AppViewModel

/// Root application view model managing authentication state and user info.
/// Uses the @Observable macro (iOS 17+) for automatic observation tracking.
@Observable
public final class AppViewModel {

    // MARK: - Published State
    var isAuthenticated: Bool = false
    var userName: String = "Devashyya"
    var userEmail: String = "user@vitaltrack.app"
    var isLoading: Bool = false
    var errorMessage: String? = nil

    // MARK: - Authentication Actions

    /// Simulates a login flow with a 1.5s async delay.
    func login(email: String, password: String) async {
        isLoading = true
        errorMessage = nil

        // Simulate network call
        try? await Task.sleep(nanoseconds: 1_500_000_000)

        await MainActor.run {
            if email.isEmpty || password.count < 6 {
                errorMessage = "Invalid credentials. Please try again."
            } else {
                isAuthenticated = true
                userEmail = email
            }
            isLoading = false
        }
    }

    /// Simulates Google Sign In
    func loginWithGoogle() async {
        isLoading = true
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        await MainActor.run {
            isAuthenticated = true
            isLoading = false
        }
    }

    /// Signs the user out and resets state.
    func signOut() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            isAuthenticated = false
            userEmail = ""
        }
    }

    /// Simulates registering a new account.
    func register(name: String, email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        try? await Task.sleep(nanoseconds: 1_800_000_000)
        await MainActor.run {
            if name.isEmpty || email.isEmpty || password.count < 8 {
                errorMessage = "Please fill in all fields with a password of 8+ characters."
            } else {
                isAuthenticated = true
                userName = name
                userEmail = email
            }
            isLoading = false
        }
    }
}
