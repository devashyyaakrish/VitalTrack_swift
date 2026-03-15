import SwiftUI

/// Upgraded animated circular progress indicator.
/// Features a glowing trailing-dot at the ring tip and per-metric glow shadow.
public struct MetricRing<CenteredContent: View>: View {
    var value: Double /// Progress from 0.0 to 1.0
    var gradient: LinearGradient
    var lineWidth: CGFloat
    var glowColor: Color
    let content: () -> CenteredContent

    @State private var animatedValue: Double = 0.0
    @State private var rotationDegrees: Double = 0.0

    public init(
        value: Double,
        gradient: LinearGradient = .primaryGradient,
        lineWidth: CGFloat = 12,
        glowColor: Color = .glowBlue,
        @ViewBuilder content: @escaping () -> CenteredContent
    ) {
        self.value = max(0.0, min(1.0, value))
        self.gradient = gradient
        self.lineWidth = lineWidth
        self.glowColor = glowColor
        self.content = content
    }

    public var body: some View {
        ZStack {
            // Background track
            Circle()
                .stroke(
                    Color.white.opacity(0.07),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )

            // Secondary background halo
            Circle()
                .stroke(
                    glowColor.opacity(0.12),
                    style: StrokeStyle(lineWidth: lineWidth + 6, lineCap: .round)
                )
                .blur(radius: 4)

            // Foreground progress arc (gradient)
            Circle()
                .trim(from: 0.0, to: animatedValue)
                .stroke(
                    gradient,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .shadow(color: glowColor.opacity(0.65), radius: lineWidth, x: 0, y: 0)
                .animation(.spring(response: 0.9, dampingFraction: 0.72, blendDuration: 0), value: animatedValue)

            // Glowing trailing dot at the ring tip
            if animatedValue > 0.02 {
                tipDot
                    .animation(.spring(response: 0.9, dampingFraction: 0.72), value: animatedValue)
            }

            // Centered child content
            content()
        }
        .onAppear {
            withAnimation(.spring(response: 0.9, dampingFraction: 0.72).delay(0.15)) {
                animatedValue = value
            }
        }
        .onChange(of: value) { _, newValue in
            withAnimation(.spring(response: 0.7, dampingFraction: 0.7)) {
                animatedValue = newValue
            }
        }
    }

    private var tipDot: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let radius = (size - lineWidth) / 2
            let angle = (animatedValue * 360 - 90) * .pi / 180
            let cx = geo.size.width / 2
            let cy = geo.size.height / 2
            let dotX = cx + radius * CGFloat(cos(angle))
            let dotY = cy + radius * CGFloat(sin(angle))

            Circle()
                .fill(Color.white)
                .frame(width: lineWidth + 2, height: lineWidth + 2)
                .shadow(color: glowColor.opacity(0.9), radius: 8, x: 0, y: 0)
                .shadow(color: glowColor.opacity(0.4), radius: 16, x: 0, y: 0)
                .position(x: dotX, y: dotY)
        }
    }
}
