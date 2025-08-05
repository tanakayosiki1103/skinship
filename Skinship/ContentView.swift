import SwiftUI

struct ContentView: View {
    @EnvironmentObject var settings: UserSettings
    
    var body: some View {
        if settings.hasName {
            MainView()
        } else {
            NameInputView()
        }
    }
}


