import SwiftUI

// MARK: - Liquid Glass Modifier (Enhanced)

/// Advanced liquid glass effect with dual-layer frosted material, animated shimmer,
/// specular top-edge highlight, and optional tint for per-metric coloring.
public struct LiquidGlassModifier: ViewModifier {
    var cornerRadius: CGFloat
    var tintColor: Color
    var intensity: Double // 0.0 to 1.0

    @State private var shimmerOffset: CGFloat = -1.0

    public func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    // Layer 1: Deep frosted base
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(.ultraThinMaterial)

                    // Layer 2: Subtle tint overlay for metric coloring
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(tintColor.opacity(0.08 * intensity))

                    // Layer 3: Inner bright highlight (top portion)
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.18), Color.clear],
                                startPoint: .top,
                                endPoint: UnitPoint(x: 0.5, y: 0.45)
                            )
                        )

                    // Layer 4: Shimmer streak animation
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.clear,
                                    Color.white.opacity(0.35),
                                    Color.white.opacity(0.12),
                                    Color.clear
                                ],
                                startPoint: UnitPoint(x: shimmerOffset, y: 0),
                                endPoint: UnitPoint(x: shimmerOffset + 0.5, y: 1)
                            )
                        )
                }
            )
            // Specular top-edge border
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.55),
                                Color.white.opacity(0.15),
                                Color.white.opacity(0.0)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.2
                    )
            )
            // Subtle tint glow border when tinted
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(tintColor.opacity(0.25 * intensity), lineWidth: 0.8)
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            // Layered shadows for depth
            .shadow(color: Color.black.opacity(0.28), radius: 16, x: 0, y: 8)
            .shadow(color: tintColor.opacity(0.20 * intensity), radius: 24, x: 0, y: 4)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 1.4).delay(0.1)
                ) {
                    shimmerOffset = 1.2
                }
            }
    }
}

// MARK: - Standard Glass Modifier (Preserved + Upgraded)

/// Original glass modifier, now using LiquidGlassModifier underneath for consistency.
public struct GlassModifier: ViewModifier {
    var cornerRadius: CGFloat

    public func body(content: Content) -> some View {
        content
            .modifier(LiquidGlassModifier(cornerRadius: cornerRadius, tintColor: .clear, intensity: 0))
    }
}

// MARK: - View Extensions

public extension View {
    /// Standard glass effect (neutral, no tint)
    func glassEffect(cornerRadius: CGFloat = 24) -> some View {
        self.modifier(GlassModifier(cornerRadius: cornerRadius))
    }

    /// Liquid glass with a specific tint color — used for metric-themed cards
    func liquidGlass(cornerRadius: CGFloat = 24, tint: Color = .clear, intensity: Double = 1.0) -> some View {
        self.modifier(LiquidGlassModifier(cornerRadius: cornerRadius, tintColor: tint, intensity: intensity))
    }
}

// MARK: - GlassCard Component

/// A pre-configured Glass Card component using the upgraded liquid glass effect.
public struct GlassCard<Content: View>: View {
    var padding: CGFloat
    var cornerRadius: CGFloat
    var tint: Color
    let content: () -> Content

    public init(
        padding: CGFloat = 20,
        cornerRadius: CGFloat = 24,
        tint: Color = .clear,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.tint = tint
        self.content = content
    }

    public var body: some View {
        content()
            .padding(padding)
            .liquidGlass(cornerRadius: cornerRadius, tint: tint, intensity: tint == .clear ? 0 : 1)
    }
}

// MARK: - Pressable Glass Card

/// A glass card that scales on press with haptic feedback.
public struct PressableGlassCard<Content: View>: View {
    var padding: CGFloat
    var cornerRadius: CGFloat
    var tint: Color
    let onTap: () -> Void
    let content: () -> Content

    @State private var isPressed = false

    public init(
        padding: CGFloat = 16,
        cornerRadius: CGFloat = 20,
        tint: Color = .clear,
        onTap: @escaping () -> Void = {},
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.tint = tint
        self.onTap = onTap
        self.content = content
    }

    public var body: some View {
        content()
            .padding(padding)
            .liquidGlass(cornerRadius: cornerRadius, tint: tint, intensity: tint == .clear ? 0 : 1)
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: isPressed)
            .onTapGesture {
                let impact = UIImpactFeedbackGenerator(style: .light)
                impact.impactOccurred()
                onTap()
            }
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in isPressed = true }
                    .onEnded   { _ in isPressed = false }
            )
    }
}
