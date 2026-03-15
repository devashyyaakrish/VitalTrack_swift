import SwiftUI

/// Base background screen layout for all Views.
/// Features a living, breathing dark gradient with three softly animating glow orbs
/// driven by a TimelineView for a premium, premium parallax feel.
public struct GradientBackground<Content: View>: View {
    let content: () -&gt; Content

    public init(@ViewBuilder content: @escaping () -&gt; Content) {
        self.content = content
    }

    public var body: some View {
        TimelineView(.animation) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            ZStack {
                // Screen spanning deep background
                LinearGradient.heroGradient
                    .ignoresSafeArea()

                // Orb 1 — primary indigo, top-right, slow drift
                Circle()
                    .fill(Color(hex: "4F46E5").opacity(0.45))
                    .frame(width: 340, height: 340)
                    .blur(radius: 90)
                    .offset(
                        x: 90 + CGFloat(sin(t * 0.4)) * 28,
                        y: -160 + CGFloat(cos(t * 0.3)) * 22
                    )
                    .ignoresSafeArea()

                // Orb 2 — cyan/teal, bottom-left, medium drift
                Circle()
                    .fill(Color(hex: "06B6D4").opacity(0.30))
                    .frame(width: 260, height: 260)
                    .blur(radius: 80)
                    .offset(
                        x: -100 + CGFloat(cos(t * 0.5)) * 30,
                        y: 260 + CGFloat(sin(t * 0.45)) * 25
                    )
                    .ignoresSafeArea()

                // Orb 3 — violet, center-right, subtle drift
                Circle()
                    .fill(Color(hex: "7C3AED").opacity(0.22))
                    .frame(width: 200, height: 200)
                    .blur(radius: 70)
                    .offset(
                        x: 60 + CGFloat(cos(t * 0.6)) * 20,
                        y: 80 + CGFloat(sin(t * 0.55)) * 18
                    )
                    .ignoresSafeArea()

                content()
            }
        }
    }
}

public extension View {
    /// Wraps the current view inside a `GradientBackground`
    func withGradientBackground() -> some View {
        GradientBackground {
            self
        }
    }
}
