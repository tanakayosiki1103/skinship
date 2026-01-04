import SwiftUI

struct NameInputView2: View {
    
    let feeling: HugFeeling
    
    @EnvironmentObject var settings: UserSettings
    @State private var name: String = ""
    @State private var isNextActive = false
    @FocusState private var isFocused: Bool
    
    var body: some View {
        ZStack {
            NeoBackground()
                .allowsHitTesting(false)
            
            VStack(spacing: 18) {
                
                // タイトルカード
                VStack(spacing: 10) {
                    Text(NSLocalizedString("enter_name3", comment: ""))
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.85)
                    
                   
                }
                .padding(16)
                .glassCard(0.14)
                .padding(.top, 12)
                
                // 入力カード
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 10) {
                        Image(systemName: "person.fill")
                            .foregroundColor(.white.opacity(0.85))
                        
                        TextField(NSLocalizedString("enter_name2", comment: ""), text: $name)
                            .foregroundColor(.white)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                            .submitLabel(.done)
                            .focused($isFocused)
                            .onSubmit { goNextIfPossible() }
                        
                        if !name.isEmpty {
                            Button {
                                name = ""
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

                
                Spacer()
                
                // 開始ボタン（プロっぽく）
                Button {
                    goNextIfPossible()
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 18, weight: .bold))
                        Text(NSLocalizedString("start", comment: ""))
                            .font(.system(size: 18, weight: .black, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .padding(.vertical, 14)
                    .frame(maxWidth: .infinity)
                    .glassCard(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.06 : 0.16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .stroke(Color.white.opacity(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.12 : 0.22), lineWidth: 1)
                    )
                }
                .buttonStyle(PressableButtonStyle(scale: 0.98, yOffset: 1))
                .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .opacity(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.65 : 1.0)
                .padding(.bottom, 16)
            }
            .padding(.horizontal, 16)
            .frame(maxWidth: 560)
        }
        .navigationTitle(NSLocalizedString("input_title2", comment: ""))
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(Color.black.opacity(0.35), for: .navigationBar)
        
        .onAppear {
            // ちょい遅らせてフォーカス
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                isFocused = true
            }
        }
        
        .navigationDestination(isPresented: $isNextActive) {
            FeelingSelectionView2(feeling: feeling)
                .environmentObject(settings)
        }
    }
    
    private func goNextIfPossible() {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        settings.name2 = trimmed
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        isNextActive = true
    }
}

#Preview("NameInputView2 - ja") {
    NavigationStack {
        NameInputView2(feeling: .hotto)
            .environmentObject(UserSettings())
    }
    .environment(\.locale, Locale(identifier: "ja"))
}
