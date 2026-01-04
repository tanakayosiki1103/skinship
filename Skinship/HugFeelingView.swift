import SwiftUI

struct HugFeelingView: View {
    let feeling: HugFeeling
    @EnvironmentObject var settings: UserSettings
    
    @State private var hugMessageWithName = ""
    @State private var displayedLine = ""
    @State private var showMessage = false
    @State private var glow = false
    
    @State private var bgTheme: NeoBackgroundTheme = .aqua
    
    // ボタン表示用（登録名 or デフォルト）
    var partnerName: String {
        settings.name.isEmpty
        ? NSLocalizedString("default_partner", comment: "あなた")
        : settings.name
    }
    
    func triggerHug() {
        settings.incrementCount(for: feeling)
        HugDataStore.shared.addHug()
        
        let name = partnerName
        hugMessageWithName = "\(name)\(feeling.hugMessage)"
        
        let key = feeling.lines.randomElement() ?? ""
        let line = NSLocalizedString(key, comment: "")
        
        displayedLine = ""
        showMessage = true
        
        if settings.isVoiceEnabled {
            settings.speak(line)
        }
        
        let interval = 0.035
        
        for (i, c) in line.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + interval * Double(i)) {
                displayedLine.append(c)
                
                // ✅ 最後の1文字が出た「直後」に広告判定（余韻0.4秒）
                if i == line.count - 1 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        UnityAdsManager.shared.showAdIfNeededAfterHug()

                    }
                }
            }
        }

        
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        withAnimation(.easeInOut(duration: 0.35)) { glow = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
            withAnimation(.easeInOut(duration: 0.55)) { glow = false }
        }
        
        // ✅ 押すたびランダム背景（同じ連続は回避）
        let themes = NeoBackgroundTheme.allCases
        var next = themes.randomElement() ?? .aqua
        if next == bgTheme, themes.count > 1 {
            next = themes.filter { $0 != bgTheme }.randomElement() ?? next
        }
        withAnimation(.easeInOut(duration: 0.8)) {
            bgTheme = next
        }
        
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        
       
    }
    
    var body: some View {
        ZStack {
            NeoBackground(theme: bgTheme)
                .allowsHitTesting(false)
            
            VStack(spacing: 18) {
             
//
                Text(feeling.title)
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 6)
                    .padding(.top, 20)
                
                Spacer(minLength: 20)
                Button {
                    triggerHug()
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 18, weight: .bold))
                        
                        Text(
                            String(
                                format: NSLocalizedString("skin_with", comment: ""),
                                partnerName
                            )
                        )
                        .font(.system(size: 18, weight: .black, design: .rounded))

                    }
                    .foregroundColor(.white)
                    .padding(.vertical, 14)
                    .frame(maxWidth: .infinity)
                    .glassCard(0.16)
                    .overlay(
                        RoundedRectangle(cornerRadius: NeoTheme.corner, style: .continuous)
                            .stroke(feeling.color.opacity(0.35), lineWidth: 1)
                    )
                    .shadow(
                        color: feeling.color.opacity(glow ? 0.45 : 0.18),
                        radius: glow ? 26 : 14,
                        x: 0,
                        y: 10
                    )
                }
                
                
                
                // メッセージ（枠を消したいなら padding だけにしてOK）
                if showMessage {
                    VStack(spacing: 10) {
                        Text(hugMessageWithName)
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundColor(.blue)
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 10)
                        
                        Text("「\(displayedLine)」")
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundColor(.white.opacity(0.95))
                            .multilineTextAlignment(.center)
                            .minimumScaleFactor(0.8)
                    }
                    .padding(.top, 12)
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
                }
                
                Spacer(minLength: 40)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 18)
            .frame(maxWidth: 560)
        }
        // ✅ navigation系 modifier は「bodyの戻り値(ZStack)」に付ける
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(Color.black.opacity(0.35), for: .navigationBar)
        .onAppear {
            // 最初もランダムにしたいなら
            bgTheme = NeoBackgroundTheme.allCases.randomElement() ?? .aqua
        }
    }
}



#Preview("HugFeelingView - ja") {
    NavigationStack {
        HugFeelingView(feeling: .hotto)
            .environmentObject(UserSettings())
    }
    .environment(\.locale, Locale(identifier: "ja"))
}
