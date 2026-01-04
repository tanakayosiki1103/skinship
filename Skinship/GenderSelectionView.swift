import SwiftUI

enum PartnerGender: String, CaseIterable, Identifiable {
    case male
    case female
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .male: return NSLocalizedString("male", comment: "")
        case .female: return NSLocalizedString("female", comment: "")
        }
    }
    
    var icon: String {
        switch self {
        case .male: return "person.fill"
        case .female: return "person.fill"
        }
    }
    
    var tint: Color {
        switch self {
        case .male: return .cyan
        case .female: return .pink
        }
    }
}

struct GenderSelectionView: View {
    @EnvironmentObject var settings: UserSettings
    
    // 次へ進むための引き継ぎ
    let partnerName: String
    
    @State private var selected: PartnerGender? = nil
    @State private var isNextActive = false
    
    var body: some View {
        ZStack {
            NeoBackground()
                .allowsHitTesting(false)
            
            VStack(spacing: 18) {
                
                // タイトルカード
                VStack(spacing: 10) {
                    Text(NSLocalizedString("gender_selection", comment: ""))
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.85)
                    
                    Text("「\(partnerName)」")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.70))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .padding(16)
                .glassCard(0.14)
                .padding(.top, 12)
                
                // 選択カード
                VStack(spacing: 12) {
                    ForEach(PartnerGender.allCases) { g in
                        Button {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            selected = g
                        } label: {
                            HStack(spacing: 12) {
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(g.tint.opacity(0.18))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .stroke(g.tint.opacity(0.35), lineWidth: 1)
                                    )
                                    .frame(width: 46, height: 46)
                                    .overlay(
                                        Image(systemName: g.icon)
                                            .font(.system(size: 18, weight: .bold))
                                            .foregroundColor(.white.opacity(0.95))
                                    )
                                
                                Text(g.title)
                                    .font(.system(size: 20, weight: .black, design: .rounded))
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Image(systemName: selected == g ? "checkmark.circle.fill" : "circle")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white.opacity(selected == g ? 0.95 : 0.35))
                            }
                            .padding(.vertical, 14)
                            .padding(.horizontal, 14)
                            .glassCard(selected == g ? 0.18 : 0.10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 26, style: .continuous)
                                    .stroke(g.tint.opacity(selected == g ? 0.30 : 0.18), lineWidth: 1)
                            )
                        }
                        .buttonStyle(PressableButtonStyle(scale: 0.98, yOffset: 1))
                    }
                }
                
                Spacer()
                
                // 次へ
                Button {
                    goNext()
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 18, weight: .bold))
                        Text(NSLocalizedString("register", comment: "登録"))
                            .font(.system(size: 18, weight: .black, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .padding(.vertical, 14)
                    .frame(maxWidth: .infinity)
                    .glassCard(selected == nil ? 0.06 : 0.16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .stroke(Color.white.opacity(selected == nil ? 0.12 : 0.22), lineWidth: 1)
                    )
                }
                .buttonStyle(PressableButtonStyle(scale: 0.98, yOffset: 1))
                .disabled(selected == nil)
                .opacity(selected == nil ? 0.65 : 1.0)
                .padding(.bottom, 16)
            }
            .padding(.horizontal, 16)
            .frame(maxWidth: 560)
        }
        .navigationTitle(NSLocalizedString("input_title", comment: "入力画面"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(Color.black.opacity(0.35), for: .navigationBar)
        
        .navigationDestination(isPresented: $isNextActive) {
            MainView()
                .environmentObject(settings)
        }
    }
    
    private func goNext() {
        guard let g = selected else { return }
        
        // ✅ ここで確定
        settings.name = partnerName
        settings.partnerGender = g.rawValue
        settings.hasName = true
        
        // ✅ ここが追加：リストに即反映（重複防止）
        if !settings.userList.contains(partnerName) {
            settings.userList.append(partnerName)
        }
        
        // ✅ 性別マップも更新（入れてる場合）
        settings.userGenderMap[partnerName] = g.rawValue
        
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        isNextActive = true
    }

}

#Preview("GenderSelectionView - ja") {
    NavigationStack {
        GenderSelectionView(partnerName: "しょうへい")
            .environmentObject(UserSettings())
    }
    .environment(\.locale, Locale(identifier: "ja"))
}
