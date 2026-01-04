import SwiftUI

struct FeelingSelectionView: View {
    @EnvironmentObject var settings: UserSettings
    @State private var showGraph = false
    
    private let feelingKeys = ["hotto","calm","balanced","soft","rest","lonely"]
    
    private func feeling(from key: String) -> HugFeeling? {
        HugFeeling.allCases.first { $0.key == key }
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // ✅ 背景（タップ奪わない）
                NeoBackground()
                    .allowsHitTesting(false)
                
                VStack(spacing: 14) {
                    
                    // 上：リスト
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 10) {
                            ForEach(feelingKeys, id: \.self) { key in
                                if let feeling = feeling(from: key) {
                                    NavigationLink {
                                        HugFeelingView(feeling: feeling)
                                            .environmentObject(settings)
                                    } label: {
                                        HStack(spacing: 12) {
                                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                                .fill(feeling.color.opacity(0.90))
                                                .frame(width: 8, height: 28)
                                                .shadow(color: feeling.color.opacity(0.25), radius: 10, x: 0, y: 0)
                                            
                                            Text(feeling.title)
                                                .font(.system(size: 18, weight: .black, design: .rounded))
                                                .foregroundColor(.white)
                                                .lineLimit(1)
                                                .minimumScaleFactor(0.85)
                                            
                                            Spacer()
                                            
                                            Image(systemName: "chevron.right")
                                                .font(.system(size: 14, weight: .black))
                                                .foregroundColor(.white.opacity(0.80))
                                        }
                                        .padding(.vertical, 14)
                                        .padding(.horizontal, 14)
                                        .glassCard(0.12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 26, style: .continuous)
                                                .stroke(feeling.color.opacity(0.18), lineWidth: 1)
                                        )
                                    }
                                    .buttonStyle(PressableButtonStyle(scale: 0.98, yOffset: 1))
                                }
                            }
                        }
                        .padding(.top, 10)
                        .padding(.horizontal, 16)
                        .frame(minHeight: geo.size.height * 0.56)
                    }
                    
                    // 下：ボタン群
                    VStack(spacing: 12) {
                        HStack(spacing: 12) {
                            NavigationLink {
                                SettingsView()
                                    .environmentObject(settings)
                            } label: {
                                actionCard(
                                    title: NSLocalizedString("voice_settings", comment: ""),
                                    icon: "speaker.wave.2.fill",
                                    tint: .cyan
                                )
                            }
                            .buttonStyle(.plain)
                            
                            Button {
                                showGraph = true
                            } label: {
                                actionCard(
                                    title: NSLocalizedString("trend", comment: ""),
                                    icon: "chart.bar.fill",
                                    tint: .orange
                                )
                            }
                            .buttonStyle(.plain)
                        }
                        
                        if let firstFeeling = feeling(from: feelingKeys.first ?? "") {
                            NavigationLink {
                                NameInputView2(feeling: firstFeeling)
                                    .environmentObject(settings)
                            } label: {
                                actionWideCard(
                                    title: NSLocalizedString("start_name_input", comment: ""),
                                    icon: "heart.fill",
                                    tint: .pink
                                )
                            }
                            .buttonStyle(PressableButtonStyle(scale: 0.98, yOffset: 1))
                        }
                        
                        Button {
                            if let url = URL(string: "https://apps.apple.com/jp/app/%E3%83%9E%E3%83%83%E3%83%81%E3%83%B3%E3%82%B0-%E3%83%95%E3%82%A3%E3%83%BC%E3%83%AA%E3%83%B3%E3%82%B0/id6748877770") {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            actionWideCard(
                                title: NSLocalizedString("gift_friend", comment: ""),
                                icon: "gift.fill",
                                tint: .purple
                            )
                        }
                        .buttonStyle(PressableButtonStyle(scale: 0.98, yOffset: 1))
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
                }
                .frame(maxWidth: 560)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            
            // ✅ 画面サイズで切り抜いて左右はみ出しを止める
            .frame(width: geo.size.width, height: geo.size.height)
            .clipped()
        }
        .navigationTitle(NSLocalizedString("select_feeling", comment: ""))
        .navigationBarTitleDisplayMode(.inline)
        
        // ✅ ナビタイトルが黒く見えるの防止
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(Color.black.opacity(0.35), for: .navigationBar)
        
        .sheet(isPresented: $showGraph) {
            SimpleGraphView()
        }
    }
    
    // MARK: - Cards
    private func actionCard(title: String, icon: String, tint: Color) -> some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white.opacity(0.95))
                .padding(10)
                .background(tint.opacity(0.18))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(tint.opacity(0.35), lineWidth: 1)
                )
            
            Text(title)
                .font(.system(size: 13, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.85)
        }
        .frame(maxWidth: .infinity, minHeight: 110)
        .padding(14)
        .glassCard(0.12)
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(tint.opacity(0.20), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.22), radius: 16, x: 0, y: 10)
    }
    
    private func actionWideCard(title: String, icon: String, tint: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white.opacity(0.95))
                .padding(10)
                .background(tint.opacity(0.18))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(tint.opacity(0.35), lineWidth: 1)
                )
            
            Text(title)
                .font(.system(size: 15, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .black))
                .foregroundColor(.white.opacity(0.80))
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 14)
        .glassCard(0.12)
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(tint.opacity(0.20), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.22), radius: 16, x: 0, y: 10)
    }
}

#Preview("FeelingSelectionView - ja") {
    NavigationStack {
        FeelingSelectionView()
            .environmentObject(UserSettings())
    }
    .environment(\.locale, Locale(identifier: "ja"))
}
