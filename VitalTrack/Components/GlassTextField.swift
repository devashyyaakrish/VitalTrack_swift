import SwiftUI

/// Upgraded GlassTextField with a glowing focus ring, animated icon color,
/// and clear button on non-secure fields.
public struct GlassTextField: View {
    let placeholder: String
    @Binding var text: String
    var icon: String?
    var isSecure: Bool
    var tint: Color

    @FocusState private var isFocused: Bool
    @State private var showPassword: Bool = false

    public init(
        placeholder: String,
        text: Binding<String>,
        icon: String? = nil,
        isSecure: Bool = false,
        tint: Color = .primaryButton
    ) {
        self.placeholder = placeholder
        self._text = text
        self.icon = icon
        self.isSecure = isSecure
        self.tint = tint
    }

    public var body: some View {
        HStack(spacing: 14) {
            // Leading icon
            if let iconName = icon {
                Image(systemName: iconName)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(isFocused ? tint : .textSecondary)
                    .frame(width: 24)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isFocused)
            }

            // Text Input
            Group {
                if isSecure && !showPassword {
                    SecureField(placeholder, text: $text)
                        .focused($isFocused)
                } else {
                    TextField(placeholder, text: $text)
                        .focused($isFocused)
                }
            }
            .font(Typography.bodyLarge)
            .foregroundColor(.textPrimary)

            // Trailing action buttons
            HStack(spacing: 8) {
                // Clear button (non-secure only)
                if !isSecure && !text.isEmpty {
                    Button {
                        text = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.textTertiary)
                            .font(.system(size: 16))
                    }
                    .transition(.scale.combined(with: .opacity))
                }

                // Toggle password visibility
                if isSecure {
                    Button {
                        showPassword.toggle()
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    } label: {
                        Image(systemName: showPassword ? "eye.slash" : "eye")
                            .foregroundColor(.textSecondary)
                            .font(.system(size: 16))
                    }
                }
            }
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: text.isEmpty)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 18)
        // Background glass layer
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.ultraThinMaterial)
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white.opacity(isFocused ? 0.08 : 0.05))
                // Top specular highlight
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.20), Color.clear],
                            startPoint: .top,
                            endPoint: UnitPoint(x: 0.5, y: 0.4)
                        )
                    )
            }
        )
        // Dynamic border
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(
                    isFocused
                        ? LinearGradient(colors: [tint, tint.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        : LinearGradient(colors: [Color.glassBorder, Color.glassBorder], startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: isFocused ? 1.5 : 1
                )
        )
        // Glow shadow on focus
        .shadow(
            color: isFocused ? tint.opacity(0.40) : .clear,
            radius: 12, x: 0, y: 4
        )
        .shadow(
            color: isFocused ? tint.opacity(0.15) : .clear,
            radius: 24, x: 0, y: 8
        )
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isFocused)
    }
}
