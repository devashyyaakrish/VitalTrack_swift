import SwiftUI

// MARK: - Particle Model
private struct Particle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var speed: Double
    var angle: Double
    var color: Color
    var size: CGFloat
    var opacity: Double = 1.0
}

// MARK: - Particle Burst View

/// A Canvas-based celebration burst when a goal is hit or habit is completed.
/// Place above the triggering element via `.overlay` or in a `ZStack`.
public struct ParticleBurst: View {
    let isTriggered: Bool
    var color: Color = .primaryButton
    var particleCount: Int = 24

    @State private var particles: [Particle] = []
    @State private var animationProgress: Double = 0

    private let colors: [Color] = [
        .waterColor, .stepsColor, .caloriesColor,
        .sleepColor, .habitsColor, .secondaryAccent, .glowCyan
    ]

    public init(isTriggered: Bool, color: Color = .primaryButton, particleCount: Int = 24) {
        self.isTriggered = isTriggered
        self.color = color
        self.particleCount = particleCount
    }

    public var body: some View {
        TimelineView(.animation(minimumInterval: 1/60, paused: !isTriggered)) { timeline in
            Canvas { context, size in
                for particle in particles {
                    let t = animationProgress
                    let dx = CGFloat(cos(particle.angle)) * particle.speed * t * 80
                    let dy = CGFloat(sin(particle.angle)) * particle.speed * t * 80 + CGFloat(t * t * 120) // gravity
                    let px = size.width / 2 + particle.x + dx
                    let py = size.height / 2 + particle.y + dy
                    let fade = max(0, 1.0 - t * 1.2)
                    let sz = particle.size * (1 - t * 0.5)

                    let ellipse = Path(ellipseIn: CGRect(
                        x: px - sz/2, y: py - sz/2,
                        width: sz, height: sz
                    ))
                    context.opacity = fade
                    context.fill(ellipse, with: .color(particle.color))
                }
            }
        }
        .allowsHitTesting(false)
        .onChange(of: isTriggered) { _, newVal in
            if newVal { triggerBurst() }
        }
    }

    private func triggerBurst() {
        particles = (0..<particleCount).map { _ in
            Particle(
                x: CGFloat.random(in: -10...10),
                y: CGFloat.random(in: -10...10),
                speed: Double.random(in: 0.6...1.4),
                angle: Double.random(in: 0...(2 * .pi)),
                color: colors.randomElement() ?? color,
                size: CGFloat.random(in: 6...14)
            )
        }
        animationProgress = 0
        withAnimation(.easeOut(duration: 1.1)) {
            animationProgress = 1.0
        }
    }
}

// MARK: - Sparkle Ring

/// A glowing ring that pops out and fades — for confirming taps on metric updates.
public struct SparkleRing: View {
    let isTriggered: Bool
    var color: Color = .primaryButton

    @State private var scale: CGFloat = 0.4
    @State private var opacity: Double = 0

    public init(isTriggered: Bool, color: Color = .primaryButton) {
        self.isTriggered = isTriggered
        self.color = color
    }

    public var body: some View {
        Circle()
            .strokeBorder(color, lineWidth: 2)
            .frame(width: 60, height: 60)
            .scaleEffect(scale)
            .opacity(opacity)
            .allowsHitTesting(false)
            .onChange(of: isTriggered) { _, newVal in
                if newVal { pop() }
            }
    }

    private func pop() {
        scale = 0.4
        opacity = 0.9
        withAnimation(.easeOut(duration: 0.6)) {
            scale = 1.8
            opacity = 0
        }
    }
}
