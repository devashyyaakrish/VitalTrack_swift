import SwiftUI

/// Upgraded GlassBottomNav with matchedGeometryEffect sliding pill indicator,
/// iOS 17 symbolEffect bounce, and label text beneath each icon.
public struct GlassBottomNav: View {
    @Binding var selectedTab: AppTab
    @Namespace private var navAnimation

    public init(selectedTab: Binding<AppTab>) {
        self._selectedTab = selectedTab
    }

    public var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                let isActive = tab == selectedTab
                tabItem(tab: tab, isActive: isActive)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .padding(.bottom, 4)
        .background(navBackground)
        .ignoresSafeArea(edges: .bottom)
        .padding(.top, 10)
    }

    @ViewBuilder
    private func tabItem(tab: AppTab, isActive: Bool) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.72)) {
                selectedTab = tab
            }
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        } label: {
            VStack(spacing: 4) {
                ZStack {
                    // Sliding pill background
                    if isActive {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.primaryButton.opacity(0.75),
                                        Color(hex: "7C3AED").opacity(0.65)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 48, height: 36)
                            .shadow(color: Color.primaryButton.opacity(0.55), radius: 10, x: 0, y: 4)
                            .matchedGeometryEffect(id: "TAB_PILL", in: navAnimation)
                    }

                    Image(systemName: tab.iconName)
                        .font(.system(size: 20, weight: isActive ? .semibold : .regular))
                        .foregroundColor(isActive ? .white : .textSecondary)
                        .frame(width: 48, height: 36)
                        .symbolEffect(.bounce, value: isActive)
                }

                Text(tab.label)
                    .font(.system(size: 10, weight: isActive ? .semibold : .regular))
                    .foregroundColor(isActive ? .white : .textTertiary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var navBackground: some View {
        RoundedRectangle(cornerRadius: 36, style: .continuous)
            .fill(.ultraThinMaterial)
            .background(
                RoundedRectangle(cornerRadius: 36, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.12), Color.white.opacity(0.04)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 36, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.40), Color.white.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: Color.black.opacity(0.35), radius: 24, x: 0, y: -4)
    }
}

/// Defines the tabs available in the main navigation
public enum AppTab: Int, CaseIterable {
    case dashboard = 0
    case trackers  = 1
    case habits    = 2
    case analytics = 3
    case settings  = 4

    var iconName: String {
        switch self {
        case .dashboard: return "square.grid.2x2"
        case .trackers:  return "heart.text.square"
        case .habits:    return "checklist"
        case .analytics: return "chart.bar.xaxis"
        case .settings:  return "gearshape"
        }
    }

    var label: String {
        switch self {
        case .dashboard: return "Home"
        case .trackers:  return "Trackers"
        case .habits:    return "Habits"
        case .analytics: return "Stats"
        case .settings:  return "Settings"
        }
    }
}
