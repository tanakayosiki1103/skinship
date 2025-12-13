import SwiftUI
import AVFoundation

struct NameInputView: View {
    @EnvironmentObject var settings: UserSettings
    @State private var name: String = ""
    @State private var gender: String = "male"
    @State private var isSaved: Bool = false
    private let synthesizer = AVSpeechSynthesizer()
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ScrollView {
                    VStack {
                        Spacer(minLength: geometry.size.height * 0.05) // 上余白
                        
                        VStack(spacing: 40) {
                            
                            // 入力タイトル
                            Text(LocalizedStringKey("enter_name"))
                                .font(.title2)
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .foregroundColor(.black)
                                .minimumScaleFactor(0.8)
                                .padding(.top, 20)   // ← ナビゲーションタイトルとの距離を確保
                                .padding(.bottom, 8)
                            
                            // 名前入力フィールド
                            TextField(LocalizedStringKey("enter_name1"), text: $name)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.horizontal)
                                .frame(maxWidth: 400)
                                .multilineTextAlignment(.center) // ← 入力フィールドも中央寄せ
                            
                            // 性別選択タイトル
                            Text(LocalizedStringKey("gender_selection"))
                                .font(.title2)
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .foregroundColor(.black)
                            
                                .minimumScaleFactor(0.8)
                                .padding(.top, 16)
                                .padding(.bottom, 8)
                            
                            // 性別選択ピッカー
                            Picker("Gender", selection: $gender) {
                                Text(LocalizedStringKey("male")).tag("male")
                                Text(LocalizedStringKey("female")).tag("female")
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .padding(.horizontal)
                            .frame(maxWidth: 400)
                            
                            // 登録ボタン
                            Button(LocalizedStringKey("register")) {
                                settings.addUser(name: name, gender: gender)
                                isSaved = true
                            }
                            .disabled(name.isEmpty)
                            .buttonStyle(.borderedProminent)
                            .tint(name.isEmpty ? .gray : .blue)
                            .frame(maxWidth: 400)
                            .padding(.top, 30)
                            
                            // スタートボタン（登録後表示）
                            if isSaved {
                                NavigationLink(destination: MainView().environmentObject(settings)) {
                                    Text(LocalizedStringKey("start"))
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(.green)
                                .frame(maxWidth: 400)
                                .padding(.top, 20)
                            }
                        }
                        .padding(.horizontal)
                        
                        Spacer(minLength: geometry.size.height * 0.05)
                    }
                    .frame(minHeight: geometry.size.height)
                }
            }
            .background(Color(red: 0.9, green: 0.85, blue: 1.0))
            .ignoresSafeArea()
            
            .navigationTitle(LocalizedStringKey("input_title"))
            .navigationBarTitleDisplayMode(.large)
            .safeAreaInset(edge: .top) { // ← タイトルと本文の距離を稼ぐ
                Color.clear.frame(height: 10)
            }
            .onAppear {
                isSaved = false
                name = settings.name
                gender = settings.selectedGender.isEmpty ? "male" : settings.selectedGender
            }
        }
    }
    
    // 性別に応じたサンプル音声
    private func speakSample(for gender: String) {
        let utterance = AVSpeechUtterance(string: "こんにちは、私は \(gender == "male" ? "男性" : "女性") の声です。")
        utterance.rate = 0.45
        
        if gender == "male" {
            if let otoya = AVSpeechSynthesisVoice(identifier: "com.apple.ttsbundle.Otoya-premium") {
                utterance.voice = otoya
            } else {
                utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
            }
        } else {
            if let kyoko = AVSpeechSynthesisVoice(identifier: "com.apple.ttsbundle.Kyoko-premium") {
                utterance.voice = kyoko
            } else {
                utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
            }
        }
        
        synthesizer.speak(utterance)
    }
}

#Preview {
    NameInputView()
        .environmentObject(UserSettings())
}
