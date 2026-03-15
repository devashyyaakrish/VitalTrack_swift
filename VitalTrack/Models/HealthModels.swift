import Foundation
import SwiftUI

// MARK: - MetricData

/// Shared metric model representing one health KPI card.
public struct MetricData: Identifiable {
    public let id = UUID()
    let title: String
    let subtitle: String
    var value: Double // 0.0 to 1.0
    let displayValue: String
    let iconName: String
    let color: Color
    let gradient: LinearGradient
}

// MARK: - Calorie Models

public struct MealEntry: Identifiable {
    public let id = UUID()
    var name: String
    var calories: Int
    var emoji: String
    var time: Date = Date()
}

// MARK: - Sleep Model

public struct SleepEntry: Identifiable {
    public let id = UUID()
    var bedTime: Date
    var wakeTime: Date

    var durationHours: Double {
        max(0, wakeTime.timeIntervalSince(bedTime) / 3600)
    }
}

// MARK: - Weekly Analytics

public struct DayStats: Identifiable {
    public let id = UUID()
    let day: String
    let water: Double   // ml
    let steps: Double
    let calories: Double // kcal
    let sleep: Double   // hours
}

// MARK: - Mock Data

public struct MockData {
    public static let sharedMetrics: [MetricData] = [
        MetricData(title: "Water",    subtitle: "Goal: 2.5L",       value: 0.65, displayValue: "1.6L",   iconName: "drop.fill",      color: .waterColor,    gradient: .waterGradient),
        MetricData(title: "Steps",    subtitle: "Goal: 10,000",     value: 0.80, displayValue: "8,432",  iconName: "shoeprints.fill", color: .stepsColor,    gradient: .stepsGradient),
        MetricData(title: "Calories", subtitle: "Goal: 2,400 kcal", value: 0.50, displayValue: "1,200",  iconName: "flame.fill",     color: .caloriesColor, gradient: .caloriesGradient),
        MetricData(title: "Sleep",    subtitle: "Goal: 8h",         value: 0.90, displayValue: "7.2h",   iconName: "moon.zzz.fill",  color: .sleepColor,    gradient: .sleepGradient)
    ]

    public static let weeklyStats: [DayStats] = [
        DayStats(day: "Mon", water: 1200, steps: 4500,  calories: 1800, sleep: 6.5),
        DayStats(day: "Tue", water: 1800, steps: 8200,  calories: 2100, sleep: 7.0),
        DayStats(day: "Wed", water: 2100, steps: 10400, calories: 2350, sleep: 8.0),
        DayStats(day: "Thu", water: 1600, steps: 6500,  calories: 1950, sleep: 6.0),
        DayStats(day: "Fri", water: 2400, steps: 11200, calories: 2200, sleep: 7.5),
        DayStats(day: "Sat", water: 1400, steps: 5400,  calories: 1700, sleep: 8.5),
        DayStats(day: "Sun", water: 2200, steps: 9800,  calories: 2050, sleep: 7.2)
    ]

    public static let sampleMeals: [MealEntry] = [
        MealEntry(name: "Oatmeal & Berries",  calories: 320, emoji: "🥣"),
        MealEntry(name: "Grilled Chicken",    calories: 480, emoji: "🍗"),
        MealEntry(name: "Greek Yogurt",       calories: 150, emoji: "🫙"),
        MealEntry(name: "Protein Shake",      calories: 220, emoji: "🥤")
    ]
}
