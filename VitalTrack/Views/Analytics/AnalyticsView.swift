import SwiftUI
import Charts

// MARK: - AnalyticsView

public struct AnalyticsView: View {
    @Environment(TrackersViewModel.self) private var vm
    @State private var selectedMetric: AnalyticsMetric = .water
    @State private var showHeader = false

    let stats = MockData.weeklyStats

    public init() {}

    public var body: some View {
        GradientBackground {
            VStack(spacing: 0) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Analytics")
                            .heading(font: Typography.displayMedium)
                        Text("7-day overview")
                            .textSecondary(font: Typography.labelMedium)
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 16)
                .opacity(showHeader ? 1 : 0)
                .offset(y: showHeader ? 0 : -20)

                // Metric Selector
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(AnalyticsMetric.allCases, id: \.self) { metric in
                            MetricSelectorChip(metric: metric, isSelected: selectedMetric == metric) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    selectedMetric = metric
                                }
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                }

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {

                        // Summary stat row
                        SummaryStatsRow(stats: stats, metric: selectedMetric)
                            .padding(.horizontal, 20)

                        // Main chart card
                        MainChartCard(stats: stats, metric: selectedMetric)
                            .padding(.horizontal, 20)

                        // All metrics mini-rings
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(AnalyticsMetric.allCases, id: \.self) { m in
                                MiniStatCard(stats: stats, metric: m, isSelected: selectedMetric == m)
                                    .onTapGesture {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            selectedMetric = m
                                        }
                                    }
                            }
                        }
                        .padding(.horizontal, 20)

                        Spacer().frame(height: 120)
                    }
                    .padding(.top, 8)
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.4)) { showHeader = true }
        }
    }
}

// MARK: - Analytics Metric Enum

enum AnalyticsMetric: String, CaseIterable {
    case water    = "Water"
    case steps    = "Steps"
    case calories = "Calories"
    case sleep    = "Sleep"

    var color: Color {
        switch self {
        case .water:    return .waterColor
        case .steps:    return .stepsColor
        case .calories: return .caloriesColor
        case .sleep:    return .sleepColor
        }
    }

    var gradient: LinearGradient {
        switch self {
        case .water:    return .waterGradient
        case .steps:    return .stepsGradient
        case .calories: return .caloriesGradient
        case .sleep:    return .sleepGradient
        }
    }

    var icon: String {
        switch self {
        case .water:    return "drop.fill"
        case .steps:    return "shoeprints.fill"
        case .calories: return "flame.fill"
        case .sleep:    return "moon.zzz.fill"
        }
    }

    var unit: String {
        switch self {
        case .water:    return "ml"
        case .steps:    return "steps"
        case .calories: return "kcal"
        case .sleep:    return "hrs"
        }
    }

    func value(from stat: DayStats) -> Double {
        switch self {
        case .water:    return stat.water
        case .steps:    return stat.steps
        case .calories: return stat.calories
        case .sleep:    return stat.sleep
        }
    }
}

// MARK: - Metric Selector Chip

private struct MetricSelectorChip: View {
    let metric: AnalyticsMetric
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: metric.icon).font(.system(size: 12, weight: .bold))
                Text(metric.rawValue).font(Typography.labelLarge)
            }
            .foregroundColor(isSelected ? .white : .textSecondary)
            .padding(.horizontal, 16).padding(.vertical, 9)
            .background(
                Group {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(metric.color.opacity(0.7))
                            .shadow(color: metric.color.opacity(0.45), radius: 8, x: 0, y: 4)
                    } else {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Color.glassWhite)
                    }
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(isSelected ? metric.color.opacity(0.4) : Color.glassBorder, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Summary Stats Row

private struct SummaryStatsRow: View {
    let stats: [DayStats]
    let metric: AnalyticsMetric

    private var values: [Double] { stats.map { metric.value(from: $0) } }
    private var avg: Double { values.isEmpty ? 0 : values.reduce(0, +) / Double(values.count) }
    private var best: Double { values.max() ?? 0 }
    private var total: Double { values.reduce(0, +) }

    var body: some View {
        GlassCard(padding: 16, cornerRadius: 20, tint: metric.color) {
            HStack {
                StatPill(label: "Avg",   value: formattedValue(avg),  color: metric.color)
                Divider().background(Color.glassBorder).frame(height: 36)
                StatPill(label: "Best",  value: formattedValue(best), color: .successApp)
                Divider().background(Color.glassBorder).frame(height: 36)
                StatPill(label: "Total", value: formattedValue(total), color: .textSecondary)
            }
        }
    }

    private func formattedValue(_ v: Double) -> String {
        switch metric {
        case .sleep:    return String(format: "%.1fh", v)
        case .steps:    return "\(Int(v).formatted())"
        default:        return "\(Int(v))"
        }
    }
}

private struct StatPill: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(Typography.headingSmall)
                .foregroundColor(color)
            Text(label)
                .textTertiary(font: Typography.labelSmall)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Main Chart Card

private struct MainChartCard: View {
    let stats: [DayStats]
    let metric: AnalyticsMetric

    var body: some View {
        GlassCard(padding: 20, cornerRadius: 24) {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 10) {
                    Image(systemName: metric.icon)
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                        .frame(width: 30, height: 30)
                        .background(metric.gradient)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(metric.rawValue)
                            .heading(font: Typography.headingSmall)
                        Text("\(metric.unit) · this week")
                            .textSecondary(font: Typography.labelSmall)
                    }
                }

                Chart(stats) { item in
                    if metric == .steps || metric == .sleep {
                        LineMark(
                            x: .value("Day", item.day),
                            y: .value(metric.rawValue, metric.value(from: item))
                        )
                        .lineStyle(StrokeStyle(lineWidth: 2.5, lineCap: .round))
                        .foregroundStyle(metric.color)

                        AreaMark(
                            x: .value("Day", item.day),
                            y: .value(metric.rawValue, metric.value(from: item))
                        )
                        .foregroundStyle(
                            .linearGradient(
                                colors: [metric.color.opacity(0.35), metric.color.opacity(0.0)],
                                startPoint: .top, endPoint: .bottom
                            )
                        )

                        PointMark(
                            x: .value("Day", item.day),
                            y: .value(metric.rawValue, metric.value(from: item))
                        )
                        .foregroundStyle(metric.color)
                    } else {
                        BarMark(
                            x: .value("Day", item.day),
                            y: .value(metric.rawValue, metric.value(from: item))
                        )
                        .foregroundStyle(
                            .linearGradient(
                                colors: [metric.color, metric.color.opacity(0.6)],
                                startPoint: .top, endPoint: .bottom
                            )
                        )
                        .cornerRadius(6)
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading, values: .automatic(desiredCount: 4)) {
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                            .foregroundStyle(Color.white.opacity(0.08))
                        AxisValueLabel()
                            .foregroundStyle(Color.white.opacity(0.45))
                            .font(Typography.labelSmall)
                    }
                }
                .chartXAxis {
                    AxisMarks {
                        AxisValueLabel()
                            .foregroundStyle(Color.white.opacity(0.5))
                            .font(Typography.labelSmall)
                    }
                }
                .frame(height: 180)
            }
        }
    }
}

// MARK: - Mini Stat Card

private struct MiniStatCard: View {
    let stats: [DayStats]
    let metric: AnalyticsMetric
    let isSelected: Bool

    private var avg: Double {
        let vals = stats.map { metric.value(from: $0) }
        return vals.isEmpty ? 0 : vals.reduce(0, +) / Double(vals.count)
    }

    private var formattedAvg: String {
        switch metric {
        case .sleep: return String(format: "%.1fh", avg)
        case .steps: return "\(Int(avg).formatted())"
        default:     return "\(Int(avg))"
        }
    }

    var body: some View {
        GlassCard(padding: 14, cornerRadius: 20, tint: isSelected ? metric.color : .clear) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: metric.icon)
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                        .frame(width: 28, height: 28)
                        .background(metric.gradient)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    Spacer()
                }

                Text(formattedAvg)
                    .font(Typography.headingSmall)
                    .foregroundColor(.textPrimary)

                Text("Avg \(metric.rawValue)")
                    .textSecondary(font: Typography.labelSmall)

                // Mini sparkline using Chart
                Chart(stats) { item in
                    LineMark(
                        x: .value("D", item.day),
                        y: .value("V", metric.value(from: item))
                    )
                    .foregroundStyle(metric.color.opacity(0.8))
                    .lineStyle(StrokeStyle(lineWidth: 1.5))
                }
                .chartXAxis(.hidden)
                .chartYAxis(.hidden)
                .frame(height: 36)
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(isSelected ? metric.color.opacity(0.5) : Color.clear, lineWidth: 1.5)
        )
    }
}
