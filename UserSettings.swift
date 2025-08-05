import SwiftUI
import Combine
import AVFoundation

class UserSettings: ObservableObject {
    // 名前を保存・読み込み（UserDefaults連動）
    @AppStorage("userName") var name: String = ""
    // 性別を保存・読み込み
    @AppStorage("userGender") var gender: String = ""
    // 音声選択用の性別設定（スピーチ音声用）
    @AppStorage("selectedGender") var selectedGender: String = ""
    
    // スキンシップ回数を辞書で管理（HugFeelingのrawValueをキーに）
    @Published var hugCounts: [String: Int] = [:]
    @Published var isVoiceEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isVoiceEnabled, forKey: "isVoiceEnabled")
        }
    }
    
    init() {
        self.isVoiceEnabled = UserDefaults.standard.bool(forKey: "isVoiceEnabled")
        loadCounts()
    }

    
    // 名前が入力済みか判定
    var hasName: Bool {
        !name.isEmpty
    }
    private let synthesizer = AVSpeechSynthesizer()  // ← 追加（1つだけ持つ）
    // テキストを音声で読み上げる関数
    func speak(_ message: String) {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)  // ← 話してたら止める（任意）
        }
        
        let utterance = AVSpeechUtterance(string: message)
        let voices = AVSpeechSynthesisVoice.speechVoices().filter { $0.language == "ja-JP" }
        
        if selectedGender == "男性" {
            if let maleVoice = voices.first(where: { $0.name.contains("Otoya") || $0.gender == .male }) {
                utterance.voice = maleVoice
            }
        } else if selectedGender == "女性" {
            if let femaleVoice = voices.first(where: { $0.name.contains("Kyoko") || $0.gender == .female }) {
                utterance.voice = femaleVoice
            }
        }
        
        utterance.rate = 0.5
        synthesizer.speak(utterance)
    }
    
    // 指定した感情のスキンシップ回数を取得
    func count(for feeling: HugFeeling) -> Int {
        hugCounts[feeling.rawValue] ?? 0
    }
    
    // 指定した感情のスキンシップ回数を増やす
    func incrementCount(for feeling: HugFeeling) {
        hugCounts[feeling.rawValue, default: 0] += 1
        saveCounts()
    }
    
    // UserDefaultsに保存
    private func saveCounts() {
        if let encoded = try? JSONEncoder().encode(hugCounts) {
            UserDefaults.standard.set(encoded, forKey: "hugCounts")
        }
    }
    
    // UserDefaultsから読み込み
    private func loadCounts() {
        guard let data = UserDefaults.standard.data(forKey: "hugCounts"),
              let decoded = try? JSONDecoder().decode([String: Int].self, from: data) else {
            hugCounts = [:]
            return
        }
        hugCounts = decoded
    }
}
