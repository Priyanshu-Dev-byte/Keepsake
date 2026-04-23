import SwiftUI
import SwiftData

@main
struct KeepsakeApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
        .modelContainer(for: [TimeCapsule.self, Memory.self])
    }
}
