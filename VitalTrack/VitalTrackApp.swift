import SwiftUI

@main
struct VitalTrackApp: App {
    // Root ViewModel injected into the environment for the whole app
    @State private var appViewModel  = AppViewModel()
    @State private var trackersVM    = TrackersViewModel()

    var body: some Scene {
        WindowGroup {
            AppView()
                .environment(appViewModel)
                .environment(trackersVM)
                .preferredColorScheme(.dark)
        }
    }
}
