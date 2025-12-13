import SwiftUI
import AVFoundation

struct HugFeelingView2: View {
    var part: HugPart = .arm
    @EnvironmentObject var settings: UserSettings
    
    // audio / speech
    @State private var player: AVAudioPlayer?
//    @StateObject private var synthesizer = AVSpeechSynthesizer()

    @State private var synthesizer = AVSpeechSynthesizer()
    @StateObject private var speechDelegate = HugSpeechDelegate()
    
    // UI state
    @State private var hugMessageWithName: String = ""
    @State private var showMessage = false
    @State private var displayedLine = ""
    
    // animations
    @State private var showHeart = false
    @State private var isAnimating = false
    @State private var hearts: [Heart] = []
    @State private var showGlow = false
    @State private var stars: [StarParticle] = []
    
    // セリフ / アクション辞書
    let hugActions: [HugPart: String] = [
        .arm: NSLocalizedString("hug_action_arm", comment: ""),
        .leg: NSLocalizedString("hug_action_leg", comment: ""),
        .chest: NSLocalizedString("hug_action_chest", comment: ""),
        .waist: NSLocalizedString("hug_action_waist", comment: ""),
        .hair: NSLocalizedString("hug_action_hair", comment: ""),
        .nose: NSLocalizedString("hug_action_nose", comment: ""),
        .lips: NSLocalizedString("hug_action_lips", comment: "")
    ]
    
    let hugLines: [HugPart: [String]] = [
        .arm: [NSLocalizedString("hug_line_arm_1", comment: ""),
               NSLocalizedString("hug_line_arm_2", comment: ""),
               NSLocalizedString("hug_line_arm_3", comment: "")],
        .leg: [NSLocalizedString("hug_line_leg_1", comment: ""),
               NSLocalizedString("hug_line_leg_2", comment: ""),
               NSLocalizedString("hug_line_leg_3", comment: "")],
        .chest: [NSLocalizedString("hug_line_chest_1", comment: ""),
                 NSLocalizedString("hug_line_chest_2", comment: ""),
                 NSLocalizedString("hug_line_chest_3", comment: "")],
        .waist: [NSLocalizedString("hug_line_waist_1", comment: ""),
                 NSLocalizedString("hug_line_waist_2", comment: ""),
                 NSLocalizedString("hug_line_waist_3", comment: "")],
        .hair: [NSLocalizedString("hug_line_hair_1", comment: ""),
                NSLocalizedString("hug_line_hair_2", comment: ""),
                NSLocalizedString("hug_line_hair_3", comment: "")],
        .nose: [NSLocalizedString("hug_line_nose_1", comment: ""),
                NSLocalizedString("hug_line_nose_2", comment: ""),
                NSLocalizedString("hug_line_nose_3", comment: "")],
        .lips: [NSLocalizedString("hug_line_lips_1", comment: ""),
                NSLocalizedString("hug_line_lips_2", comment: ""),
                NSLocalizedString("hug_line_lips_3", comment: "")]
    ]
    
    // MARK: - Structs
    struct Heart: Identifiable { let id = UUID(); var x: CGFloat; var y: CGFloat; var scale: CGFloat = 1.0; var opacity: Double = 1.0; var size: CGFloat = 40; var delay: Double = 0 }
    struct StarParticle: Identifiable { let id = UUID(); var x: CGFloat; var y: CGFloat; var size: CGFloat; var opacity: Double; var speedX: CGFloat; var speedY: CGFloat; var color: Color }
    
    // MARK: - ハグトリガー
    func triggerHug() {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        
        // UnityAds: 9回に1回表示
        UnityAdsManager.shared.showAdIfNeeded()
        
        // 部位ごとの文言作成
        let action = hugActions[part] ?? ""
        let hugName = settings.name2.isEmpty ? "あなた" : settings.name2
        
        hugMessageWithName = "\(hugName)と\(action)"
        
        // セリフ取得とタイプライター
        if let lines = hugLines[part], let randomLine = lines.randomElement() {
            let lineWithName = randomLine.replacingOccurrences(of: "りん", with: hugName).replacingOccurrences(of: "Rin", with: hugName)
            typeWriterEffect(text: lineWithName)
            if settings.isVoiceEnabled {
                speak(text: lineWithName)
            }
        }
        
        playSound()
        triggerAnimations(for: part)
        showGlow = true
        generateStars()
        
        // セリフを消すタイミング
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            withAnimation {
                showGlow = false
                stars.removeAll()
                showMessage = false
            }
        }
    }
    
    // MARK: - タイプライター表示
    func typeWriterEffect(text: String, interval: Double = 0.05) {
        displayedLine = ""
        showMessage = true
        for (i, c) in text.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + interval * Double(i)) {
                displayedLine.append(c)
            }
        }
    }
    
    // MARK: - 音声・デリゲート
    func speak(text: String) {
        let utterance = AVSpeechUtterance(string: text)
        settings.configureUtterance(utterance)  
        utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
        synthesizer.delegate = speechDelegate
        synthesizer.speak(utterance)
    }
    
    // MARK: - 音
    func playSound() {
        guard let url = Bundle.main.url(forResource: "hug", withExtension: "mp3") else { return }
        do { player = try AVAudioPlayer(contentsOf: url); player?.play() } catch { print(error.localizedDescription) }
    }
    
    // MARK: - アニメーション
    func triggerAnimations(for part: HugPart) {
        switch part {
        case .arm, .chest, .hair, .lips:
            showHeart = true
            isAnimating = true
        case .leg, .waist, .nose:
            hearts.removeAll()
            let count = 8
            let screenWidth = UIScreen.main.bounds.width
            let screenHeight = UIScreen.main.bounds.height
            hearts = (0..<count).map { _ in
                Heart(
                    x: CGFloat.random(in: 50...(screenWidth - 50)),
                    y: CGFloat.random(in: 50...(screenHeight / 2)),
                    scale: CGFloat.random(in: 0.5...1.5),
                    opacity: 1.0
                )
            }
        }
    }
    
    func generateStars() {
        let screenWidth = UIScreen.main.bounds.width
        let centerX = screenWidth / 2
        let colors: [Color] = [.white, .yellow, .pink, .orange]
        stars = (0..<25).map { _ in
            StarParticle(
                x: centerX + CGFloat.random(in: -60...60),
                y: CGFloat.random(in: 100...300),
                size: CGFloat.random(in: 15...30),
                opacity: Double.random(in: 0.5...1),
                speedX: CGFloat.random(in: -0.5...0.5),
                speedY: CGFloat.random(in: -0.5...0.5),
                color: colors.randomElement()!
            )
        }
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if showHeart {
                Image(systemName: "heart.fill")
                    .resizable()
                    .frame(width: 150, height: 150)
                    .foregroundColor(.red)
                    .opacity(isAnimating ? 1 : 0)
                    .scaleEffect(isAnimating ? 1 : 0.5)
                    .animation(.easeOut(duration: 1.3).repeatForever(autoreverses: false), value: isAnimating)
            }
            
            ForEach(hearts) { heart in
                Image(systemName: "heart.fill")
                    .resizable()
                    .frame(width: heart.size, height: heart.size)
                    .foregroundColor(.pink)
                    .position(x: heart.x, y: heart.y)
                    .opacity(heart.opacity)
            }
            
            VStack(spacing: 30) {
                Spacer()
                Text(part.localizedName)
                    .font(.largeTitle)
                    .foregroundColor(.white)
                
                Button(action: {
                    triggerHug()
                }) {
                    Text(NSLocalizedString("hug_button_title", comment: "スキンシップボタンのラベル"))
                        .font(.title2)
                        .padding()
                        .frame(maxWidth: 220)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(25)
                }
                
                if showMessage {
                    Text(hugMessageWithName).font(.title3).foregroundColor(.blue)
                    Text(displayedLine)
                        .font(.title3)
                        .foregroundColor(.white)
                        .padding(.top, 10)
                        .multilineTextAlignment(.center)
                }
                
                Spacer()
            }
        }
        .onAppear {
            // ここで初期化だけ行う
            UnityAdsManager.shared.initialize() // ← 表示はされない
        }

    }
}

// MARK: - SpeechDelegate
final class HugSpeechDelegate: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    @Published var finishedCount = 0
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        finishedCount += 1
        // 音声終了で広告を出したい場合はこちらでも showAdIfNeeded を呼べる
    }
}

// MARK: - Preview
struct HugFeelingView2_Previews: PreviewProvider {
    static var previews: some View {
        HugFeelingView2(part: .arm)
            .environmentObject(UserSettings())
    }
}
