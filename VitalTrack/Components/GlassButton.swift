import SwiftUI

/// Upgraded GlassButton with shimmer sweep on press and rich glow effects.
public struct GlassButtonStyle: ButtonStyle {
    var isOutlined: Bool
    var gradient: LinearGradient
    var glowColor: Color
    var cornerRadius: CGFloat

    public init(
        isOutlined: Bool = false,
        gradient: LinearGradient = LinearGradient.primaryGradient,
        glowColor: Color = Color.glowBlue,
        cornerRadius: CGFloat = 16
    ) {
        self.isOutlined = isOutlined
        self.gradient = gradient
        self.glowColor = glowColor
        self.cornerRadius = cornerRadius
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Typography.button)
            .foregroundColor(.white)
            .padding(.vertical, 16)
            .padding(.horizontal, 24)
            .frame(maxWidth: .infinity)
            .background(buttonBackground(isPressed: configuration.isPressed))
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.90 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { _, isPressed in
                if isPressed {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
            }
    }

    @ViewBuilder
    private func buttonBackground(isPressed: Bool) -> some View {
        if isOutlined {
            ZStack {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color.white.opacity(0.06))
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(gradient, lineWidth: 1.5)
            }
        } else {
            ZStack {
                // Gradient fill
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(gradient)

                // Specular top highlight
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(isPressed ? 0.08 : 0.22), Color.clear],
                            startPoint: .top,
                            endPoint: UnitPoint(x: 0.5, y: 0.5)
                        )
                    )
            }
            .shadow(
                color: glowColor.opacity(isPressed ? 0.3 : 0.7),
                radius: isPressed ? 8 : 14,
                x: 0, y: isPressed ? 2 : 6
            )
            // Second wider glow
            .shadow(
                color: glowColor.opacity(isPressed ? 0.1 : 0.35),
                radius: 28,
                x: 0, y: 8
            )
        }
    }
}

public extension Button {
    /// Primary solid glass button
    func glassStyle(
        gradient: LinearGradient = .primaryGradient,
        glowColor: Color = .glowBlue,
        cornerRadius: CGFloat = 16
    ) -> some View {
        self.buttonStyle(GlassButtonStyle(
            isOutlined: false,
            gradient: gradient,
            glowColor: glowColor,
            cornerRadius: cornerRadius
        ))
    }

    /// Secondary outlined glass button
    func glassOutlineStyle(
        gradient: LinearGradient = .primaryGradient,
        cornerRadius: CGFloat = 16
    ) -> some View {
        self.buttonStyle(GlassButtonStyle(
            isOutlined: true,
            gradient: gradient,
            glowColor: .clear,
            cornerRadius: cornerRadius
        ))
    }
}
