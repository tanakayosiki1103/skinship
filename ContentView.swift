import SwiftUI

struct ContentView: View {
    @EnvironmentObject var settings: UserSettings
    
    var body: some View {
        NavigationStack {
            if settings.hasName {  // ← Binding ではなく直接アクセス
                MainView()
                    .environmentObject(settings)
            } else {
                NameInputView()
                    .environmentObject(settings)
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(UserSettings())
}
