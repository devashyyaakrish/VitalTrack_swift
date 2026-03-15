import SwiftUI

// MARK: - Tracker Tab Enum

enum TrackerTab: String, CaseIterable {
    case water    = "Water"
    case steps    = "Steps"
    case calories = "Meals"
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
}

// MARK: - TrackersView

public struct TrackersView: View {
    @Environment(TrackersViewModel.self) private var vm
    @State private var selectedTab: TrackerTab = .water
    @Namespace private var animation

    public init() {}

    public var body: some View {
        GradientBackground {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Health Trackers")
                        .heading(font: Typography.displayMedium)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 12)

                // Tab Picker
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(TrackerTab.allCases, id: \.self) { tab in
                            TrackerPill(
                                tab: tab,
                                isSelected: selectedTab == tab,
                                animation: animation
                            ) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.72)) {
                                    selectedTab = tab
                                }
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                }

                // Page Content — wrapped TabView for swipe gesture
                TabView(selection: $selectedTab) {
                    WaterTrackingView()
                        .tag(TrackerTab.water)

                    StepsTrackingView()
                        .tag(TrackerTab.steps)

                    CaloriesTrackingView()
                        .tag(TrackerTab.calories)

                    SleepTrackingView()
                        .tag(TrackerTab.sleep)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: selectedTab)
            }
        }
    }
}

// MARK: - TrackerPill

private struct TrackerPill: View {
    let tab: TrackerTab
    let isSelected: Bool
    let animation: Namespace.ID
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                Image(systemName: tab.icon)
                    .font(.system(size: 13, weight: .bold))
                Text(tab.rawValue)
                    .font(Typography.labelLarge)
            }
            .foregroundColor(isSelected ? .white : .textSecondary)
            .padding(.horizontal, 18)
            .padding(.vertical, 10)
            .background(
                ZStack {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(tab.color.opacity(0.75))
                            .matchedGeometryEffect(id: "TRACKER_TAB", in: animation)
                            .shadow(color: tab.color.opacity(0.5), radius: 8, x: 0, y: 4)
                    } else {
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(Color.glassWhite)
                    }
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(isSelected ? tab.color.opacity(0.4) : Color.glassBorder, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Water Tracking View

struct WaterTrackingView: View {
    @Environment(TrackersViewModel.self) private var vm
    @State private var showParticle = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 32) {
                Spacer().frame(height: 8)

                // Big Ring
                ZStack {
                    MetricRing(
                        value: vm.waterProgress,
                        gradient: .waterGradient,
                        lineWidth: 18,
                        glowColor: .waterColor
                    ) {
                        VStack(spacing: 6) {
                            Image(systemName: "drop.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.waterColor)
                            Text("\(Int(vm.waterMl)) ml")
                                .heading(font: Typography.headingMedium)
                            Text("of \(Int(vm.waterGoalMl)) ml")
                                .textSecondary(font: Typography.labelMedium)
                        }
                    }
                    .frame(width: 240, height: 240)

                    ParticleBurst(isTriggered: showParticle, color: .waterColor)
                        .frame(width: 240, height: 240)
                }

                // Progress label
                Text("\(Int(vm.waterProgress * 100))% of daily goal")
                    .textSecondary()

                // Add buttons
                GlassCard(padding: 20, tint: .waterColor) {
                    VStack(spacing: 12) {
                        Text("Add Water")
                            .heading(font: Typography.headingSmall)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        HStack(spacing: 12) {
                            ForEach([150.0, 250.0, 350.0, 500.0], id: \.self) { ml in
                                Button("+\(Int(ml))ml") {
                                    vm.addWater(ml)
                                    if vm.waterProgress >= 1.0 {
                                        showParticle = true
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                                            showParticle = false
                                        }
                                    }
                                }
                                .glassStyle(gradient: .waterGradient, glowColor: .waterColor, cornerRadius: 12)
                                .font(Typography.labelMedium)
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)

                Spacer().frame(height: 120)
            }
        }
    }
}

// MARK: - Steps Tracking View

struct StepsTrackingView: View {
    @Environment(TrackersViewModel.self) private var vm
    @State private var showParticle = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 32) {
                Spacer().frame(height: 8)

                ZStack {
                    MetricRing(
                        value: vm.stepsProgress,
                        gradient: .stepsGradient,
                        lineWidth: 18,
                        glowColor: .stepsColor
                    ) {
                        VStack(spacing: 6) {
                            Image(systemName: "shoeprints.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.stepsColor)
                            Text("\(Int(vm.steps).formatted())")
                                .heading(font: Typography.headingMedium)
                            Text("Goal: \(Int(vm.stepsGoal).formatted())")
                                .textSecondary(font: Typography.labelMedium)
                        }
                    }
                    .frame(width: 240, height: 240)

                    ParticleBurst(isTriggered: showParticle, color: .stepsColor)
                        .frame(width: 240, height: 240)
                }

                Text("\(Int(vm.stepsProgress * 100))% of daily goal")
                    .textSecondary()

                GlassCard(padding: 20, tint: .stepsColor) {
                    VStack(spacing: 12) {
                        Text("Sync & Manual")
                            .heading(font: Typography.headingSmall)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        HStack(spacing: 12) {
                            Button("Sync HealthKit") {
                                vm.syncSteps(vm.steps + Double.random(in: 200...500))
                                UINotificationFeedbackGenerator().notificationOccurred(.success)
                            }
                            .glassStyle(gradient: .stepsGradient, glowColor: .stepsColor, cornerRadius: 12)

                            Button("+1000") {
                                vm.syncSteps(min(vm.stepsGoal, vm.steps + 1000))
                            }
                            .glassStyle(gradient: .stepsGradient, glowColor: .stepsColor, cornerRadius: 12)
                        }
                    }
                }
                .padding(.horizontal, 24)

                Spacer().frame(height: 120)
            }
        }
    }
}

// MARK: - Calories Tracking View

struct CaloriesTrackingView: View {
    @Environment(TrackersViewModel.self) private var vm
    @State private var showAddMeal = false
    @State private var newMealName = ""
    @State private var newMealCalories = ""
    @State private var newMealEmoji = "🍽️"

    private let emojiOptions = ["🍗", "🥗", "🍔", "🍕", "🥣", "🍜", "🥤", "🍎", "🫙", "🍫"]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                Spacer().frame(height: 8)

                // Ring Summary
                MetricRing(
                    value: vm.caloriesProgress,
                    gradient: .caloriesGradient,
                    lineWidth: 18,
                    glowColor: .caloriesColor
                ) {
                    VStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.caloriesColor)
                        Text("\(vm.totalCalories)")
                            .heading(font: Typography.headingMedium)
                        Text("of \(vm.calorieGoal) kcal")
                            .textSecondary(font: Typography.labelSmall)
                    }
                }
                .frame(width: 200, height: 200)

                // Macro summary
                GlassCard(padding: 16, tint: .caloriesColor) {
                    HStack {
                        MacroChip(label: "Eaten", value: "\(vm.totalCalories)", color: .caloriesColor)
                        Divider().background(Color.glassBorder).frame(height: 40)
                        MacroChip(label: "Remaining", value: "\(max(0, vm.calorieGoal - vm.totalCalories))", color: .successApp)
                        Divider().background(Color.glassBorder).frame(height: 40)
                        MacroChip(label: "Goal", value: "\(vm.calorieGoal)", color: .textSecondary)
                    }
                }
                .padding(.horizontal, 24)

                // Meals List
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Today's Meals")
                            .heading(font: Typography.headingSmall)
                        Spacer()
                        Button {
                            showAddMeal = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 22))
                                .foregroundStyle(.caloriesGradient)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 24)

                    ForEach(vm.meals) { meal in
                        MealRow(meal: meal)
                            .padding(.horizontal, 24)
                    }
                }

                Spacer().frame(height: 120)
            }
        }
        .sheet(isPresented: $showAddMeal) {
            AddMealSheet(isPresented: $showAddMeal)
                .environment(vm)
                .presentationDetents([.fraction(0.60)])
                .presentationDragIndicator(.visible)
                .presentationBackground(.ultraThinMaterial)
        }
    }
}

private struct MacroChip: View {
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

private struct MealRow: View {
    let meal: MealEntry

    var body: some View {
        GlassCard(padding: 14, cornerRadius: 18) {
            HStack(spacing: 14) {
                Text(meal.emoji)
                    .font(.system(size: 28))

                VStack(alignment: .leading, spacing: 2) {
                    Text(meal.name)
                        .heading(font: Typography.labelLarge)
                    Text(meal.time, style: .time)
                        .textTertiary(font: Typography.labelSmall)
                }

                Spacer()

                Text("\(meal.calories) kcal")
                    .font(Typography.labelMedium)
                    .foregroundColor(.caloriesColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.caloriesColor.opacity(0.15))
                    .clipShape(Capsule())
            }
        }
    }
}

private struct AddMealSheet: View {
    @Environment(TrackersViewModel.self) private var vm
    @Binding var isPresented: Bool

    @State private var name = ""
    @State private var calories = ""
    @State private var emoji = "🍽️"

    private let emojiOptions = ["🍗", "🥗", "🍔", "🍕", "🥣", "🍜", "🥤", "🍎", "🫙", "🍫"]

    var body: some View {
        VStack(spacing: 20) {
            Capsule().fill(Color.glassBorder).frame(width: 36, height: 4).padding(.top, 12)

            Text("Add Meal").heading(font: Typography.headingMedium)

            // Emoji picker
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(emojiOptions, id: \.self) { e in
                        Button(action: { emoji = e }) {
                            Text(e).font(.system(size: 28))
                                .padding(10)
                                .background(
                                    Circle().fill(emoji == e ? Color.caloriesColor.opacity(0.3) : Color.glassWhite)
                                )
                                .overlay(Circle().stroke(emoji == e ? Color.caloriesColor : Color.glassBorder, lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
            }

            VStack(spacing: 12) {
                GlassTextField(placeholder: "Meal name", text: $name, icon: "fork.knife")
                GlassTextField(placeholder: "Calories (kcal)", text: $calories, icon: "flame")
                    .keyboardType(.numberPad)
            }
            .padding(.horizontal, 20)

            HStack(spacing: 12) {
                Button("Cancel") { isPresented = false }
                    .glassOutlineStyle()
                Button("Add") {
                    if let kcal = Int(calories), !name.isEmpty {
                        vm.addMeal(MealEntry(name: name, calories: kcal, emoji: emoji))
                        isPresented = false
                    }
                }
                .glassStyle(gradient: .caloriesGradient, glowColor: .caloriesColor)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }
}

// MARK: - Sleep Tracking View

struct SleepTrackingView: View {
    @Environment(TrackersViewModel.self) private var vm

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 28) {
                Spacer().frame(height: 8)

                // Sleep Duration Ring
                MetricRing(
                    value: vm.sleepProgress,
                    gradient: .sleepGradient,
                    lineWidth: 18,
                    glowColor: .sleepColor
                ) {
                    VStack(spacing: 6) {
                        Image(systemName: "moon.stars.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.sleepColor)
                        Text(String(format: "%.1fh", vm.sleepHours))
                            .heading(font: Typography.headingMedium)
                        Text("of \(Int(vm.sleepGoal))h goal")
                            .textSecondary(font: Typography.labelSmall)
                    }
                }
                .frame(width: 220, height: 220)

                // Sleep quality label
                Text(sleepQualityLabel)
                    .textSecondary()

                // Bed Time & Wake Time pickers
                GlassCard(padding: 20, tint: .sleepColor) {
                    VStack(spacing: 20) {
                        Text("Sleep Schedule")
                            .heading(font: Typography.headingSmall)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        HStack(spacing: 20) {
                            // Bed time
                            VStack(spacing: 8) {
                                Image(systemName: "moon.fill")
                                    .foregroundColor(.sleepColor)
                                Text("Bed Time")
                                    .textTertiary(font: Typography.labelSmall)
                                DatePicker(
                                    "",
                                    selection: Binding(
                                        get: { vm.bedTime },
                                        set: { vm.bedTime = $0 }
                                    ),
                                    displayedComponents: .hourAndMinute
                                )
                                .labelsHidden()
                                .colorScheme(.dark)
                                .tint(.sleepColor)
                            }
                            .frame(maxWidth: .infinity)

                            Divider().background(Color.glassBorder)

                            // Wake time
                            VStack(spacing: 8) {
                                Image(systemName: "sun.rise.fill")
                                    .foregroundColor(.warningApp)
                                Text("Wake Time")
                                    .textTertiary(font: Typography.labelSmall)
                                DatePicker(
                                    "",
                                    selection: Binding(
                                        get: { vm.wakeTime },
                                        set: { vm.wakeTime = $0 }
                                    ),
                                    displayedComponents: .hourAndMinute
                                )
                                .labelsHidden()
                                .colorScheme(.dark)
                                .tint(.warningApp)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
                .padding(.horizontal, 24)

                // Sleep stats chips
                HStack(spacing: 12) {
                    SleepStatChip(icon: "bed.double.fill", label: "Duration",
                                  value: String(format: "%.1f hrs", vm.sleepHours), color: .sleepColor)
                    SleepStatChip(icon: "brain.head.profile", label: "Quality",
                                  value: sleepQualityShort, color: sleepQualityColor)
                }
                .padding(.horizontal, 24)

                Spacer().frame(height: 120)
            }
        }
    }

    private var sleepQualityLabel: String {
        switch vm.sleepHours {
        case 8...:   return "Excellent sleep! You're fully rested. 🌟"
        case 7...:   return "Good sleep! Almost at your goal. 👍"
        case 6...:   return "Fair sleep. Try going to bed earlier. 😴"
        default:     return "Not enough sleep. Prioritize rest! ⚠️"
        }
    }

    private var sleepQualityShort: String {
        switch vm.sleepHours {
        case 8...: return "Excellent"
        case 7...: return "Good"
        case 6...: return "Fair"
        default:   return "Poor"
        }
    }

    private var sleepQualityColor: Color {
        switch vm.sleepHours {
        case 8...: return .successApp
        case 7...: return .stepsColor
        case 6...: return .warningApp
        default:   return .errorApp
        }
    }
}

private struct SleepStatChip: View {
    let icon: String
    let label: String
    let value: String
    let color: Color

    var body: some View {
        GlassCard(padding: 14, cornerRadius: 18, tint: color) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(color)
                Text(value)
                    .heading(font: Typography.labelLarge)
                Text(label)
                    .textTertiary(font: Typography.labelSmall)
            }
            .frame(maxWidth: .infinity)
        }
    }
}
