import SwiftUI

@main
struct SkinshipApp: App {
    @StateObject private var settings = UserSettings()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(settings)
                .task {
                    UnityAdsManager.shared.initialize()
                }
        }
    }
}
