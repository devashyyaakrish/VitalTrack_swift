import Foundation
import SwiftUI

// MARK: - HabitModel

public struct HabitModel: Identifiable {
    public let id = UUID()
    var name: String
    var emoji: String
    var currentStreak: Int
    var isCompletedToday: Bool
    var milestoneStreak: Int = 7 // Celebrate at this streak milestone
}

// MARK: - HabitsView

public struct HabitsView: View {
    @State private var habits: [HabitModel] = [
        HabitModel(name: "Drink Water",  emoji: "💧", currentStreak: 12, isCompletedToday: true),
        HabitModel(name: "Read 10 pages",emoji: "📚", currentStreak: 4,  isCompletedToday: false),
        HabitModel(name: "Meditate",     emoji: "🧘", currentStreak: 21, isCompletedToday: false)
    ]
    @State private var showAddSheet = false

    public init() {}

    public var body: some View {
        GradientBackground {
            VStack {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Habit Tracker")
                            .heading(font: Typography.displayMedium)
                        Text("\(habits.filter(\.isCompletedToday).count)/\(habits.count) done today")
                            .textSecondary(font: Typography.labelMedium)
                    }
                    Spacer()
                    Button(action: { showAddSheet = true }) {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .padding(14)
                            .background(LinearGradient.habitsGradient)
                            .clipShape(Circle())
                            .shadow(color: Color.habitsColor.opacity(0.55), radius: 10, x: 0, y: 5)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)

                // Daily streak summary bar
                if !habits.isEmpty {
                    todaySummaryBar
                        .padding(.horizontal, 20)
                        .padding(.top, 12)
                }

                if habits.isEmpty {
                    emptyState
                } else {
                    habitList
                }
            }
        }
        .sheet(isPresented: $showAddSheet) {
            AddHabitSheet(habits: $habits)
                .presentationDetents([.fraction(0.65)])
                .presentationDragIndicator(.visible)
                .presentationBackground(.ultraThinMaterial)
        }
    }

    // MARK: - Today Progress Bar

    private var todaySummaryBar: some View {
        let done = habits.filter(\.isCompletedToday).count
        let total = habits.count
        let progress = total > 0 ? Double(done) / Double(total) : 0

        return GlassCard(padding: 14, cornerRadius: 18) {
            VStack(spacing: 8) {
                HStack {
                    Text("Today's Progress")
                        .textTertiary(font: Typography.labelSmall)
                    Spacer()
                    Text("\(done) of \(total)")
                        .font(Typography.labelSmall)
                        .foregroundColor(.habitsColor)
                }
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4).fill(Color.glassWhite)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(LinearGradient.habitsGradient)
                            .frame(width: geo.size.width * progress)
                            .animation(.spring(response: 0.5, dampingFraction: 0.75), value: progress)
                    }
                }
                .frame(height: 6)
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "sparkles")
                .font(.system(size: 64, weight: .thin))
                .foregroundStyle(LinearGradient.habitsGradient)
                .symbolEffect(.pulse)
            Text("No Habits Yet")
                .heading(font: Typography.headingLarge)
            Text("Build great routines, one day at a time.\nSmall steps create big changes.")
                .textSecondary()
                .multilineTextAlignment(.center)
            Button("Create First Habit") { showAddSheet = true }
                .glassStyle(gradient: .habitsGradient, glowColor: .habitsColor)
                .padding(.top, 16)
                .padding(.horizontal, 48)
            Spacer()
        }
    }

    // MARK: - Habits List

    private var habitList: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 12) {
                ForEach($habits) { $habit in
                    HabitCard(habit: $habit)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 120)
        }
    }
}

// MARK: - HabitCard

struct HabitCard: View {
    @Binding var habit: HabitModel

    @State private var showParticle = false
    @State private var showMilestone = false

    var body: some View {
        ZStack {
            GlassCard(
                padding: 16,
                cornerRadius: 20,
                tint: habit.isCompletedToday ? .successApp : .clear
            ) {
                HStack(spacing: 14) {
                    // Emoji with completion ring
                    ZStack {
                        Circle()
                            .stroke(
                                habit.isCompletedToday
                                    ? LinearGradient(colors: [Color.successApp, Color.stepsColor], startPoint: .topLeading, endPoint: .bottomTrailing)
                                    : LinearGradient(colors: [Color.glassBorder, Color.glassBorder], startPoint: .top, endPoint: .bottom),
                                lineWidth: 2
                            )
                            .frame(width: 52, height: 52)

                        Text(habit.emoji)
                            .font(.system(size: 24))
                    }

                    // Name and streak
                    VStack(alignment: .leading, spacing: 6) {
                        Text(habit.name)
                            .font(Typography.labelLarge)
                            .fontWeight(.semibold)
                            .foregroundColor(habit.isCompletedToday ? .textSecondary : .textPrimary)
                            .strikethrough(habit.isCompletedToday, color: .textSecondary)

                        HStack(spacing: 6) {
                            Text("🔥")
                                .font(.system(size: 13))
                            Text("\(habit.currentStreak) day streak")
                                .textSecondary(font: Typography.labelSmall)

                            // Milestone badge
                            if habit.currentStreak > 0 && habit.currentStreak % 7 == 0 {
                                Text("🏆 Milestone!")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.warningApp)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.warningApp.opacity(0.15))
                                    .clipShape(Capsule())
                            }
                        }
                    }

                    Spacer()

                    // Toggle Button
                    Button(action: toggleHabit) {
                        ZStack {
                            Circle()
                                .fill(habit.isCompletedToday ? Color.successApp : Color.glassWhite)
                                .frame(width: 36, height: 36)
                                .shadow(color: habit.isCompletedToday ? Color.successApp.opacity(0.5) : .clear, radius: 8)

                            Image(systemName: habit.isCompletedToday ? "checkmark" : "plus")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(habit.isCompletedToday ? .white : .textSecondary)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }

            // Particle burst overlay
            ParticleBurst(isTriggered: showParticle, color: .successApp)
                .frame(width: 200, height: 200)
                .allowsHitTesting(false)
        }
    }

    private func toggleHabit() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            habit.isCompletedToday.toggle()
            if habit.isCompletedToday {
                habit.currentStreak += 1
                showParticle = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    showParticle = false
                }
                // Milestone haptic
                if habit.currentStreak % 7 == 0 {
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                }
            } else {
                habit.currentStreak = max(0, habit.currentStreak - 1)
            }
        }
    }
}

// MARK: - Add Habit Sheet

struct AddHabitSheet: View {
    @Binding var habits: [HabitModel]
    @Environment(\.dismiss) var dismiss

    @State private var name = ""
    @State private var emoji = "🎯"

    let emojis = ["✅","💧","🏃","📚","🧘","🥗","💻","☀️","🎯","🎵","🌙","💊","🧹","🎨","🏊"]

    var body: some View {
        ZStack {
            Color.backgroundDeep.ignoresSafeArea()

            VStack(spacing: 0) {
                Capsule().fill(Color.glassBorder).frame(width: 36, height: 4).padding(.top, 12).padding(.bottom, 20)

                VStack(alignment: .leading, spacing: 6) {
                    Text("New Habit").heading(font: Typography.displayMedium)
                    Text("Choose an emoji and give it a name").textSecondary()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)

                Spacer().frame(height: 24)

                // Emoji Grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 14) {
                    ForEach(emojis, id: \.self) { e in
                        Button(action: { emoji = e }) {
                            Text(e).font(.system(size: 28))
                                .padding(12)
                                .background(Circle().fill(emoji == e ? Color.habitsColor.opacity(0.3) : Color.glassWhite))
                                .overlay(Circle().stroke(emoji == e ? Color.habitsColor : Color.glassBorder, lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)

                GlassTextField(placeholder: "Habit name (e.g. Meditate)", text: $name, icon: "pencil")
                    .padding(.horizontal, 24)

                Spacer()

                HStack(spacing: 14) {
                    Button("Cancel") { dismiss() }.glassOutlineStyle()
                    Button("Create") {
                        if !name.isEmpty {
                            habits.append(HabitModel(name: name, emoji: emoji, currentStreak: 0, isCompletedToday: false))
                            dismiss()
                        }
                    }.glassStyle(gradient: .habitsGradient, glowColor: .habitsColor)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
    }
}
