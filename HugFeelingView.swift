import SwiftUI
import AVFoundation

struct HugFeelingView: View {
    let feeling: HugFeeling
    @EnvironmentObject var settings: UserSettings
    
    @State private var player: AVAudioPlayer?
    @State private var synthesizer = AVSpeechSynthesizer()
    @State private var speechDelegate = SpeechDelegate()
    
    @State private var hugMessageWithName: String = ""
    @State private var showMessage: Bool = false
    @State private var displayedLine: String = ""
    
    @State private var starPositions: [UUID: CGPoint] = [:]
    @State private var starOpacities: [UUID: Double] = [:]
    @State private var heartPositions: [UUID: CGPoint] = [:]
    @State private var heartOpacities: [UUID: Double] = [:]
    
    // MARK: - ハグトリガー
    func triggerHug() {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        settings.incrementCount(for: feeling)
        
        // Unity Ads: 9回に1回
        if Int.random(in: 1...9) == 1 {
            UnityAdsManager.shared.load()
            UnityAdsManager.shared.show()
        }
        
        // hugMessageWithName
        let format = NSLocalizedString("hug_with_name", comment: "")
        hugMessageWithName = String(format: format, settings.name.isEmpty ? feeling.hugMessage : settings.name, feeling.hugMessage)
        
        // ライン取得 & タイプライター表示
        if let randomLine = feeling.lines.randomElement() {
            typeWriterEffect(text: randomLine.replacingOccurrences(of: "りん", with: settings.name))
            speak(text: randomLine)
        }
        
        playSound()
        spawnHeart()
        spawnStar()
    }
    
    // MARK: - タイプライター
    func typeWriterEffect(text: String) {
        displayedLine = ""
        showMessage = true
        for (i, c) in text.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.04 * Double(i)) {
                displayedLine.append(c)
            }
        }
    }
    
    // MARK: - 音
    func playSound() {
        guard let url = Bundle.main.url(forResource: "pi", withExtension: "mp3") else { return }
        do { player = try AVAudioPlayer(contentsOf: url); player?.play() }
        catch { print(error) }
    }
    
    func speak(text: String) {
        guard settings.isVoiceEnabled else { return }
        
        let utterance = AVSpeechUtterance(string: text)
        settings.configureUtterance(utterance)   // ← ここで性格別に設定
        synthesizer.delegate = speechDelegate
        synthesizer.speak(utterance)
    }

    
    // MARK: - ハート・星
    func spawnHeart() {
        let id = UUID()
        heartPositions[id] = CGPoint(x: CGFloat.random(in: 50...300), y: CGFloat.random(in: 100...400))
        heartOpacities[id] = 1.0
        withAnimation(.easeOut(duration: 1.5)) { heartOpacities[id] = 0.0 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            heartPositions.removeValue(forKey: id)
            heartOpacities.removeValue(forKey: id)
        }
    }
    
    func spawnStar() {
        let id = UUID()
        starPositions[id] = CGPoint(x: CGFloat.random(in: 30...330), y: CGFloat.random(in: 150...350))
        starOpacities[id] = 1.0
        withAnimation(.easeOut(duration: 1.0)) { starOpacities[id] = 0.0 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            starPositions.removeValue(forKey: id)
            starOpacities.removeValue(forKey: id)
        }
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [.pink.opacity(0.3), .white]),
                           startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
            
            // 星
            ForEach(Array(starPositions.keys), id: \.self) { id in
                if let pos = starPositions[id], let opacity = starOpacities[id] {
                    Text("⭐").font(.system(size: 32)).position(pos).opacity(opacity)
                }
            }
            
            // ハート
            ForEach(Array(heartPositions.keys), id: \.self) { id in
                if let pos = heartPositions[id], let opacity = heartOpacities[id] {
                    Text("❤️").font(.system(size: 40)).position(pos).opacity(opacity)
                }
            }
            
            VStack(spacing: 30) {
                Spacer()
                
                // 気分名
                Text(NSLocalizedString(feeling.rawValue, comment: ""))
                    .font(.title2)
                    .foregroundColor(.black)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                
                // ハグボタン
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
                
                // セリフ
                if showMessage {
                    VStack(spacing: 8) {
                        Text(hugMessageWithName)
                            .font(.title3)
                            .foregroundColor(.blue)
                            .multilineTextAlignment(.center)
                            .lineLimit(nil)
                            .minimumScaleFactor(0.5)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Text(displayedLine)
                            .font(.title3)
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                            .padding(.top, 5)
                            .lineLimit(nil)
                            .minimumScaleFactor(0.5)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal, 16)
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

// 音声デリゲート
class SpeechDelegate: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {}
struct HugFeelingView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            HugFeelingView(feeling: .hotto)
                .environmentObject(UserSettings())
                .previewDevice("iPhone SE (3rd generation)")
                .previewDisplayName("iPhone SE")
            
            HugFeelingView(feeling: .hotto)
                .environmentObject(UserSettings())
                .previewDevice("iPhone 14 Pro")
                .previewDisplayName("iPhone 14 Pro")
            
            HugFeelingView(feeling: .hotto)
                .environmentObject(UserSettings())
                .previewDevice("iPhone 15 Plus")
                .previewDisplayName("iPhone 15 Plus")
        }
    }
}
