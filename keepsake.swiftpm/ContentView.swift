import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            Tab("Capsules", systemImage: "capsule.fill") {
                NavigationStack {
                    HomeView()
                }
            }
            Tab("Constellation", systemImage: "sparkles") {
                NavigationStack {
                    ConstellationGalleryView()
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}
