import SwiftUI

struct FeelingSelectionView2: View {
    let feeling: HugFeeling
    @EnvironmentObject var settings: UserSettings
    
    var body: some View {
        ZStack {
            NeoBackground()
                .allowsHitTesting(false)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    
                    // タイトルカード（サブタイトル削除済み）
                    VStack(spacing: 10) {
                        Text(NSLocalizedString("select_hug_part", comment: ""))
                            .font(.system(size: 19, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .minimumScaleFactor(0.85)
                    }
                    .padding(16)
                    .glassCard(0.14)
                    .padding(.top, 10)
                    
                    // 部位ボタン群（文字を大きく・センターに）
                    VStack(spacing: 12) {
                        ForEach(HugPart.allCases, id: \.self) { part in
                            NavigationLink {
                                HugFeelingView2(feeling: feeling, part: part)
                                    .environmentObject(settings)
                            } label: {
                                ZStack {
                                    // 背景カード
                                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                                        .fill(.ultraThinMaterial.opacity(0.12))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 26, style: .continuous)
                                                .stroke(partColor(part).opacity(0.28), lineWidth: 1)
                                        )
                                    
                                    // 中央テキスト（大きめ）
                                    Text(part.localizedName)
                                        .font(.system(size: 22, weight: .black, design: .rounded))
                                        .foregroundColor(.white)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.85)
                                        .padding(.horizontal, 16)
                                }
                                .frame(height: 62)
                            }
                            .buttonStyle(PressableButtonStyle(scale: 0.98, yOffset: 1))
                            .simultaneousGesture(TapGesture().onEnded {
                                let g = UIImpactFeedbackGenerator(style: .light)
                                g.prepare()
                                g.impactOccurred()
                            })
                        }
                    }
                    
             
                    NavigationLink {
                        SpecialSkinshipView()
                            .environmentObject(settings)
                    } label: {
                        SpecialSparkleButton(
                            title: NSLocalizedString("special_title", comment: "")
                        )
                        .frame(maxWidth: .infinity)
                        .minimumScaleFactor(0.5)
                    }

                    .buttonStyle(PressableButtonStyle(scale: 0.98, yOffset: 1))
                    .simultaneousGesture(TapGesture().onEnded {
                        let g = UIImpactFeedbackGenerator(style: .medium)
                        g.prepare()
                        g.impactOccurred()
                    })
                    .padding(.top, 6)
                    
                    Spacer(minLength: 14)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
                .frame(maxWidth: 560)
                .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle(NSLocalizedString("start_name_input", comment: "ドキドキ体験"))
        .navigationBarTitleDisplayMode(.inline)
        
        // ✅ ナビタイトルが黒く見える問題を潰す
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(Color.black.opacity(0.35), for: .navigationBar)
    }
    
    private func partColor(_ part: HugPart) -> Color {
        switch part {
        case .arm:   return feeling.color
        case .leg:   return feeling.color.opacity(0.92)
        case .chest: return feeling.color.opacity(0.88)
        case .waist: return feeling.color.opacity(0.84)
        case .hair:  return feeling.color.opacity(0.80)
        case .nose:  return feeling.color.opacity(0.76)
        case .lips:  return feeling.color.opacity(0.72)
        }
    }
}


#Preview("FeelingSelectionView2 - en") {
    NavigationStack {
        FeelingSelectionView2(feeling: .hotto)
            .environmentObject(UserSettings())
    }
    .environment(\.locale, Locale(identifier: "en"))
}



