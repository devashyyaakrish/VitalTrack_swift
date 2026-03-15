import SwiftUI

/// Root Application Router reading auth state from the environment AppViewModel.
public struct AppView: View {
    @Environment(AppViewModel.self) private var appVM
    @State private var showRegister = false

    public init() {}

    public var body: some View {
        Group {
            if appVM.isAuthenticated {
                MainTabView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            } else {
                LoginView(showRegister: $showRegister)
                    .sheet(isPresented: $showRegister) {
                        RegisterView(showRegister: $showRegister)
                            .presentationDetents([.large])
                            .presentationDragIndicator(.visible)
                            .presentationBackground(.ultraThinMaterial)
                    }
                    .transition(.asymmetric(
                        insertion: .move(edge: .leading).combined(with: .opacity),
                        removal: .move(edge: .trailing).combined(with: .opacity)
                    ))
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: appVM.isAuthenticated)
    }
}
