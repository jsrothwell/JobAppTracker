import SwiftUI

@main
struct JobAppTrackerApp: App {
    @StateObject private var jobStore = JobStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(jobStore)
        }
    }
}
