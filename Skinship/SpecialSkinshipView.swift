import SwiftUI
import AVFoundation

struct SpecialSkinshipView: View {
    @EnvironmentObject var settings: UserSettings
    
    @State private var text: String = ""
    @State private var isPressed = false
    @State private var savedToast = false
    
    // ✅ 読み上げ完了検知用
    @State private var synthesizer = AVSpeechSynthesizer()
    @State private var speechDelegate = SpeechFinishDelegate()
    
    private var trimmed: String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.black, Color.purple.opacity(0.65), Color.black],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 18) {
                    Text(NSLocalizedString("special_title", comment: "スペシャルスキンシップ"))
                        .font(.largeTitle.weight(.bold))
                        .foregroundColor(.white)
                        .padding(.top, 10)
                    
                    Text(NSLocalizedString("special_subtitle", comment: "好きなセリフを入力して、読み上げよう。"))
                        .foregroundColor(.white.opacity(0.75))
                    
                    // 入力エリア
                    VStack(alignment: .leading, spacing: 10) {
                        Text(NSLocalizedString("special_line_label", comment: "セリフ"))
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.9))
                        
                        TextEditor(text: $text)
                            .frame(minHeight: 140)
                            .padding(12)
                            .background(Color.white.opacity(0.12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.white.opacity(0.18), lineWidth: 1)
                            )
                            .cornerRadius(14)
                            .foregroundColor(.white)
                            .scrollContentBackground(.hidden)
                    }
                    .padding(.horizontal)
                    
                    // ボタン群
                    VStack(spacing: 12) {
                        // ✅ 保存（押した時だけ）
                        Button {
                            settings.addSpecialLineToCollection(text)
                            settings.impactHaptic(style: .light)
                            
                            withAnimation(.easeOut(duration: 0.2)) {
                                savedToast = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                withAnimation(.easeOut(duration: 0.25)) {
                                    savedToast = false
                                }
                            }
                        } label: {
                            Label(
                                NSLocalizedString("special_save", comment: "保存"),
                                systemImage: "tray.and.arrow.down.fill"
                            )
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.blue)
                        .disabled(trimmed.isEmpty)
                        .padding(.horizontal)
                        
                        // ✅ 読み上げ（レイアウト不変／内部処理だけ差し替え）
                        Button {
                            settings.impactHaptic(style: .medium)
                            
                            withAnimation(.spring(response: 0.22, dampingFraction: 0.6)) {
                                isPressed = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) {
                                withAnimation(.spring(response: 0.28, dampingFraction: 0.7)) {
                                    isPressed = false
                                }
                            }
                            
                            guard !trimmed.isEmpty, settings.isVoiceEnabled else { return }
                            
                            // ✅ ここで読み上げ（完了を delegate で拾う）
                            let utterance = AVSpeechUtterance(string: trimmed)
                            utterance.voice = AVSpeechSynthesisVoice(language: Locale.current.identifier)
                            utterance.rate = AVSpeechUtteranceDefaultSpeechRate
                            synthesizer.speak(utterance)
                            
                        } label: {
                            Label(
                                NSLocalizedString("special_read", comment: "読み上げ"),
                                systemImage: "speaker.wave.2.fill"
                            )
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.pink)
                        .scaleEffect(isPressed ? 0.97 : 1.0)
                        .disabled(trimmed.isEmpty || !settings.isVoiceEnabled)
                        .padding(.horizontal)
                        
                        // クリア
                        Button(role: .destructive) {
                            settings.impactHaptic(style: .light)
                            text = ""
                            settings.clearSpecialLine()
                        } label: {
                            Label(
                                NSLocalizedString("special_clear", comment: "クリア"),
                                systemImage: "trash.fill"
                            )
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .tint(.red)
                        .padding(.horizontal)
                        
                        // ✅ 集へ
                        NavigationLink {
                            SpecialSkinshipCollectionView()
                        } label: {
                            Label(
                                NSLocalizedString("special_collection_title", comment: "スペシャルスキンシップ集"),
                                systemImage: "books.vertical.fill"
                            )
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .tint(.white.opacity(0.9))
                        .padding(.horizontal)
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding(.bottom, 30)
                
                // セリフについて（一番下）
                VStack(alignment: .leading, spacing: 8) {
                    Text(NSLocalizedString("special_suggest_title", comment: "セリフについて"))
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                    
                    Text(NSLocalizedString("special_suggest_1", comment: ""))
                    Text(NSLocalizedString("special_suggest_2", comment: ""))
                    Text(NSLocalizedString("special_suggest_3", comment: ""))
                    Text(NSLocalizedString("special_suggest_4", comment: ""))
                }
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.5))
                .padding(.horizontal)
                .padding(.top, 16)
                
            }
            
            // 保存トースト
            if savedToast {
                Text(NSLocalizedString("special_saved_toast", comment: "保存しました"))
                    .font(.footnote.weight(.semibold))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.18))
                    .cornerRadius(14)
                    .foregroundColor(.white)
                    .transition(.opacity)
                    .padding(.bottom, 24)
                    .frame(maxHeight: .infinity, alignment: .bottom)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            text = settings.specialLine
            
            // ✅ delegate セット＆読み上げ完了時の処理
            synthesizer.delegate = speechDelegate
            speechDelegate.onFinish = {
                // ✅ 読み上げ終了後「余韻」を置いてから 5回に1回広告判定
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    UnityAdsManager.shared.showAdIfNeededAfterSpecial()
                }
            }
        }
    }
}

// ✅ 読み上げ完了検知
final class SpeechFinishDelegate: NSObject, AVSpeechSynthesizerDelegate {
    var onFinish: (() -> Void)?
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer,
                           didFinish utterance: AVSpeechUtterance) {
        onFinish?()
    }
}

#Preview {
    NavigationStack {
        SpecialSkinshipView()
            .environmentObject(UserSettings())
    }
}
