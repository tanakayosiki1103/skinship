import SwiftUI

struct NameInputView: View {
    @EnvironmentObject var settings: UserSettings
    @AppStorage("userName") private var savedName: String = ""
    @AppStorage("userGender") private var savedGender: String = ""
    
    @State private var name: String = ""
    @State private var gender: String = "男性"
    @State private var isSaved: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                Text("相手の名前を入力してください。")
                    .font(.title2)
                    .padding()
                    .minimumScaleFactor(0.5)
                
                TextField("しょうへい", text: $name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .padding(.top, 8)
                
                Text("相手の性別を選択してください。")
                    .font(.title2)
                    .padding()
                    .minimumScaleFactor(0.5)
                
                Picker("性別", selection: $gender) {
                    Text("男性").tag("男性")
                    Text("女性").tag("女性")
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                Button("登録") {
                    settings.name = name
                    settings.gender = gender
                    isSaved = true  // ← これを追加しないと「はじめる」ボタンが出ない
                }
               

                .disabled(name.isEmpty)
                .buttonStyle(.borderedProminent)
                .tint(name.isEmpty ? .gray : .blue)
                .padding(.top, 30)
                
                if isSaved {
                    NavigationLink(destination: MainView().environmentObject(settings)) {
                        Text("はじめる")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                    .padding(.top, 20)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("入力画面")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                isSaved = false
                name = settings.name
                gender = settings.gender.isEmpty ? "男性" : settings.gender
            }
        }
    }
}

#Preview {
    NameInputView()
        .environmentObject(UserSettings())
}
