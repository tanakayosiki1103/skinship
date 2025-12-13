import SwiftUI

@main
struct SkinshipApp: App {
    @StateObject private var settings = UserSettings()
    
    // ✅ ここで Unity Ads 初期化
    init() {
        UnityAdsManager.shared.initialize()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(settings)
        }
    }
}
