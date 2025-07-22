import SwiftUI

enum NavigationTarget: Hashable {
    case feeling
}

struct ContentView: View {
    @AppStorage("savedName") private var savedName: String = ""
    @AppStorage("savedGender") private var savedGender: String = ""
    
    @State private var name: String = ""
    @State private var gender: String = ""
    @State private var isNameSaved: Bool = false
    
    @EnvironmentObject var settings: UserSettings
    @State private var path = NavigationPath() // これが遷移の状態を管理
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                if isNameSaved || !savedName.isEmpty {
                    // 上部に「〇〇とスキンシップする」
                    Text("\(savedName)とスキンシップする")
                        .font(.title)
                        .padding(.top, 50)
                    
                    Spacer()
                    
                    // 中央に矢印ボタン
                    Button(action: {
                        path.append(NavigationTarget.feeling)
                    }) {
                        Image(systemName: "arrow.right.circle.fill")
                            .resizable()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    // 下部に「相手を変更する」ボタン
                    Button("相手を変更する") {
                        savedName = ""
                        savedGender = ""
                        name = ""
                        gender = ""
                        isNameSaved = false
                    }
                    .padding(.bottom, 50)
                    
                } else {
                    // 名前と性別の入力フォーム
                    Text("相手の名前を入力してください")
                        .font(.headline)
                        .padding()
                        .minimumScaleFactor(0.7)
                    TextField("しょうへい", text: $name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    
                    Text("相手の性別を選んでください")
                        .font(.headline)
                        .padding(.top)
                        .minimumScaleFactor(0.5)
                    Picker("性別", selection: $gender) {
                        Text("男性").tag("男性")
                        Text("女性").tag("女性")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    
                    Button("はじめる") {
                        if !name.isEmpty && !gender.isEmpty {
                            savedName = name
                            savedGender = gender
                            settings.name = name
                            settings.gender = gender
                            settings.selectedGender = gender  // ← 追加これが必要
                            isNameSaved = true
                        }
                    }

                    .padding()
                    .disabled(name.isEmpty || gender.isEmpty)
                }
            }
            .onAppear {
                isNameSaved = !savedName.isEmpty
            }
            .animation(.easeInOut, value: isNameSaved)
            .padding()
            .navigationTitle("Top")
            // ← 遷移先をここで指定
            .navigationDestination(for: NavigationTarget.self) { target in
                switch target {
                case .feeling:
                    FeelingSelectionView(settings: settings)
                }
            }

        }
    }
}

#Preview {
    ContentView()
        .environmentObject(UserSettings())
}
