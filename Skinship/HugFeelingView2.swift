import SwiftUI
import AVFoundation
import AudioToolbox

struct HugFeelingView2: View {
    let feeling: HugFeeling
    let part: HugPart
    
    @EnvironmentObject var settings: UserSettings
    
    // audio / speech
    @State private var player: AVAudioPlayer?
    
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
    @State private var bgTheme: NeoBackgroundTheme = .aqua
    @State private var glow = false
    
    private var partnerName: String {
        settings.name.isEmpty
        ? NSLocalizedString("default_partner", comment: "あなた")
        : settings.name
    }
    
    // MARK: - セリフ / アクション辞書
    let hugActions: [HugPart: String] = [
        .arm: NSLocalizedString("hug_action_arm", comment: ""),
        .leg: NSLocalizedString("hug_action_leg", comment: ""),
        .chest: NSLocalizedString("hug_action_chest", comment: ""),
        .waist: NSLocalizedString("hug_action_waist", comment: ""),
        .hair: NSLocalizedString("hug_action_hair", comment: ""),
        .nose: NSLocalizedString("hug_action_nose", comment: ""),
        .lips: NSLocalizedString("hug_action_lips", comment: "")
    ]
    
    private func hugPartKey(_ part: HugPart) -> String {
        switch part {
        case .arm: return "arm"
        case .leg: return "leg"
        case .chest: return "chest"
        case .waist: return "waist"
        case .hair: return "hair"
        case .nose: return "nose"
        case .lips: return "lips"
        }
    }
    
    // MARK: - ハグトリガー
    func triggerHug() {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        HugDataStore.shared.addHug()
        
        let partner = settings.name.isEmpty
        ? NSLocalizedString("default_partner", comment: "あなた")
        : settings.name
        
        let action = hugActions[part] ?? ""
        hugMessageWithName = String(
            format: NSLocalizedString("hug_action_with_name", comment: ""),
            partner,
            action
        )
        
        let speakerName = settings.name2.isEmpty
        ? NSLocalizedString("default_you", comment: "あなた")
        : settings.name2
        
        let line = localizedHugLine(for: part, name: speakerName)
        
        showMessage = true
        displayedLine = ""
        
        typeWriterEffect(text: line, interval: 0.05) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                UnityAdsManager.shared.showAdIfNeededAfterHug()
            }
        }
        
        if settings.isVoiceEnabled {
            settings.speak(line)
        }
        
        playSound()
        triggerAnimations(for: part)
        showGlow = true
        generateStars()
    }
    
    private func localizedHugLine(for part: HugPart, name: String) -> String {
        let partKey = hugPartKey(part)
        let key = "hug_line_\(partKey)_\(Int.random(in: 1...5))"
        let template = NSLocalizedString(key, comment: "")
        if template.contains("%@") {
            return String(format: template, name)
        } else {
            return template
        }
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
    
    // MARK: - タイプライター
    func typeWriterEffect(text: String, interval: Double = 0.05, onFinished: (() -> Void)? = nil) {
        displayedLine = ""
        for (i, c) in text.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + interval * Double(i)) {
                displayedLine.append(c)
                if i == text.count - 1 {
                    onFinished?()
                }
            }
        }
    }
    
    // MARK: - Sound
    func playSound() {
        guard let url = Bundle.main.url(forResource: "hug", withExtension: "mp3") else { return }
        player = try? AVAudioPlayer(contentsOf: url)
        player?.play()
    }
    
    // MARK: - Models
    struct Heart: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var scale: CGFloat = 1.0
        var opacity: Double = 1.0
        var size: CGFloat = 40
    }
    
    struct StarParticle: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var size: CGFloat
        var opacity: Double
        var speedX: CGFloat
        var speedY: CGFloat
        var color: Color
    }
    
    // MARK: - View
    var body: some View {
        ZStack {
            NeoBackground(theme: bgTheme)
                .allowsHitTesting(false)
            
            content
                .frame(maxWidth: 560)
                .padding(.horizontal, 16)
                .padding(.bottom, 18)
        }
        .onAppear {
            bgTheme = NeoBackgroundTheme.allCases.randomElement() ?? .aqua
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(Color.black.opacity(0.35), for: .navigationBar)
    }
    
    private var content: some View {
        VStack(spacing: 18) {
            Spacer(minLength: 20)
            
            Text(part.localizedName)
                .font(.system(size: 28, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .padding(.top, 8)
            
            Spacer(minLength: 20)
            
            Button {
                triggerHug()
                
                // ✅ 背景ランダム切替（同じ連続は避ける）
                let themes = NeoBackgroundTheme.allCases
                var next = themes.randomElement() ?? .aqua
                if next == bgTheme, themes.count > 1 {
                    next = themes.filter { $0 != bgTheme }.randomElement() ?? next
                }
                withAnimation(.easeInOut(duration: 0.8)) { bgTheme = next }
                
                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                withAnimation(.easeInOut(duration: 0.35)) { glow = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
                    withAnimation(.easeInOut(duration: 0.55)) { glow = false }
                }
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 18, weight: .bold))
                    
                    Text(String(format: NSLocalizedString("skin_with", comment: ""), partnerName))
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.6)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .foregroundColor(.white)
                .padding(.vertical, 14)
                .frame(maxWidth: .infinity)
                .glassCard(0.16)
                .overlay(
                    RoundedRectangle(cornerRadius: NeoTheme.corner, style: .continuous)
                        .stroke(Color.white.opacity(0.14), lineWidth: 1)
                )
                .shadow(
                    color: .white.opacity(glow ? 0.28 : 0.12),
                    radius: glow ? 26 : 14,
                    x: 0,
                    y: 10
                )
            }
            .buttonStyle(PressableButtonStyle(scale: 0.98, yOffset: 1))
            
            if showMessage {
                VStack(spacing: 18) {
                    // ✅ SE「…」対策（本命）
                    Text(hugMessageWithName)
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundColor(.blue)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                        .minimumScaleFactor(0.55)
                        .padding(.horizontal, 16)
                    
                    Text("「\(displayedLine)」")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundColor(.white.opacity(0.95))
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        .minimumScaleFactor(0.85)
                }
                .padding(.top, 12)
                .transition(.opacity.combined(with: .scale(scale: 0.98)))
            }
            
            Spacer(minLength: 16)
            
            // 演出レイヤー（タップ奪わない）
            ZStack {
                if showGlow {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(feeling.color.opacity(0.10))
                        .blur(radius: 18)
                        .transition(.opacity)
                }
                
                ForEach(hearts) { h in
                    Image(systemName: "heart.fill")
                        .font(.system(size: h.size))
                        .foregroundColor(.pink.opacity(h.opacity))
                        .scaleEffect(h.scale)
                        .position(x: h.x, y: h.y)
                }
                
                ForEach(stars) { s in
                    Image(systemName: "sparkle")
                        .font(.system(size: s.size))
                        .foregroundColor(s.color.opacity(s.opacity))
                        .position(x: s.x, y: s.y)
                }
            }
            .allowsHitTesting(false)
            .frame(maxWidth: .infinity, maxHeight: 260)
            
            Spacer(minLength: 24)
        }
    }
}

// MARK: - Preview
struct HugFeelingView2_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            HugFeelingView2(feeling: .hotto, part: .arm)
                .environmentObject(UserSettings())
        }
        .environment(\.locale, Locale(identifier: "ja"))
    }
}
