import SwiftUI
import Observation

// MARK: - TrackersViewModel

/// @Observable ViewModel managing all health tracker state.
/// Connects to views via the SwiftUI environment.
@Observable
public final class TrackersViewModel {

    // MARK: - Water
    var waterMl: Double = 1600
    var waterGoalMl: Double = 2500

    var waterProgress: Double { min(1.0, waterMl / waterGoalMl) }

    func addWater(_ ml: Double) {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            waterMl = min(waterGoalMl, waterMl + ml)
        }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    // MARK: - Steps
    var steps: Double = 8432
    var stepsGoal: Double = 10_000

    var stepsProgress: Double { min(1.0, steps / stepsGoal) }

    func syncSteps(_ newSteps: Double) {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            steps = newSteps
        }
    }

    // MARK: - Calories
    var meals: [MealEntry] = MockData.sampleMeals
    var calorieGoal: Int = 2400

    var totalCalories: Int { meals.reduce(0) { $0 + $1.calories } }
    var caloriesProgress: Double { min(1.0, Double(totalCalories) / Double(calorieGoal)) }

    func addMeal(_ meal: MealEntry) {
        withAnimation { meals.append(meal) }
    }

    func removeMeal(at offsets: IndexSet) {
        withAnimation { meals.remove(atOffsets: offsets) }
    }

    // MARK: - Sleep
    var bedTime: Date = Calendar.current.date(bySettingHour: 23, minute: 0, second: 0, of: Date()) ?? Date()
    var wakeTime: Date = Calendar.current.date(bySettingHour: 7, minute: 12, second: 0, of: Date()) ?? Date()

    var sleepEntry: SleepEntry { SleepEntry(bedTime: bedTime, wakeTime: wakeTime) }
    var sleepHours: Double { sleepEntry.durationHours }
    var sleepGoal: Double = 8.0
    var sleepProgress: Double { min(1.0, sleepHours / sleepGoal) }

    // MARK: - Overall Health Score
    var healthScore: Double {
        (waterProgress + stepsProgress + caloriesProgress + sleepProgress) / 4.0
    }

    // MARK: - Dashboard Metrics (computed for DashboardView)
    var dashboardMetrics: [MetricData] {
        [
            MetricData(
                title: "Water", subtitle: "Goal: \(Int(waterGoalMl / 1000))L",
                value: waterProgress, displayValue: String(format: "%.1fL", waterMl / 1000),
                iconName: "drop.fill", color: .waterColor, gradient: .waterGradient
            ),
            MetricData(
                title: "Steps", subtitle: "Goal: \(Int(stepsGoal))",
                value: stepsProgress, displayValue: "\(Int(steps).formatted())",
                iconName: "shoeprints.fill", color: .stepsColor, gradient: .stepsGradient
            ),
            MetricData(
                title: "Calories", subtitle: "Goal: \(calorieGoal) kcal",
                value: caloriesProgress, displayValue: "\(totalCalories)",
                iconName: "flame.fill", color: .caloriesColor, gradient: .caloriesGradient
            ),
            MetricData(
                title: "Sleep", subtitle: "Goal: \(Int(sleepGoal))h",
                value: sleepProgress, displayValue: String(format: "%.1fh", sleepHours),
                iconName: "moon.zzz.fill", color: .sleepColor, gradient: .sleepGradient
            )
        ]
    }
}
