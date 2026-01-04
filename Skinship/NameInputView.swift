import SwiftUI

struct NameInputView: View {
    
    @EnvironmentObject var settings: UserSettings
    @State private var partnerName: String = ""
    @State private var isNextActive = false
    @FocusState private var isFocused: Bool
    
    var body: some View {
        ZStack {
            NeoBackground()
                .allowsHitTesting(false)
            
            VStack(spacing: 18) {
                
                // ✅ 上の余白：上に詰まりすぎ防止（画面高に応じて伸縮）
                Spacer(minLength: 14)
                
                // タイトルカード
                VStack(spacing: 10) {
                    Text(NSLocalizedString("enter_name", comment: ""))
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.85)
                    
                    Text(NSLocalizedString("skin_with", comment: "%@ とスキンシップする").replacingOccurrences(of: "%@", with: "◯◯"))
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.70))
                }
                .padding(16)
                .glassCard(0.14)
                // ✅ ここはSpacerに任せる（上のpaddingは削る/弱める）
                .padding(.top, 0)
                
                // 入力カード（ラベルなし）
                VStack(spacing: 10) {
                    HStack(spacing: 10) {
                        Image(systemName: "person.crop.circle.fill")
                            .foregroundColor(.white.opacity(0.88))
                        
                        TextField(NSLocalizedString("enter_name1", comment: ""), text: $partnerName)
                            .foregroundColor(.white)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                            .submitLabel(.done)
                            .focused($isFocused)
                            .onSubmit { goNextIfPossible() }
                        
                        if !partnerName.isEmpty {
                            Button {
                                partnerName = ""
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.white.opacity(0.75))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 14)
                    .padding(.horizontal, 14)
                    .background(Color.white.opacity(0.10))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.white.opacity(0.20), lineWidth: 1)
                    )
                    
                   
                }
                .padding(16)
                .glassCard(0.12)
                
                // ✅ 下に落ちすぎ防止：効きすぎる Spacer を弱める
                Spacer(minLength: 18)
                
                // 次へボタン
                Button {
                    goNextIfPossible()
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
                    .glassCard(isValid ? 0.16 : 0.06)
                    .overlay(
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .stroke(Color.white.opacity(isValid ? 0.22 : 0.12), lineWidth: 1)
                    )
                }
                .buttonStyle(PressableButtonStyle(scale: 0.98, yOffset: 1))
                .disabled(!isValid)
                .opacity(isValid ? 1.0 : 0.65)
                .padding(.bottom, 14)
            }

            .padding(.horizontal, 16)
            .frame(maxWidth: 560)
        }
        .navigationTitle(NSLocalizedString("input_title", comment: "入力画面"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(Color.black.opacity(0.35), for: .navigationBar)
        .onAppear {
            // 既存があれば初期表示
            if !settings.name.isEmpty {
                partnerName = settings.name
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                isFocused = true
            }
        }
        
        // ✅ 遷移先：あなたのアプリ構成に合わせてどっちか選ぶ
        .navigationDestination(isPresented: $isNextActive) {
            GenderSelectionView(partnerName: partnerName.trimmingCharacters(in: .whitespacesAndNewlines))
                .environmentObject(settings)
        }
        
    }
    
    private var isValid: Bool {
        !partnerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private func goNextIfPossible() {
        let trimmed = partnerName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        isNextActive = true
    }
}


#Preview("NameInputView - ja") {
    NavigationStack {
        NameInputView()
            .environmentObject(UserSettings())
    }
    .environment(\.locale, Locale(identifier: "ja"))
}
