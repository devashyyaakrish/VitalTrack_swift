import SwiftUI

public struct SettingsView: View {
    @Environment(AppViewModel.self) private var appVM
    @Environment(TrackersViewModel.self) private var trackersVM

    @State private var isDarkMode       = true
    @State private var useMetric        = true
    @State private var waterReminders   = true
    @State private var habitReminders   = true
    @State private var showSignOutAlert = false
    @State private var showDeleteAlert  = false
    @State private var showGoalsSheet   = false

    public init() {}

    public var body: some View {
        GradientBackground {
            VStack(spacing: 0) {
                HStack {
                    Text("Settings")
                        .heading(font: Typography.displayMedium)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 8)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {

                        // MARK: Profile Card
                        profileCard

                        // MARK: Daily Goals
                        SettingsSection(header: "DAILY GOALS") {
                            GoalRow(
                                label: "Water Goal",
                                icon: "drop.fill",
                                color: .waterColor,
                                value: "\(Int(trackersVM.waterGoalMl / 1000 * 10) / 10)L"
                            )
                            Divider().background(Color.glassBorder).padding(.leading, 48)
                            GoalRow(
                                label: "Step Goal",
                                icon: "shoeprints.fill",
                                color: .stepsColor,
                                value: "\(Int(trackersVM.stepsGoal).formatted())"
                            )
                            Divider().background(Color.glassBorder).padding(.leading, 48)
                            GoalRow(
                                label: "Calorie Goal",
                                icon: "flame.fill",
                                color: .caloriesColor,
                                value: "\(trackersVM.calorieGoal) kcal"
                            )
                            Divider().background(Color.glassBorder).padding(.leading, 48)
                            GoalRow(
                                label: "Sleep Goal",
                                icon: "moon.zzz.fill",
                                color: .sleepColor,
                                value: "\(Int(trackersVM.sleepGoal))h"
                            )
                        }

                        // MARK: Preferences
                        SettingsSection(header: "PREFERENCES") {
                            SettingsToggle(
                                title: "Dark Mode",
                                icon: "moon.fill",
                                iconColor: .secondaryAccent,
                                isOn: $isDarkMode
                            )
                            Divider().background(Color.glassBorder).padding(.leading, 48)
                            SettingsToggle(
                                title: "Metric Units",
                                subtitle: useMetric ? "kg, cm, ml" : "lbs, ft, oz",
                                icon: "ruler.fill",
                                iconColor: .stepsColor,
                                isOn: $useMetric
                            )
                        }

                        // MARK: Notifications
                        SettingsSection(header: "NOTIFICATIONS") {
                            SettingsToggle(
                                title: "Water Reminders",
                                icon: "drop.fill",
                                iconColor: .waterColor,
                                isOn: $waterReminders
                            )
                            Divider().background(Color.glassBorder).padding(.leading, 48)
                            SettingsToggle(
                                title: "Habit Reminders",
                                icon: "bell.fill",
                                iconColor: .habitsColor,
                                isOn: $habitReminders
                            )
                        }

                        // MARK: Account
                        SettingsSection(header: "ACCOUNT") {
                            Button(action: { showSignOutAlert = true }) {
                                SettingsRow(title: "Sign Out", titleColor: .warningApp,
                                           icon: "rectangle.portrait.and.arrow.right", iconColor: .warningApp)
                            }
                            .buttonStyle(.plain)
                            Divider().background(Color.glassBorder).padding(.leading, 48)
                            Button(action: { showDeleteAlert = true }) {
                                SettingsRow(title: "Delete Account", titleColor: .errorApp,
                                           icon: "trash.fill", iconColor: .errorApp)
                            }
                            .buttonStyle(.plain)
                        }

                        // Version
                        Text("VitalTrack v2.0 · SwiftUI")
                            .textTertiary(font: Typography.labelSmall)
                            .tracking(0.5)
                            .padding(.bottom, 120)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                }
            }
        }
        .alert("Sign Out", isPresented: $showSignOutAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Sign Out", role: .destructive) { appVM.signOut() }
        } message: {
            Text("Are you sure you want to sign out?")
        }
        .alert("Delete Account?", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) { appVM.signOut() }
        } message: {
            Text("This action is permanent and will delete all your data.")
        }
    }

    // MARK: - Profile Card

    private var profileCard: some View {
        GlassCard(padding: 20) {
            HStack(spacing: 16) {
                // Avatar with gradient ring
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "2563EB"), Color(hex: "7C3AED")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 68, height: 68)

                    Text(String(appVM.userName.prefix(1)).uppercased())
                        .font(Typography.displayMedium)
                        .foregroundColor(.white)
                }
                .shadow(color: Color(hex: "4F46E5").opacity(0.5), radius: 10)

                VStack(alignment: .leading, spacing: 4) {
                    Text(appVM.userName)
                        .heading(font: Typography.headingMedium)
                    Text(appVM.userEmail)
                        .textSecondary(font: Typography.bodyMedium)

                    // Health score badge
                    HStack(spacing: 6) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.habitsColor)
                        Text("Health Score: \(Int(trackersVM.healthScore * 100))")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.habitsColor)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.habitsColor.opacity(0.15))
                    .clipShape(Capsule())
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.textTertiary)
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [Color(hex: "2563EB").opacity(0.4), Color(hex: "7C3AED").opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }
}

// MARK: - Settings Helpers

private struct SettingsSection<Content: View>: View {
    let header: String
    let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(header)
                .font(Typography.labelSmall)
                .tracking(1.4)
                .foregroundColor(.textTertiary)
                .padding(.leading, 8)

            VStack(spacing: 0) { content() }
                .glassEffect(cornerRadius: 20)
        }
    }
}

private struct SettingsToggle: View {
    let title: String
    var subtitle: String? = nil
    let icon: String
    let iconColor: Color
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 15))
                .foregroundColor(iconColor)
                .frame(width: 32, height: 32)
                .background(iconColor.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 2) {
                Text(title).heading(font: Typography.labelLarge)
                if let sub = subtitle {
                    Text(sub).textSecondary(font: Typography.labelSmall)
                }
            }
            Spacer()

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(.primaryButton)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}

private struct SettingsRow: View {
    let title: String
    let titleColor: Color
    let icon: String
    let iconColor: Color

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 15))
                .foregroundColor(iconColor)
                .frame(width: 32, height: 32)
                .background(iconColor.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            Text(title)
                .heading(font: Typography.labelLarge)
                .foregroundColor(titleColor)

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(.textTertiary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}

private struct GoalRow: View {
    let label: String
    let icon: String
    let color: Color
    let value: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 15))
                .foregroundColor(color)
                .frame(width: 32, height: 32)
                .background(color.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            Text(label).heading(font: Typography.labelLarge)

            Spacer()

            Text(value)
                .font(Typography.labelMedium)
                .foregroundColor(color)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(color.opacity(0.12))
                .clipShape(Capsule())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}
