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
            return "そっと頭に手を添えたよ"
        case .kokoro:
            return "あなたの腕を、やさしく包んだよ"
        case .tottonoeru:
            return "一緒にすぅーっと深呼吸しよう"
        case .fuwa:
            return "ふわっと肩に触れたよ"
        case .yasumi:
            return "となりで静かに手をにぎってるよ"
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
    @EnvironmentObject var settings: UserSettings
    
    @State private var player: AVAudioPlayer?
    @State private var synthesizer = AVSpeechSynthesizer()
    @State private var showMessage = false
    @State private var displayedLine = ""
    
    @State private var showHeart = false
    @State private var heartScale: CGFloat = 0.5
    @State private var heartOpacity: Double = 0.0
    
    var hugMessageWithName: String {
        if settings.name.isEmpty {
            return feeling.hugMessage
        } else {
            return "\(settings.name)と" + feeling.hugMessage
        }
    }
    
    func triggerHug() {
        print("triggerHug called for feeling: \(feeling.rawValue)")
        
        if let style = feeling.vibrationStyle {
            let generator = UIImpactFeedbackGenerator(style: style)
            generator.impactOccurred()
        } else {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        }
        
        HugDataStore.shared.addHug()
        print("HugDataStore.shared.addHug() called")
        
        if let randomLine = feeling.lines.randomElement() {
            displayedLine = randomLine
            withAnimation {
                showMessage = true
            }
            
            if settings.isVoiceEnabled {  // ← この行を追加
                let utterance = AVSpeechUtterance(string: randomLine)
                let gender = settings.gender
                let voices = AVSpeechSynthesisVoice.speechVoices().filter { $0.language == "ja-JP" }
                
                if gender == "男性" {
                    utterance.voice = voices.first(where: { $0.name.contains("Otoya") }) ?? AVSpeechSynthesisVoice(language: "ja-JP")
                } else if gender == "女性" {
                    utterance.voice = voices.first(where: { $0.name.contains("Kyoko") }) ?? AVSpeechSynthesisVoice(language: "ja-JP")
                } else {
                    utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
                }
                
                utterance.rate = 0.5
                synthesizer.speak(utterance)
            }
        }

        
        // ハート表示アニメーション
        showHeart = true
        heartScale = 1.2
        heartOpacity = 1.0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation {
                heartOpacity = 0.0
                heartScale = 0.5
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                showHeart = false
            }
        }
        
        // メッセージ非表示は3秒後
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation {
                showMessage = false
            }
        }
    }
    
    func playSound() {
        guard let url = Bundle.main.url(forResource: "hug", withExtension: "mp3") else {
            print("Sound file not found.")
            return
        }
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
            player?.play()
        } catch {
            print("Error playing sound: \(error.localizedDescription)")
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                feeling.backgroundColor.ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Spacer()
                    
                    Text(feeling.rawValue)
                        .font(.largeTitle)
                        .multilineTextAlignment(.center)
                    
                    Button(action: {
                        triggerHug()
                        playSound()
                    }) {
                        Text("スキンシップする")
                            .font(.title2)
                            .padding()
                            .frame(maxWidth: 220)
                            .background(Color.green)
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
                        .minimumScaleFactor(0.5)
                        .animation(.easeInOut, value: showMessage)
                    }
                    
                    Spacer()
                }
                .padding()
                
                if showHeart {
                    Image(systemName: "heart.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.pink)
                        .scaleEffect(heartScale)
                        .opacity(heartOpacity)
                        .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 5)
                        .animation(.easeOut(duration: 1.0), value: heartScale)
                        .animation(.easeOut(duration: 1.0), value: heartOpacity)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // 広告は画面の一番下
            AdBannerView()
                .frame(width: 320, height: 50)
                .background(Color.clear)
                .padding(.bottom, 10)
        }
    }
}



// MARK: - プレビュー
#Preview {
    HugFeelingView(feeling: .hotto)
        .environmentObject(UserSettings())
}

