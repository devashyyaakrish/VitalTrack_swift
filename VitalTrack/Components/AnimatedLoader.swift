import SwiftUI

// MARK: - Orbital Ring Loader

/// An orbital ring loader with 3 offset rotating circles — premium replacement for the pulsing dots.
public struct AnimatedLoader: View {
    var color: Color = .primaryButton

    @State private var rotation: Double = 0

    public init(color: Color = .primaryButton) {
        self.color = color
    }

    public var body: some View {
        ZStack {
            // Core glowing center
            Circle()
                .fill(color.opacity(0.25))
                .frame(width: 16, height: 16)
                .blur(radius: 4)

            Circle()
                .fill(color)
                .frame(width: 8, height: 8)

            // Orbital ring 1
            OrbitalDot(color: color, radius: 18, size: 7, phaseOffset: 0, duration: 1.1, rotation: rotation)
            // Orbital ring 2
            OrbitalDot(color: color.opacity(0.7), radius: 28, size: 5, phaseOffset: 0.5, duration: 1.5, rotation: rotation)
            // Orbital ring 3
            OrbitalDot(color: color.opacity(0.45), radius: 38, size: 4, phaseOffset: 0.25, duration: 2.0, rotation: rotation)
        }
        .onAppear {
            withAnimation(.linear(duration: 1.8).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}

private struct OrbitalDot: View {
    let color: Color
    let radius: CGFloat
    let size: CGFloat
    let phaseOffset: Double
    let duration: Double
    let rotation: Double

    var body: some View {
        let angle = Angle.degrees((rotation * (1 / duration)) + (phaseOffset * 360))
        let x = CGFloat(cos(angle.radians)) * radius
        let y = CGFloat(sin(angle.radians)) * radius

        Circle()
            .fill(color)
            .frame(width: size, height: size)
            .shadow(color: color.opacity(0.8), radius: 4, x: 0, y: 0)
            .offset(x: x, y: y)
    }
}

// MARK: - Animated Checkmark

public struct AnimatedCheckmark: View {
    @State private var animateDraw = false
    @State private var animateScale = false
    @State private var animateGlow = false

    var color: Color = .successApp

    public init(color: Color = .successApp) {
        self.color = color
    }

    public var body: some View {
        ZStack {
            // Outer glow ring
            Circle()
                .stroke(color.opacity(animateGlow ? 0 : 0.4), lineWidth: 2)
                .frame(width: 100, height: 100)
                .scaleEffect(animateGlow ? 1.6 : 1.0)
                .opacity(animateGlow ? 0 : 1)

            // Background circle
            Circle()
                .fill(color.opacity(0.15))
                .frame(width: 80, height: 80)
                .scaleEffect(animateScale ? 1.0 : 0.0)

            // Checkmark icon
            Image(systemName: "checkmark")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(color)
                .scaleEffect(animateScale ? 1.0 : 0.0)
                .clipShape(
                    Rectangle()
                        .offset(x: animateDraw ? 0 : -80)
                )
        }
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                animateScale = true
            }
            withAnimation(.easeOut(duration: 0.4).delay(0.2)) {
                animateDraw = true
            }
            withAnimation(.easeOut(duration: 0.9).delay(0.3)) {
                animateGlow = true
            }
        }
    }
}

// MARK: - Shimmer Placeholder (for loading skeleton)

/// A shimmering rectangle for skeleton loading state.
public struct ShimmerBlock: View {
    var width: CGFloat?
    var height: CGFloat
    var cornerRadius: CGFloat

    @State private var phase: CGFloat = -1

    public init(width: CGFloat? = nil, height: CGFloat = 20, cornerRadius: CGFloat = 8) {
        self.width = width
        self.height = height
        self.cornerRadius = cornerRadius
    }

    public var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(Color.white.opacity(0.06))
            .overlay(
                GeometryReader { geo in
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.clear, Color.white.opacity(0.15), Color.clear],
                                startPoint: UnitPoint(x: phase, y: 0.5),
                                endPoint: UnitPoint(x: phase + 0.5, y: 0.5)
                            )
                        )
                }
            )
            .frame(width: width, height: height)
            .onAppear {
                withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                    phase = 1.2
                }
            }
    }
}
