import SwiftUI

public struct DashboardView: View {
    @Environment(AppViewModel.self) private var appVM
    @Environment(TrackersViewModel.self) private var trackersVM

    @State private var showHero = false
    @State private var showMetrics = false
    @State private var showQuickActions = false

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    public init() {}

    public var body: some View {
        GradientBackground {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {

                    // MARK: - Hero Header
                    if showHero {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(greetingText)
                                        .textSecondary(font: Typography.bodyLarge)
                                    Text(appVM.userName)
                                        .font(Typography.displayLarge)
                                        .foregroundColor(.textPrimary)
                                }
                                Spacer()
                                // Notification bell
                                Button {} label: {
                                    ZStack(alignment: .topTrailing) {
                                        Image(systemName: "bell.fill")
                                            .font(.system(size: 22))
                                            .foregroundColor(.white)
                                            .padding(14)
                                            .liquidGlass(cornerRadius: 16)

                                        // Notification badge
                                        Circle()
                                            .fill(Color.errorApp)
                                            .frame(width: 10, height: 10)
                                            .overlay(Circle().stroke(Color.backgroundDark, lineWidth: 2))
                                            .offset(x: 2, y: 2)
                                    }
                                }
                                .buttonStyle(.plain)
                            }

                            // Daily quote card
                            GlassCard(padding: 14, cornerRadius: 18) {
                                HStack(spacing: 10) {
                                    Text("💡")
                                        .font(.system(size: 18))
                                    Text("Consistency is the core of progress. Keep moving!")
                                        .textSecondary(font: Typography.bodyMedium)
                                        .italic()
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }

                    // MARK: - Overall Health Score Ring
                    if showHero {
                        GlassCard(padding: 20, cornerRadius: 24) {
                            HStack(spacing: 20) {
                                MetricRing(
                                    value: trackersVM.healthScore,
                                    gradient: .healthGradient,
                                    lineWidth: 10,
                                    glowColor: .secondaryAccent
                                ) {
                                    VStack(spacing: 2) {
                                        Text("\(Int(trackersVM.healthScore * 100))")
                                            .font(Typography.headingMedium)
                                            .foregroundColor(.textPrimary)
                                        Text("pts")
                                            .font(Typography.labelSmall)
                                            .foregroundColor(.textTertiary)
                                    }
                                }
                                .frame(width: 80, height: 80)

                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Health Score")
                                        .heading(font: Typography.headingSmall)
                                    Text(healthScoreLabel)
                                        .textSecondary(font: Typography.bodyMedium)
                                    Text("Today's overall wellness")
                                        .textTertiary(font: Typography.labelSmall)
                                }
                                Spacer()
                            }
                        }
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }

                    // MARK: - Metric Grid
                    if showMetrics {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(Array(trackersVM.dashboardMetrics.enumerated()), id: \.element.id) { index, metric in
                                MetricCard(metric: metric, index: index)
                            }
                        }
                    }

                    // MARK: - Quick Actions
                    if showQuickActions {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Quick Log")
                                .heading(font: Typography.headingSmall)
                                .padding(.leading, 4)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    QuickActionChip(
                                        label: "+250ml Water", icon: "drop.fill",
                                        color: .waterColor, gradient: .waterGradient
                                    ) { trackersVM.addWater(250) }

                                    QuickActionChip(
                                        label: "+500ml Water", icon: "drop.fill",
                                        color: .waterColor, gradient: .waterGradient
                                    ) { trackersVM.addWater(500) }

                                    QuickActionChip(
                                        label: "Log Meal", icon: "fork.knife",
                                        color: .caloriesColor, gradient: .caloriesGradient
                                    ) {}

                                    QuickActionChip(
                                        label: "Set Sleep", icon: "moon.zzz.fill",
                                        color: .sleepColor, gradient: .sleepGradient
                                    ) {}
                                }
                                .padding(.horizontal, 4)
                            }
                        }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }

                    Spacer().frame(height: 120) // Bottom nav buffer
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                showHero = true
            }
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2)) {
                showMetrics = true
            }
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.35)) {
                showQuickActions = true
            }
        }
    }

    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:  return "Good Morning,"
        case 12..<17: return "Good Afternoon,"
        case 17..<21: return "Good Evening,"
        default:      return "Good Night,"
        }
    }

    private var healthScoreLabel: String {
        switch trackersVM.healthScore {
        case 0.85...: return "Excellent! 🏆"
        case 0.65...: return "Looking great! 💪"
        case 0.45...: return "Getting there 📈"
        default:      return "Let's get moving! 🚀"
        }
    }
}

// MARK: - MetricCard

private struct MetricCard: View {
    let metric: MetricData
    let index: Int

    @State private var animateIn = false

    var body: some View {
        GlassCard(padding: 16, cornerRadius: 24, tint: metric.color) {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(metric.gradient)
                            .frame(width: 36, height: 36)
                        Image(systemName: metric.iconName)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    }
                    Spacer()
                    MetricRing(
                        value: metric.value,
                        gradient: metric.gradient,
                        lineWidth: 5,
                        glowColor: metric.color
                    ) { EmptyView() }
                    .frame(width: 28, height: 28)
                }

                Spacer().frame(height: 20)

                VStack(alignment: .leading, spacing: 4) {
                    Text(metric.displayValue)
                        .font(Typography.headingMedium)
                        .foregroundColor(.textPrimary)
                        .fontWeight(.heavy)
                    Text(metric.title)
                        .textSecondary(font: Typography.labelLarge)
                    Text(metric.subtitle)
                        .textTertiary(font: Typography.labelSmall)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .offset(y: animateIn ? 0 : 50)
        .opacity(animateIn ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(Double(index) * 0.1)) {
                animateIn = true
            }
        }
    }
}

// MARK: - QuickActionChip

private struct QuickActionChip: View {
    let label: String
    let icon: String
    let color: Color
    let gradient: LinearGradient
    let action: () -> Void

    @State private var showSparkle = false

    var body: some View {
        ZStack {
            Button(action: {
                action()
                showSparkle = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    showSparkle = false
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(color)
                    Text(label)
                        .font(Typography.labelLarge)
                        .foregroundColor(.textPrimary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .liquidGlass(cornerRadius: 24, tint: color, intensity: 0.6)

            SparkleRing(isTriggered: showSparkle, color: color)
        }
    }
}
