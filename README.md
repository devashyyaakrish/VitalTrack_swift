# VitalTrack iOS (SwiftUI)

VitalTrack iOS is a premium, beautifully designed health and wellness tracking application built natively with SwiftUI. It serves as the iOS counterpart to the cross-platform VitalTrack project, demonstrating advanced usage of iOS 17 features, responsive fluid animations, and a bespoke "Liquid Glass" design system.

---

## ✨ Features & Capabilities

The application includes five fully functional main sections built around a clean MVVM architecture:

### 1. Dashboard
- **Personalized Greeting**: Dynamic time-of-day greetings and hero section.
- **Overall Health Score**: An aggregated metric ring analyzing daily wellness across all trackers.
- **Quick Actions**: One-tap logging for water, meals, and sleep with beautiful particle burst feedback.

### 2. Health Trackers
- **Liquid Glass Interface**: Multi-layered frosted glass cards utilizing `.ultraThinMaterial`, simulated specular light refraction, and animated shimmer sweeps.
- **Water & Steps**: Clean progress rings with trailing glow dots and haptic-enabled quick-add buttons.
- **Calories (Meals)**: Fully interactive meal logging with macro split chips and an emoji-based food picker sheet.
- **Sleep**: Integration with native iOS `DatePicker` for sleep schedule management, complete with qualitative sleep analysis.

### 3. Habit Builder
- **Daily Progress Bar**: Visual summary of completed routines vs remaining goals.
- **Streak Engine**: Tracks continuous habit chains with automated milestone celebrations (🏆) at 7-day intervals.
- **Celebration Effects**: Custom SwiftUI `Canvas` implementation emitting a vibrant particle burst when a habit is completed.

### 4. Interactive Analytics
- **Summary Statistics**: Computes daily averages, bests, and total values over the last 7 days.
- **Swift Charts Integration**: Utilizes Apple's native `Charts` framework to render dynamic Line, Area, and Bar marks with custom gradients.
- **Mini-Sparklines**: Quick-glance trend graphs for all tracked metrics embedded directly into the selection chips.

### 5. Settings & Profile
- **Account Management**: Simulated user profile card with health score badge and robust sign-out/delete flows.
- **Configurable Goals**: Centralized setting panel to adjust daily targets for water, steps, calories, and sleep.
- **Preferences & Notifications**: Toggles for theme (Dark/Light mode integration), units (Metric/Imperial), and granular reminder settings.

---

## 🏗 Architecture & Technical Highlights

This project was built from the ground up to showcase modern iOS development practices:

- **State Management**: Fully adopts the iOS 17 `@Observable` macro pattern for clean, reactive ViewModel bindings (`AppViewModel`, `TrackersViewModel`).
- **Dependencies**: 100% native. Zero third-party packages. Everything from the charts to the particle engine is built using first-party Apple frameworks (`SwiftUI`, `Charts`, `LocalAuthentication`).
- **Biometric Authentication**: Implements `LocalAuthentication` for seamless Face ID / Touch ID driven login flows.
- **Advanced Animations**: Extensive use of `matchedGeometryEffect` for sliding tab indicators, `symbolEffect(.bounce)` for dynamic iconography, and `TimelineView` for living, breathing background gradients.

---

## 🎨 The "Liquid Glass" Design System

The hallmark of VitalTrack's visual identity is its custom glassmorphism implementation. The `LiquidGlassModifier` utilizes:
1. Native `Material` blurs mixed with per-metric color tints.
2. A continuous, specular top-edge stroke simulating light hitting the glass edge.
3. Dual-layered shadows (a deep depth shadow paired with a vibrant, colored glow shadow).
4. An animated `LinearGradient` shimmer streak that sweeps across the component upon appearance.

---

## 🚀 Getting Started

### Prerequisites
- macOS 14.0 or later
- Xcode 15.0 or later
- iOS 17.0+ deployment target

### Running the App
1. Clone the repository:
   ```bash
   git clone https://github.com/devashyyaakrish/VitalTrack_swift.git
   ```
2. Open the project in Xcode:
   ```bash
   cd VitalTrack_swift/VitalTrack-iOS
   open VitalTrack-iOS.xcodeproj
   ```
3. Select an iOS 17+ Simulator (e.g., iPhone 15 Pro) and hit **Run (Cmd+R)**.

---

## 📝 License
This project is created for academic demonstration and portfolio purposes. All rights reserved.
