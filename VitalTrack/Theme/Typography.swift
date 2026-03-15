import SwiftUI

/// Premium Typography mapping utilizing Apple's native San Francisco (SF) font
public struct Typography {

    /// Huge display titles (e.g., Dashboard Hero)
    public static let displayLarge  = Font.system(size: 34, weight: .heavy, design: .rounded)
    public static let displayMedium = Font.system(size: 28, weight: .heavy, design: .rounded)

    /// Standard section headers
    public static let headingLarge  = Font.system(size: 24, weight: .bold,    design: .default)
    public static let headingMedium = Font.system(size: 20, weight: .bold,    design: .default)
    public static let headingSmall  = Font.system(size: 18, weight: .semibold, design: .default)

    /// Standard body text
    public static let bodyLarge  = Font.system(size: 16, weight: .regular, design: .default)
    public static let bodyMedium = Font.system(size: 14, weight: .regular, design: .default)
    public static let bodySmall  = Font.system(size: 12, weight: .regular, design: .default)

    /// Labels and sub-text
    public static let labelLarge  = Font.system(size: 14, weight: .medium, design: .default)
    public static let labelMedium = Font.system(size: 12, weight: .medium, design: .default)
    public static let labelSmall  = Font.system(size: 10, weight: .medium, design: .default)

    /// Specialized Button Text
    public static let button = Font.system(size: 16, weight: .bold, design: .default)
}

/// Shared ViewModifier for text appearance
struct MainTextModifier: ViewModifier {
    var font: Font
    var color: Color
    var lineLimit: Int?

    func body(content: Content) -> some View {
        content
            .font(font)
            .foregroundColor(color)
            .lineLimit(lineLimit)
    }
}

public extension View {
    /// Applies primary text styling (white, medium body)
    func textPrimary(font: Font = Typography.bodyMedium) -> some View {
        self.modifier(MainTextModifier(font: font, color: .textPrimary, lineLimit: nil))
    }

    /// Applies secondary text styling (65% white)
    func textSecondary(font: Font = Typography.bodyMedium) -> some View {
        self.modifier(MainTextModifier(font: font, color: .textSecondary, lineLimit: nil))
    }

    /// Applies heading styling (white, strong weight, 1 line)
    func heading(font: Font = Typography.headingMedium) -> some View {
        self.modifier(MainTextModifier(font: font, color: .textPrimary, lineLimit: 1))
    }

    // Note: textTertiary is defined in AppColors.swift to avoid circular module dependency
}
