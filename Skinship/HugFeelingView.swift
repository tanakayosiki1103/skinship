import SwiftUI
import AVFoundation

// MARK: - 癒し気分（感情）定義
enum HugFeeling: String, CaseIterable, Identifiable, Hashable {
    
    case hotto = "ほっとしたい"
    case kokoro = "落ちつきたい"
    case tottonoeru = "ととのえたい"
    case fuwa = "ふわっとしたい"
    case yasumi = "やすみたい"
    case samisii = "さみしい"
    
    var id: String { self.rawValue }
    
    var hugMessage: String {
        switch self {
        case .hotto:
            return "そっと背中に手を添えたよ"
        case .kokoro:
            return "あなたの気持ちを、ぎゅっと包んだよ"
        case .tottonoeru:
            return "一緒にすぅーっと深呼吸しよう"
        case .fuwa:
            return "ふわっと肩に触れたよ"
        case .yasumi:
            return "となりで静かに寄り添ってるよ"
        case .samisii:
            return "ギュってハグしたよ"
        }
    }
    
    var lines: [String] {
        switch self {
        case .hotto:
            return ["なんにもしなくていいよ", "ここにいていいんだよ", "ゆっくりしてね"]
        case .kokoro:
            return ["あなたの気持ち、ちゃんと伝わってるよ", "そっと包み込むよ", "そのままのあなたで大丈夫"]
        case .tottonoeru:
            return ["いったん深呼吸しよう", "心を整える時間、大切だよ", "焦らなくていいよ"]
        case .fuwa:
            return ["ふわっと軽くなるね", "なにも考えず、ぼーっとしよ", "気持ちが空に浮かぶみたい"]
        case .yasumi:
            return ["ここで少し、ひとやすみしよう", "力を抜いて、ほっと一息", "おつかれさま、ちゃんと休もう"]
        case .samisii:
            return ["心がぽかぽかになる時間を過ごそう", "ひとりじゃないよ、ここにいるよ", "言わなくても、ちゃんと伝わってるよ"]
        }
    }
    
    var vibrationStyle: UIImpactFeedbackGenerator.FeedbackStyle? {
        switch self {
        case .kokoro: return .medium
        case .tottonoeru: return .light
        default: return nil
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .hotto: return Color.green.opacity(0.15)
        case .kokoro: return Color.pink.opacity(0.15)
        case .tottonoeru: return Color.blue.opacity(0.15)
        case .fuwa: return Color.purple.opacity(0.15)
        case .yasumi: return Color.gray.opacity(0.15)
        case .samisii: return Color.gray.opacity(0.15)
        }
    }
}

// MARK: - メインビュー
struct HugFeelingView: View {
    let feeling: HugFeeling
    @ObservedObject var settings: UserSettings
    
    @State private var showMessage = false
    @State private var displayedLine = ""
    
    var hugMessageWithName: String {
        if settings.name.isEmpty {
            return feeling.hugMessage
        } else {
            return "\(settings.name)と" + feeling.hugMessage
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                feeling.backgroundColor.ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Spacer()  // 上の空きスペース
                    
                    // テキストとボタンは中央寄り
                    Text(feeling.rawValue)
                        .font(.largeTitle)
                        .multilineTextAlignment(.center)
                    
                    Button(action: {
                        triggerHug(for: feeling)
                    }) {
                        Text("スキンシップする")
                            .font(.title2)
                            .padding()
                            .frame(maxWidth: 220)
                            .background(Color.pink)
                            .foregroundColor(.white)
                            .cornerRadius(25)
                    }
                    
                    if showMessage {
                        VStack(spacing: 8) {
                            Text(hugMessageWithName)
                                .font(.title3)
                                .foregroundColor(.blue)
                            Text(displayedLine)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .multilineTextAlignment(.center)
                        .padding(.top, 10)
                        .transition(.opacity)
                    }
                    
                    Spacer()  // 下の空きスペース（調整用）
                }
                .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // 広告は画面の一番下
            AdBannerView()
                .frame(width: 320, height: 50)
                .background(Color.clear)
                .padding(.bottom, 10)
        }
        .animation(.easeInOut, value: showMessage)
    }



    
    func triggerHug(for feeling: HugFeeling) {
        // バイブレーション
        if let style = feeling.vibrationStyle {
            let generator = UIImpactFeedbackGenerator(style: style)
            generator.impactOccurred()
        } else {
            // デフォルトの振動
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        }
        
        // ランダムなセリフを取得して音声再生
        if let randomLine = feeling.lines.randomElement() {
            displayedLine = randomLine
            
            let utterance = AVSpeechUtterance(string: randomLine)
            
            // 性別で声を変える
            let gender = settings.gender
            let voices = AVSpeechSynthesisVoice.speechVoices().filter { $0.language == "ja-JP" }
            
            if gender == "男性" {
                if let maleVoice = voices.first(where: { $0.name.contains("Otoya") }) {
                    utterance.voice = maleVoice
                }
            } else if gender == "女性" {
                if let femaleVoice = voices.first(where: { $0.name.contains("Kyoko") }) {
                    utterance.voice = femaleVoice
                }
            } else {
                utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
            }
            
            utterance.rate = 0.5
            
            let synthesizer = AVSpeechSynthesizer()
            synthesizer.speak(utterance)
        }
        
        withAnimation {
            showMessage = true
        }
        
        // メッセージ表示を3秒で消す
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation {
                showMessage = false
            }
        }
    }
}

// MARK: - プレビュー
#Preview {
    HugFeelingView(feeling: .hotto, settings: UserSettings())
}
