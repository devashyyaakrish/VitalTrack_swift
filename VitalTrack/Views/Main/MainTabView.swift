import SwiftUI

public struct MainTabView: View {
    @State private var selectedTab: AppTab = .dashboard
    @Environment(TrackersViewModel.self) private var trackersVM

    public init() {}

    public var body: some View {
        ZStack(alignment: .bottom) {
            // Tab Content — all real views wired up
            Group {
                switch selectedTab {
                case .dashboard:
                    DashboardView()
                case .trackers:
                    TrackersView()
                case .habits:
                    HabitsView()
                case .analytics:
                    AnalyticsView()
                case .settings:
                    SettingsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .transition(.asymmetric(
                insertion: .opacity.combined(with: .scale(scale: 0.97)),
                removal: .opacity.combined(with: .scale(scale: 1.02))
            ))
            .id(selectedTab) // Forces view refresh on tab switch for transition

            // Floating Glass Bottom Navigation Bar
            GlassBottomNav(selectedTab: $selectedTab)
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .animation(.spring(response: 0.38, dampingFraction: 0.82), value: selectedTab)
    }
}
