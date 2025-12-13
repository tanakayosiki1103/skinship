import SwiftUI

struct NameInputView2: View {
    @EnvironmentObject var settings: UserSettings
    @State private var name: String = ""
    @State private var isNextActive = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                Text(NSLocalizedString("enter_name3", comment: ""))
                    .font(.title2)
                    .minimumScaleFactor(0.8)
                    .lineLimit(nil)                         // 行数制限なし
                    .fixedSize(horizontal: false, vertical: true)  // 横幅に合わせて折り返す
                    .padding(.top, 50)

                
                TextField(NSLocalizedString("enter_name1", comment: "Placeholder"), text: $name)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .padding(.horizontal, 30)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                
                Spacer()
                
                Button(NSLocalizedString("start", comment: "")) {
                    if !name.isEmpty {
                        settings.name2 = name   // ← name ではなく name2 に保存
                        isNextActive = true
                    }
                }

                .font(.title2)
                .frame(maxWidth: .infinity)
                .padding()
                .background(name.isEmpty ? Color.gray : Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal, 30)
                .disabled(name.isEmpty)
                
                Spacer()
                
                // 遷移先を FeelingSelectionView2 に変更
                    .navigationDestination(isPresented: $isNextActive) {
                        FeelingSelectionView2()
                            .environmentObject(settings)
                    }
            }
            .navigationTitle(NSLocalizedString("input_title", comment: ""))
        }
    }
}
struct NameInputView2_Previews: PreviewProvider {
    static var previews: some View {
        let settings = UserSettings() // ここで明示的に作る
        NameInputView2()
            .environmentObject(settings)
    }
}







