import SwiftUI
import SwiftData

@main
struct FoundationModelsDemoApp: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                ContentView()
                    .tabItem { Label("On-Device AI", systemImage: "sparkles") }
                SwiftDataExampleView()
                    .tabItem { Label("SwiftData", systemImage: "checklist") }
                iPadLayoutExampleView()
                    .tabItem { Label("iPad Layout", systemImage: "ipad") }
            }
        }
        .modelContainer(for: TodoItem.self)
    }
}
