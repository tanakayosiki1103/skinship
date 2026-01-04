import SwiftUI

struct RootView: View {
    @EnvironmentObject var settings: UserSettings
    @State private var showIntro = false
    
    var body: some View {
        content
            .onAppear {
                showIntro = !settings.introDontShowAgain
            }
    }
    
    private var content: AnyView {
        if showIntro {
            return AnyView(
                IntroView { dontShowAgain in
                    settings.introDontShowAgain = dontShowAgain
                    showIntro = false
                }
            )
        } else {
            return AnyView(
                NavigationStack {
                    if settings.hasName {
                        MainView()
                    } else {
                        NameInputView() // ←違うならここだけ実在するView名へ
                    }
                }
            )
        }
    }
}

#Preview {
    RootView()
        .environmentObject(UserSettings())
}
