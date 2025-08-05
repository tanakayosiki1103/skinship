import SwiftUI

struct MainView: View {
    @AppStorage("userName") private var savedName: String = ""
    @AppStorage("userGender") private var savedGender: String = ""
    
    @EnvironmentObject var settings: UserSettings
    
    @State private var isShowingFeelingSelection = false
    @State private var isShowingNameInput = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer(minLength: 50)
                
                Text("\(settings.name)とスキンシップする")
                    .font(.system(size: 28, weight: .bold))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                Spacer()
                
                Button {
                    isShowingFeelingSelection = true
                } label: {
                    Image(systemName: "arrow.right")
                        .foregroundColor(.white)
                        .font(.system(size: 40, weight: .bold))
                        .frame(width: 80, height: 80)
                        .background(Color.blue)
                        .clipShape(Circle())
                        .shadow(radius: 5)
                }
                
                Spacer()
                
                Button("相手を変更する") {
                    settings.name = ""
                    settings.gender = ""
//                    isShowingNameInput = true
                }
                .font(.title2)
                .buttonStyle(.bordered)
                .padding(.bottom, 50)
            }
            .navigationTitle("メイン画面")
            .navigationBarTitleDisplayMode(.inline)
            
            // navigationDestinationで遷移先を登録
            .navigationDestination(isPresented: $isShowingFeelingSelection) {
                FeelingSelectionView()
                    .environmentObject(settings)
            }
            .navigationDestination(isPresented: $isShowingNameInput) {
                NameInputView()
                    .environmentObject(settings)
            }
        }
    }
}

#Preview {
    MainView().environmentObject(UserSettings())
}
